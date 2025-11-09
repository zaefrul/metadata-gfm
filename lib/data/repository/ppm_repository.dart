import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:GEMS/data/local/entities/ppm_entities.dart';
import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/model/form.dart';
import 'package:GEMS/utils/network.dart';
import 'package:sqflite/sqflite.dart';

enum PPMActionResult {
  success,
  queued, // Stored for offline sync
}

class PPMRepository {
  final OfflineDatabase _database = OfflineDatabase.instance;
  DateTime Function() _clock = () => DateTime.now();

  // Expose database for direct queries when needed
  Future<Database> get database => _database.database;

  // For testing purposes
  @visibleForTesting
  void overrideClock(DateTime Function() clock) {
    _clock = clock;
  }

  // ============================================================================
  // MAINTENANCE IMAGES (Form H)
  // ============================================================================

  Future<List<FormHItem>> getMaintenanceImages({
    required String ppmTaskId,
    bool forceRefresh = false,
    void Function(List<FormHItem>)? onRemoteUpdate,
  }) async {
    debugPrint('PPMRepository.getMaintenanceImages: ppmTaskId=$ppmTaskId, forceRefresh=$forceRefresh');
    
    final cached = await _database.getPPMMaintenanceImages(ppmTaskId);
    debugPrint('PPMRepository.getMaintenanceImages: Found ${cached.length} cached images');

    if (cached.isNotEmpty && !forceRefresh) {
      final images = cached.map<FormHItem>(_formHItemFromEntity).toList();
      if (onRemoteUpdate != null) {
        unawaited(
          _refreshMaintenanceImages(ppmTaskId: ppmTaskId).then((value) {
            onRemoteUpdate(value);
          }),
        );
      }
      return images;
    }

    final refreshed = await _refreshMaintenanceImages(ppmTaskId: ppmTaskId);
    if (refreshed.isEmpty && cached.isNotEmpty) {
      return cached.map<FormHItem>(_formHItemFromEntity).toList();
    }

    return refreshed;
  }

  Future<List<FormHItem>> _refreshMaintenanceImages({
    required String ppmTaskId,
  }) async {
    debugPrint('PPMRepository._refreshMaintenanceImages: Fetching from API for ppmTaskId=$ppmTaskId');
    
    try {
      final images = await _fetchMaintenanceImagesRemote(ppmTaskId);
      debugPrint('PPMRepository._refreshMaintenanceImages: API returned ${images.length} images');
      
      // Save to database
      debugPrint('PPMRepository._refreshMaintenanceImages: Saving ${images.length} entities to database');
      final db = await _database.database;
      await db.transaction((txn) async {
        // Clear existing images for this task
        await txn.delete(
          'ppm_maintenance_images',
          where: 'ppm_task_id = ?',
          whereArgs: [ppmTaskId],
        );
        // Insert new ones
        for (final img in images) {
          await txn.insert(
            'ppm_maintenance_images',
            _formHItemToEntity(img, ppmTaskId).toMap(),
          );
        }
      });
      
      debugPrint('PPMRepository._refreshMaintenanceImages: Database save complete, returning ${images.length} images');
      return images;
    } catch (err, st) {
      debugPrint('PPMRepository._refreshMaintenanceImages: Error fetching images: $err\n$st');
      return [];
    }
  }

  Future<List<FormHItem>> _fetchMaintenanceImagesRemote(String ppmTaskId) async {
    debugPrint('PPMRepository._fetchMaintenanceImagesRemote: Calling API for ppmTaskId=$ppmTaskId');
    
    final provider = Provider(
      taskID: ppmTaskId,
      fetchURL: "/api/m_ppm.php?type=ppm_section_h&ppmTaskId=",
    );
    
    final response = await provider.fetch();
    final items = response.sectionHList?.toList() ?? [];
    
    debugPrint('PPMRepository._fetchMaintenanceImagesRemote: API response parsed, got ${items.length} images');
    return items;
  }

  Future<List<PendingMaintenanceImage>> getPendingMaintenanceImages(
    String ppmTaskId,
  ) async {
    debugPrint('PPMRepository.getPendingMaintenanceImages: Fetching for ppmTaskId=$ppmTaskId');
    
    final pending = await _database.getPPMPendingActions();
    debugPrint('PPMRepository.getPendingMaintenanceImages: Total pending actions in DB: ${pending.length}');
    
    if (pending.isEmpty) {
      debugPrint('PPMRepository.getPendingMaintenanceImages: No pending actions, returning empty list');
      return const [];
    }

    final results = <PendingMaintenanceImage>[];
    for (final action in pending) {
      debugPrint('  - Action: id=${action.id}, ppmTaskId=${action.ppmTaskId}, action=${action.action}, createdAt=${action.createdAt}');
      
      if (action.ppmTaskId != ppmTaskId) {
        debugPrint('    -> Skipped (different PPM task)');
        continue;
      }
      if (action.action != 'upload_maintenance_image') {
        debugPrint('    -> Skipped (action=${action.action})');
        continue;
      }
      try {
        final payload = json.decode(action.payloadJson) as Map<String, dynamic>;
        final data = payload['fileUpload[data]']?.toString();
        if (data == null || data.isEmpty) {
          debugPrint('    -> Skipped (no image data)');
          continue;
        }
        final bytes = base64Decode(data);
        debugPrint('    -> Adding to results (uploadType=${payload['uploadType']}, size=${bytes.length} bytes)');
        results.add(
          PendingMaintenanceImage(
            uploadType: _getUploadTypeLabel(payload['uploadType']?.toString() ?? '2'),
            bytes: bytes,
            createdAt: action.createdAt,
            latitude: payload['latitude']?.toString(),
            longitude: payload['longitude']?.toString(),
            displayName: payload['fileUpload[name]']?.toString(),
          ),
        );
      } catch (err) {
        debugPrint('    -> ERROR decoding: $err');
      }
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    debugPrint('PPMRepository.getPendingMaintenanceImages: Returning ${results.length} pending maintenance images');
    return results;
  }

  Future<PPMActionResult> uploadMaintenanceImage({
    required String ppmTaskId,
    required String uploadType, // '0' = Before, '1' = During, '2' = After
    required String latitude,
    required String longitude,
    required String displayName,
    required String filename,
    required int sizeBytes,
    required String base64Data,
  }) {
    return _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: {
        'action': 'upload_maintenance_image',
        'ppmTaskId': ppmTaskId,
        'uploadType': uploadType,
        'longitude': longitude,
        'latitude': latitude,
        'fileUpload[name]': displayName,
        'fileUpload[filename]': filename,
        'fileUpload[size]': sizeBytes.toString(),
        'fileUpload[type]': 'data:image/jpeg;base64',
        'fileUpload[data]': base64Data,
      },
    );
  }

  Future<PPMActionResult> saveMaintenanceImageDescriptions({
    required String ppmTaskId,
    required Map<String, String> descriptions,
  }) {
    final body = <String, String>{
      'action': 'save_image_desc',
      'ppmTaskId': ppmTaskId,
    };
    var index = 0;
    descriptions.forEach((key, value) {
      body['ppmTaskUpload[$index][ppmTaskUploadId]'] = key;
      body['ppmTaskUpload[$index][ppmTaskUploadDesc]'] = value;
      index++;
    });
    return _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: body,
    );
  }

  // ============================================================================
  // FORM F - ADDITIONAL REPORTS
  // ============================================================================

  Future<PPMActionResult> checkAdditionalReport({
    required String ppmTaskId,
    required bool hasAdditionalReport,
  }) {
    return _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: {
        'action': 'check_additional_report',
        'ppmTaskId': ppmTaskId,
        'checked': hasAdditionalReport ? '1' : '0',
      },
    );
  }

  Future<PPMActionResult> uploadAdditionalReport({
    required String ppmTaskId,
    required String displayName,
    required String filename,
    required int sizeBytes,
    required String base64Data,
  }) {
    return _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: {
        'action': 'upload_additional_report',
        'ppmTaskId': ppmTaskId,
        'fileUpload[name]': displayName,
        'fileUpload[filename]': filename,
        'fileUpload[size]': sizeBytes.toString(),
        'fileUpload[type]': 'data:image/jpeg;base64',
        'fileUpload[data]': base64Data,
      },
    );
  }

  // ============================================================================
  // FORM E - MATERIALS/SPARE PARTS
  // ============================================================================

  Future<PPMActionResult> checkMaterialsUsed({
    required String ppmTaskId,
    required bool hasMaterials,
  }) {
    return _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: {
        'action': 'check_ppm_parts',
        'ppmTaskId': ppmTaskId,
        'checked': hasMaterials ? '1' : '0',
      },
    );
  }

  Future<PPMActionResult> addMaterial({
    required String ppmTaskId,
    required String description,
  }) {
    return _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: {
        'action': 'add_ppm_parts',
        'ppmTaskId': ppmTaskId,
        'ppmTaskPartsDesc': description,
      },
    );
  }

  // ============================================================================
  // FORM C - QUALITATIVE TASKS
  // ============================================================================

  Future<PPMActionResult> saveQualitativeTasks({
    required String ppmTaskId,
    required List<Map<String, String>> tasks,
  }) async {
    final body = <String, String>{
      'action': 'save_qualitative_tasks',
      'ppmTaskId': ppmTaskId,
    };
    
    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      body['ppmTaskQual[$i][id]'] = task['id'] ?? '';
      body['ppmTaskQual[$i][result]'] = task['result'] ?? '';
      body['ppmTaskQual[$i][remark]'] = task['remark'] ?? '';
    }
    
    final result = await _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: body,
    );
    
    // If queued (offline mode), update the cache so user can see their changes
    if (result == PPMActionResult.queued) {
      await updateSectionCCache(ppmTaskId: ppmTaskId, tasks: tasks);
    }
    
    return result;
  }

  // ============================================================================
  // FORM D - QUANTITATIVE TASKS
  // ============================================================================

  Future<PPMActionResult> saveQuantitativeTasks({
    required String ppmTaskId,
    required List<Map<String, String>> tasks,
  }) async {
    final body = <String, String>{
      'action': 'save_quantitative_tasks',
      'ppmTaskId': ppmTaskId,
    };
    
    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      body['ppmTaskQuan[$i][id]'] = task['id'] ?? '';
      body['ppmTaskQuan[$i][setValues]'] = task['setValues'] ?? '';
      body['ppmTaskQuan[$i][measuredValues]'] = task['measuredValues'] ?? '';
      body['ppmTaskQuan[$i][limit]'] = task['limit'] ?? '';
      body['ppmTaskQuan[$i][result]'] = task['result'] ?? '';
      body['ppmTaskQuan[$i][remark]'] = task['remark'] ?? '';
    }
    
    final result = await _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: body,
    );
    
    // If queued (offline mode), update the cache so user can see their changes
    if (result == PPMActionResult.queued) {
      await updateSectionDCache(ppmTaskId: ppmTaskId, tasks: tasks);
    }
    
    return result;
  }

  // ============================================================================
  // FORM G - REMARK
  // ============================================================================

  Future<PPMActionResult> saveRemark({
    required String ppmTaskId,
    required String remark,
  }) async {
    final body = <String, String>{
      'action': 'save_ppm_remark',
      'ppmTaskId': ppmTaskId,
      'ppmTaskRemark': remark,
    };
    
    final result = await _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: body,
    );
    
    // If queued (offline mode), update the cache so user can see their changes
    if (result == PPMActionResult.queued) {
      await updateSectionGCache(ppmTaskId: ppmTaskId, remark: remark);
    }
    
    return result;
  }

  // ============================================================================
  // OFFLINE QUEUE MANAGEMENT
  // ============================================================================

  Future<PPMActionResult> _sendOrQueue({
    required String ppmTaskId,
    required Map<String, dynamic> body,
  }) async {
    final action = body['action']?.toString() ?? 'unknown';
    debugPrint('PPMRepository._sendOrQueue: action=$action, ppmTaskId=$ppmTaskId');
    
    // Check if offline mode is enabled
    final isOffline = await isOfflineModeEnabled(ppmTaskId);
    if (isOffline) {
      debugPrint('PPMRepository._sendOrQueue: Offline mode enabled, queuing action');
      await _queueAction(ppmTaskId, body);
      return PPMActionResult.queued;
    }
    
    try {
      debugPrint('PPMRepository._sendOrQueue: Attempting to sync pending actions first...');
      await syncPendingActions();
      debugPrint('PPMRepository._sendOrQueue: Attempting to post...');
      await _post(body);
      debugPrint('PPMRepository._sendOrQueue: POST successful, returning success');
      return PPMActionResult.success;
    } on SocketException catch (e) {
      debugPrint('PPMRepository._sendOrQueue: SocketException caught: $e');
      await _queueAction(ppmTaskId, body);
      debugPrint('PPMRepository._sendOrQueue: Action queued due to SocketException');
      return PPMActionResult.queued;
    } on TimeoutException catch (e) {
      debugPrint('PPMRepository._sendOrQueue: TimeoutException caught: $e');
      await _queueAction(ppmTaskId, body);
      debugPrint('PPMRepository._sendOrQueue: Action queued due to TimeoutException');
      return PPMActionResult.queued;
    } catch (e) {
      debugPrint('PPMRepository._sendOrQueue: Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> _queueAction(
    String ppmTaskId,
    Map<String, dynamic> body,
  ) async {
    final action = body['action']?.toString() ?? 'unknown';
    debugPrint('PPMRepository._queueAction: Queuing action=$action for ppmTaskId=$ppmTaskId');
    
    // Map WO-style action names to PPM action names
    final ppmAction = action
        .replaceAll('upload_repair_image', 'upload_maintenance_image')
        .replaceAll('wo_repair_image', 'ppm_maintenance_image');
    
    await _database.enqueuePPMPendingAction(
      PPMPendingActionEntity(
        ppmTaskId: ppmTaskId,
        action: ppmAction,
        payloadJson: json.encode(body),
        createdAt: _clock(),
      ),
    );
    
    debugPrint('PPMRepository._queueAction: Action queued successfully');
  }

  Future<void> _post(Map<String, dynamic> body) async {
    final action = body['action'];
    final ppmTaskId = body['ppmTaskId'];
    
    // Log diagnostic info for image uploads
    if (action == 'upload_ppm_maintenance_image') {
      final base64Data = body['fileUpload[data]'];
      final sizeKB = base64Data != null ? (base64Data.length / 1024).toStringAsFixed(2) : '0';
      debugPrint('Uploading PPM maintenance image: action=$action, ppmTaskId=$ppmTaskId, size=${sizeKB}KB');
    }
    
    final provider = Provider(
      taskID: ppmTaskId.toString(),
      fetchURL: '/api/m_ppm.php',
    );
    
    await provider.post(
      url: '/api/m_ppm.php',
      body: body,
    );
  }

  Future<void> syncPendingActions() async {
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('🔄 PPMRepository.syncPendingActions: Starting sync...');
    debugPrint('═══════════════════════════════════════════════════════════════');
    
    final pending = await _database.getPPMPendingActions();
    if (pending.isEmpty) {
      debugPrint('✓ PPMRepository.syncPendingActions: No pending actions to sync');
      return;
    }

    debugPrint('📋 PPMRepository.syncPendingActions: Found ${pending.length} pending actions');
    
    var successCount = 0;
    var failureCount = 0;
    
    for (final action in pending) {
      try {
        debugPrint('');
        debugPrint('┌─────────────────────────────────────────────────────────────');
        debugPrint('│ Processing Pending Action #${action.id}');
        debugPrint('├─────────────────────────────────────────────────────────────');
        debugPrint('│ PPM Task ID: ${action.ppmTaskId}');
        debugPrint('│ Action Type: ${action.action}');
        debugPrint('│ Created At: ${action.createdAt}');
        
        final body = json.decode(action.payloadJson) as Map<String, dynamic>;
        
        debugPrint('├─────────────────────────────────────────────────────────────');
        debugPrint('│ 🌐 Sending to API: /api/m_ppm.php');
        debugPrint('├─────────────────────────────────────────────────────────────');
        debugPrint('│ Request Body:');
        body.forEach((key, value) {
          debugPrint('│   $key: $value');
        });
        debugPrint('└─────────────────────────────────────────────────────────────');
        
        await _post(body);
        
        if (action.id != null) {
          await _database.removePPMPendingAction(action.id!);
          successCount++;
          debugPrint('✅ Action ${action.id} synced successfully and removed from queue');
        }
      } catch (err, st) {
        failureCount++;
        debugPrint('❌ Failed to sync action ${action.id}: $err');
        debugPrint('   Stack trace: $st');
        // Don't break - continue with other actions
        continue;
      }
    }
    
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('📊 Sync Summary:');
    debugPrint('   ✅ Success: $successCount');
    debugPrint('   ❌ Failed: $failureCount');
    debugPrint('   📝 Total: ${pending.length}');
    debugPrint('═══════════════════════════════════════════════════════════════');
  }

  /// Get the count of pending actions for a specific task or all tasks
  Future<int> getPendingActionCount({String? ppmTaskId}) async {
    return await _database.getPPMPendingActionCount(ppmTaskId: ppmTaskId);
  }

  /// Get list of pending actions for a specific task or all tasks
  Future<List<PPMPendingActionEntity>> getPendingActions({String? ppmTaskId}) async {
    return await _database.getPPMPendingActions(ppmTaskId: ppmTaskId);
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  FormHItem _formHItemFromEntity(PPMMaintenanceImageEntity entity) {
    return FormHItem((b) => b
      ..ppmTaskUploadId = entity.ppmTaskUploadId
      ..ppmTaskUploadType = entity.uploadType
      ..ppmTaskId = entity.ppmTaskId
      ..ppmTaskUploadLongitude = entity.longitude ?? ''
      ..ppmTaskUploadLatitude = entity.latitude ?? ''
      ..ppmTaskUploadTimestamp = entity.timestamp ?? ''
      ..ppmTaskUploadDesc = entity.description ?? ''
      ..uploadId = entity.uploadId ?? ''
      ..uploadName = entity.uploadName ?? ''
      ..documentDesc = entity.documentDesc ?? ''
      ..documentFilename = entity.documentFilename ?? ''
      ..documentSrc = entity.documentSrc ?? '');
  }

  PPMMaintenanceImageEntity _formHItemToEntity(FormHItem item, String ppmTaskId) {
    return PPMMaintenanceImageEntity(
      ppmTaskUploadId: item.ppmTaskUploadId,
      ppmTaskId: ppmTaskId,
      uploadType: item.ppmTaskUploadType,
      latitude: item.ppmTaskUploadLatitude,
      longitude: item.ppmTaskUploadLongitude,
      timestamp: item.ppmTaskUploadTimestamp,
      description: item.ppmTaskUploadDesc,
      uploadId: item.uploadId,
      uploadName: item.uploadName,
      documentDesc: item.documentDesc,
      documentFilename: item.documentFilename,
      documentSrc: item.documentSrc,
    );
  }

  String _getUploadTypeLabel(String uploadType) {
    switch (uploadType) {
      case '2':
        return 'Before';
      case '3':
        return 'During';
      case '4':
        return 'After';
      default:
        return 'Unknown';
    }
  }

  // ============================================================================
  // OFFLINE MODE MANAGEMENT
  // ============================================================================

  /// Enable or disable offline mode for a PPM task
  Future<void> setOfflineMode({
    required String ppmTaskId,
    required bool enabled,
  }) async {
    debugPrint('PPMRepository.setOfflineMode: ppmTaskId=$ppmTaskId, enabled=$enabled');
    
    if (enabled) {
      // Download snapshot when enabling offline mode
      try {
        await downloadSnapshot(ppmTaskId: ppmTaskId);
        await _database.setPPMOfflineMode(ppmTaskId, true);
      } catch (err, st) {
        debugPrint('PPMRepository.setOfflineMode: Failed to download snapshot: $err\n$st');
        await _database.setPPMOfflineMode(ppmTaskId, false);
        rethrow;
      }
    } else {
      // Disable offline mode and optionally delete snapshot
      await _database.setPPMOfflineMode(ppmTaskId, false);
      await _database.deletePPMSnapshot(ppmTaskId);
    }
  }

  /// Check if offline mode is enabled for a PPM task
  Future<bool> isOfflineModeEnabled(String ppmTaskId) async {
    final result = await _database.isPPMOfflineMode(ppmTaskId);
    debugPrint('PPMRepository.isOfflineModeEnabled: ppmTaskId=$ppmTaskId, result=$result');
    return result;
  }

  /// Download and cache all task data for offline use
  Future<void> downloadSnapshot({
    required String ppmTaskId,
  }) async {
    debugPrint('PPMRepository.downloadSnapshot: Starting snapshot download for ppmTaskId=$ppmTaskId');

    // Fetch sections status
    List<Map<String, dynamic>> sections = [];
    try {
      final provider = Provider(
        taskID: ppmTaskId,
        fetchURL: "/ppm_v2/ppm_section_status/",
      );
      final response = await provider.getJson(url: "/ppm_v2/ppm_section_status/");
      
      // getJson() already returns the 'result' field, not the full response
      if (response != null && response is List) {
        sections = response.map((item) => {
          'ppmTaskSectionName': item['ppmTaskSectionName'] ?? '',
          'ppmTaskSectionStatus': item['ppmTaskSectionStatus'] ?? '',
          'checkParts': item['checkParts'] ?? '',
          'checkAdditionalReport': item['checkAdditionalReport'] ?? '',
        }).toList();
      }
      debugPrint('PPMRepository.downloadSnapshot: Fetched ${sections.length} sections');
    } catch (err, st) {
      debugPrint('PPMRepository.downloadSnapshot: Failed to fetch sections: $err\n$st');
      throw Exception('Failed to download task sections for offline use. Please check your connection.');
    }

    if (sections.isEmpty) {
      throw Exception('No sections found for this task. Cannot enable offline mode.');
    }

    // Fetch detailed section data for each section
    debugPrint('PPMRepository.downloadSnapshot: Downloading detailed data for ${sections.length} sections...');
    for (var section in sections) {
      final sectionName = section['ppmTaskSectionName'] as String;
      try {
        final sectionProvider = Provider(
          taskID: ppmTaskId,
          fetchURL: "/api/m_ppm.php?type=ppm_section_${sectionName.toLowerCase()}&ppmTaskId=",
        );
        final sectionData = await sectionProvider.getJson(url: "/api/m_ppm.php?type=ppm_section_${sectionName.toLowerCase()}&ppmTaskId=");
        
        if (sectionData != null) {
          section['sectionData'] = json.encode(sectionData);
          debugPrint('PPMRepository.downloadSnapshot: Downloaded data for section $sectionName');
        }
      } catch (err) {
        debugPrint('PPMRepository.downloadSnapshot: Failed to download section $sectionName data: $err');
        // Continue with other sections even if one fails
      }
    }

    // Fetch execution info (time allocation)
    String? executionJson;
    try {
      final provider = Provider(
        fetchURL: '/ppm_v2/execution_info/',
        taskID: ppmTaskId,
      );
      final execData = await provider.getJson(url: '/ppm_v2/execution_info/');
      if (execData != null) {
        executionJson = json.encode(execData);
      }
      debugPrint('PPMRepository.downloadSnapshot: Fetched execution info');
    } catch (err, st) {
      debugPrint('PPMRepository.downloadSnapshot: Failed to fetch execution info (non-critical): $err\n$st');
    }

    // Fetch and cache technician list
    try {
      final technicianProvider = Provider(
        fetchURL: '/ppm_task_assist/dropdown_list/',
        taskID: ppmTaskId,
      );
      final selectedProvider = Provider(
        fetchURL: '/ppm_task_assist/assistant_list/',
        taskID: ppmTaskId,
      );
      
      final List<dynamic> technicianList = await technicianProvider.getJson(url: '/ppm_task_assist/dropdown_list/') ?? [];
      final List<dynamic> selectedList = await selectedProvider.getJson(url: '/ppm_task_assist/assistant_list/') ?? [];
      
      // Convert to List<Map<String, dynamic>>
      final technicians = technicianList.map((e) => e as Map<String, dynamic>).toList();
      final selectedTechnicians = selectedList.map((e) => e as Map<String, dynamic>).toList();
      
      if (technicians.isNotEmpty || selectedTechnicians.isNotEmpty) {
        await cacheTechnicians(
          ppmTaskId: ppmTaskId,
          technicians: technicians,
          selectedTechnicians: selectedTechnicians,
        );
        debugPrint('PPMRepository.downloadSnapshot: Cached ${technicians.length} available and ${selectedTechnicians.length} selected technicians');
      }
    } catch (err, st) {
      debugPrint('PPMRepository.downloadSnapshot: Failed to cache technicians (non-critical): $err\n$st');
      // Continue even if technician caching fails
    }

    // Save snapshot to database
    await _database.savePPMSnapshot(
      ppmTaskId: ppmTaskId,
      taskNo: '', // Will be populated from task list if needed
      siteName: '',
      status: '',
      sections: sections,
      executionJson: executionJson,
    );

    debugPrint('PPMRepository.downloadSnapshot: Snapshot saved successfully with section data');
  }

  /// Load cached snapshot data
  Future<Map<String, dynamic>?> loadSnapshot(String ppmTaskId) async {
    debugPrint('PPMRepository.loadSnapshot: Loading snapshot for ppmTaskId=$ppmTaskId');
    final snapshot = await _database.loadPPMSnapshot(ppmTaskId);
    if (snapshot != null) {
      debugPrint('PPMRepository.loadSnapshot: Found cached snapshot with ${(snapshot['sections'] as List).length} sections');
    } else {
      debugPrint('PPMRepository.loadSnapshot: No snapshot found');
    }
    return snapshot;
  }

  /// Load section data for offline mode
  Future<dynamic> loadSectionData(String ppmTaskId, String sectionName) async {
    debugPrint('PPMRepository.loadSectionData: Loading section $sectionName for task $ppmTaskId');
    final sectionDataJson = await _database.loadPPMSectionData(ppmTaskId, sectionName);
    
    if (sectionDataJson != null && sectionDataJson.isNotEmpty) {
      try {
        final data = json.decode(sectionDataJson);
        debugPrint('PPMRepository.loadSectionData: Successfully loaded cached data for section $sectionName');
        return data;
      } catch (err) {
        debugPrint('PPMRepository.loadSectionData: Failed to parse section data: $err');
        return null;
      }
    }
    
    debugPrint('PPMRepository.loadSectionData: No cached data found for section $sectionName');
    return null;
  }

  /// Save PPM start time offline (to be synced later)
  Future<void> savePPMStartTimeOffline({
    required String ppmTaskId,
    bool groupExecution = false,
    DateTime? startTime,
  }) async {
    final timestamp = startTime ?? _clock();
    debugPrint('PPMRepository.savePPMStartTimeOffline: Saving start time for task $ppmTaskId at $timestamp');
    
    final actionData = json.encode({
      'ppmTaskId': ppmTaskId,
      'ppmGroupExecution': groupExecution ? '1' : '0',
      'startTime': timestamp.toIso8601String(),
    });
    
    await _database.savePPMOfflineAction(
      ppmTaskId: ppmTaskId,
      actionType: 'start_time',
      actionData: actionData,
      timestamp: timestamp.toIso8601String(),
    );
    
    debugPrint('PPMRepository.savePPMStartTimeOffline: Start time saved to local database');
  }

  /// Update Section A data with start time in local cache
  Future<void> updateSectionAStartTime({
    required String ppmTaskId,
    required DateTime startTime,
  }) async {
    debugPrint('PPMRepository.updateSectionAStartTime: Updating Section A cache with start time');
    
    try {
      // Load existing section A data
      final sectionDataJson = await loadSectionData(ppmTaskId, 'A');
      
      if (sectionDataJson != null) {
        // Parse existing data
        final sectionData = json.decode(sectionDataJson) as Map<String, dynamic>;
        
        // Update the ppmTaskTimeStart field with formatted timestamp
        // Format: "YYYY-MM-DD HH:MM:SS" to match backend format
        final formattedTime = '${startTime.year.toString().padLeft(4, '0')}-'
            '${startTime.month.toString().padLeft(2, '0')}-'
            '${startTime.day.toString().padLeft(2, '0')} '
            '${startTime.hour.toString().padLeft(2, '0')}:'
            '${startTime.minute.toString().padLeft(2, '0')}:'
            '${startTime.second.toString().padLeft(2, '0')}';
        
        sectionData['ppmTaskTimeStart'] = formattedTime;
        
        // Save back to cache using database method
        await _database.savePPMSectionData(
          ppmTaskId: ppmTaskId,
          sectionName: 'A',
          sectionData: json.encode(sectionData),
        );
        
        debugPrint('PPMRepository.updateSectionAStartTime: Updated cache with start time: $formattedTime');
      } else {
        debugPrint('PPMRepository.updateSectionAStartTime: No cached Section A data found');
      }
    } catch (err) {
      debugPrint('PPMRepository.updateSectionAStartTime: Error updating cache: $err');
      // Don't throw - this is not critical, the time will sync from server later
    }
  }

  /// Update Section D (Quantitative) data in local cache after offline save
  Future<void> updateSectionDCache({
    required String ppmTaskId,
    required List<Map<String, String>> tasks,
  }) async {
    debugPrint('PPMRepository.updateSectionDCache: Updating Section D cache with ${tasks.length} tasks');
    
    try {
      // Load existing section D data
      final sectionData = await loadSectionData(ppmTaskId, 'D');
      
      if (sectionData != null && sectionData is Map<String, dynamic>) {
        // Update the tasks in the section data
        final sectionDList = sectionData['sectionDList'] as List<dynamic>?;
        
        if (sectionDList != null) {
          // Update each task with the saved values
          for (var task in tasks) {
            final taskId = task['id'];
            final index = sectionDList.indexWhere((t) => t['ppmTaskQuanId'] == taskId);
            
            if (index != -1) {
              sectionDList[index]['ppmTaskQuanSetValues'] = task['setValues'] ?? '';
              sectionDList[index]['ppmTaskQuanMeasuredValues'] = task['measuredValues'] ?? '';
              sectionDList[index]['ppmTaskQuanLimit'] = task['limit'] ?? '';
              sectionDList[index]['ppmTaskQuanResult'] = _convertStatusToText(task['result'] ?? '');
              sectionDList[index]['ppmTaskQuanRemark'] = task['remark'] ?? '';
            }
          }
          
          // Save updated data back to cache
          await _database.savePPMSectionData(
            ppmTaskId: ppmTaskId,
            sectionName: 'D',
            sectionData: json.encode(sectionData),
          );
          
          debugPrint('PPMRepository.updateSectionDCache: Successfully updated cache');
        }
      }
    } catch (err) {
      debugPrint('PPMRepository.updateSectionDCache: Error updating cache: $err');
    }
  }

  /// Update Section C (Qualitative) data in local cache after offline save
  Future<void> updateSectionCCache({
    required String ppmTaskId,
    required List<Map<String, String>> tasks,
  }) async {
    debugPrint('PPMRepository.updateSectionCCache: Updating Section C cache with ${tasks.length} tasks');
    
    try {
      // Load existing section C data
      final sectionData = await loadSectionData(ppmTaskId, 'C');
      
      if (sectionData != null && sectionData is Map<String, dynamic>) {
        // Update the tasks in the section data
        final sectionCList = sectionData['sectionCList'] as List<dynamic>?;
        
        if (sectionCList != null) {
          // Update each task with the saved values
          for (var task in tasks) {
            final taskId = task['id'];
            final index = sectionCList.indexWhere((t) => t['ppmTaskQualId'] == taskId);
            
            if (index != -1) {
              sectionCList[index]['ppmTaskQualResult'] = _convertStatusToText(task['result'] ?? '');
              sectionCList[index]['ppmTaskQualRemark'] = task['remark'] ?? '';
            }
          }
          
          // Save updated data back to cache
          await _database.savePPMSectionData(
            ppmTaskId: ppmTaskId,
            sectionName: 'C',
            sectionData: json.encode(sectionData),
          );
          
          debugPrint('PPMRepository.updateSectionCCache: Successfully updated cache');
        }
      }
    } catch (err) {
      debugPrint('PPMRepository.updateSectionCCache: Error updating cache: $err');
    }
  }

  /// Update Section G (Remark) cache after offline save
  Future<void> updateSectionGCache({
    required String ppmTaskId,
    required String remark,
  }) async {
    debugPrint('PPMRepository.updateSectionGCache: Updating Section G cache with remark');
    
    try {
      // Load existing section G data
      final sectionData = await loadSectionData(ppmTaskId, 'G');
      
      if (sectionData != null && sectionData is Map<String, dynamic>) {
        // Update the remark in the section data
        final sectionGList = sectionData['sectionGList'] as Map<String, dynamic>?;
        
        if (sectionGList != null) {
          sectionGList['ppmTaskRemark'] = remark;
          
          // Save updated data back to cache
          await _database.savePPMSectionData(
            ppmTaskId: ppmTaskId,
            sectionName: 'G',
            sectionData: json.encode(sectionData),
          );
          
          debugPrint('PPMRepository.updateSectionGCache: Successfully updated cache');
        }
      } else {
        // If no cache exists, create a new one
        final newSectionData = {
          'sectionGList': {
            'ppmTaskRemark': remark,
          }
        };
        
        await _database.savePPMSectionData(
          ppmTaskId: ppmTaskId,
          sectionName: 'G',
          sectionData: json.encode(newSectionData),
        );
        
        debugPrint('PPMRepository.updateSectionGCache: Created new cache entry');
      }
    } catch (err) {
      debugPrint('PPMRepository.updateSectionGCache: Error updating cache: $err');
    }
  }

  /// Convert status code to text for display
  String _convertStatusToText(String statusCode) {
    switch (statusCode) {
      case '1':
        return 'Pass';
      case '0':
        return 'Fail';
      case '2':
        return 'N/A';
      default:
        return statusCode;
    }
  }

  /// Get all unsynced offline actions
  Future<List<Map<String, dynamic>>> getUnsyncedActions({String? ppmTaskId}) async {
    return await _database.getPPMUnsyncedActions(ppmTaskId: ppmTaskId);
  }

  /// Sync offline actions to server
  Future<void> syncOfflineActions() async {
    debugPrint('PPMRepository.syncOfflineActions: Starting sync');
    final actions = await _database.getPPMUnsyncedActions();
    
    debugPrint('PPMRepository.syncOfflineActions: Found ${actions.length} unsynced actions');
    
    for (var action in actions) {
      try {
        debugPrint('PPMRepository.syncOfflineActions: Processing action ${action['id']}:');
        debugPrint('  - Type: ${action['action_type']}');
        debugPrint('  - PPM Task ID: ${action['ppm_task_id']}');
        debugPrint('  - Queue Timestamp: ${action['timestamp']}');
        debugPrint('  - Action Data: ${action['action_data']}');
        
        if (action['action_type'] == 'start_time') {
          final actionData = json.decode(action['action_data']);
          
          // Create provider and call the API
          final provider = Provider(
            fetchURL: "/api/m_ppm.php",
          );
          
          // Use the recorded start time from the action data (not the queue timestamp)
          final startTime = actionData['startTime'] ?? action['timestamp'];
          
          // Prepare the request body
          final requestBody = {
            "action": "save_scan_start_time",
            "ppmTaskId": actionData['ppmTaskId'],
            "ppmGroupExecution": actionData['ppmGroupExecution'],
            "scan_start_timer": startTime, // Backend expects scan_start_timer field
          };
          
          debugPrint('╔════════════════════════════════════════════════════════════════');
          debugPrint('║ 🔄 SYNCING TO API: /api/m_ppm.php');
          debugPrint('╠════════════════════════════════════════════════════════════════');
          debugPrint('║ Request Body:');
          debugPrint('║   action: ${requestBody['action']}');
          debugPrint('║   ppmTaskId: ${requestBody['ppmTaskId']}');
          debugPrint('║   ppmGroupExecution: ${requestBody['ppmGroupExecution']}');
          debugPrint('║   scan_start_timer: ${requestBody['scan_start_timer']}');
          debugPrint('╠════════════════════════════════════════════════════════════════');
          debugPrint('║ Note: scan_start_timer is the OFFLINE start time, not sync time');
          debugPrint('╚════════════════════════════════════════════════════════════════');
          
          await provider.post(
            url: "/api/m_ppm.php",
            body: requestBody,
          );
          
          // Mark as synced
          await _database.markPPMActionSynced(action['id']);
          debugPrint('✅ PPMRepository.syncOfflineActions: Successfully synced action ${action['id']}');
        }
      } catch (err) {
        debugPrint('PPMRepository.syncOfflineActions: Failed to sync action ${action['id']}: $err');
        await _database.markPPMActionFailed(action['id'], err.toString());
      }
    }
    
    // Clean up synced actions
    await _database.deleteSyncedPPMActions();
    debugPrint('PPMRepository.syncOfflineActions: Sync complete');
  }

  /// Get count of unsynced actions for a task
  Future<int> getUnsyncedActionCount(String ppmTaskId) async {
    return await _database.getPPMUnsyncedActionCount(ppmTaskId);
  }

  // ============================================================================
  // TECHNICIAN MANAGEMENT
  // ============================================================================

  /// Cache technician list when enabling offline mode
  Future<void> cacheTechnicians({
    required String ppmTaskId,
    required List<Map<String, dynamic>> technicians,
    required List<Map<String, dynamic>> selectedTechnicians,
  }) async {
    await _database.cachePPMTechnicians(
      ppmTaskId: ppmTaskId,
      technicians: technicians,
      selectedTechnicians: selectedTechnicians,
    );
  }

  /// Get technician list (from cache if offline, from API if online)
  Future<List<Map<String, dynamic>>> getTechnicians(String ppmTaskId) async {
    final isOffline = await isOfflineModeEnabled(ppmTaskId);
    
    if (isOffline) {
      // Load from cache
      return await _database.getCachedPPMTechnicians(ppmTaskId);
    }
    
    // Check if cache exists (we can use cached data even in online mode)
    final hasCache = await _database.hasCachedPPMTechnicians(ppmTaskId);
    if (hasCache) {
      return await _database.getCachedPPMTechnicians(ppmTaskId);
    }
    
    // No cache, must be online - return empty (caller should fetch from API)
    return [];
  }

  /// Get selected technicians (from cache if offline, from API if online)
  Future<List<Map<String, dynamic>>> getSelectedTechnicians(String ppmTaskId) async {
    final isOffline = await isOfflineModeEnabled(ppmTaskId);
    
    if (isOffline) {
      // Load from cache
      return await _database.getCachedPPMSelectedTechnicians(ppmTaskId);
    }
    
    // Check if cache exists
    final hasCache = await _database.hasCachedPPMTechnicians(ppmTaskId);
    if (hasCache) {
      return await _database.getCachedPPMSelectedTechnicians(ppmTaskId);
    }
    
    // No cache, must be online - return empty (caller should fetch from API)
    return [];
  }

  /// Check if technician cache exists
  Future<bool> hasCachedTechnicians(String ppmTaskId) async {
    return await _database.hasCachedPPMTechnicians(ppmTaskId);
  }

  /// Complete PPM task - records end time
  /// Returns PPMActionResult.success if online, PPMActionResult.queued if offline
  Future<PPMActionResult> completeTask({
    required String ppmTaskId,
    required DateTime endTime,
  }) async {
    debugPrint('PPMRepository.completeTask: ppmTaskId=$ppmTaskId, endTime=$endTime');

    final isOffline = await isOfflineModeEnabled(ppmTaskId);

    if (isOffline) {
      // Queue the complete action for offline sync
      debugPrint('PPMRepository.completeTask: Offline mode - queuing action');
      await _database.enqueuePPMPendingAction(
        PPMPendingActionEntity(
          ppmTaskId: ppmTaskId,
          action: 'complete_ppm_task',
          payloadJson: json.encode({
            'ppmTaskId': ppmTaskId,
            'endTime': endTime.toIso8601String(),
            'completedOffline': true,
          }),
          createdAt: DateTime.now(),
        ),
      );
      return PPMActionResult.queued;
    }

    // Online - call API directly
    try {
      final provider = Provider(
        taskID: ppmTaskId,
        fetchURL: '/api/m_ppm.php',
      );

      final body = {
        'action': 'complete_ppm_task',
        'ppmTaskId': ppmTaskId,
        'endTime': endTime.toIso8601String(),
        'completedOffline': false,
      };

      final response = await provider.post(url: '/api/m_ppm.php', body: body);
      debugPrint('PPMRepository.completeTask: API response: $response');

      return PPMActionResult.success;
    } catch (err, st) {
      debugPrint('PPMRepository.completeTask: Error calling API: $err\n$st');
      rethrow;
    }
  }

  /// Queue complete task action for offline sync (called by completeTask when offline)
  Future<void> queueCompleteTask({
    required String ppmTaskId,
    required DateTime endTime,
  }) async {
    await _database.enqueuePPMPendingAction(
      PPMPendingActionEntity(
        ppmTaskId: ppmTaskId,
        action: 'complete_ppm_task',
        payloadJson: json.encode({
          'ppmTaskId': ppmTaskId,
          'endTime': endTime.toIso8601String(),
          'completedOffline': true,
        }),
        createdAt: DateTime.now(),
      ),
    );
  }
}

