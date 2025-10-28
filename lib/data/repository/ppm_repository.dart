import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:GEMS/data/local/entities/ppm_entities.dart';
import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/model/form.dart';
import 'package:GEMS/utils/network.dart';

enum PPMActionResult {
  success,
  queued, // Stored for offline sync
}

class PPMRepository {
  final OfflineDatabase _database = OfflineDatabase.instance;
  DateTime Function() _clock = () => DateTime.now();

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
    required String uploadType, // '2' = Before, '3' = During, '4' = After
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
        'action': 'upload_ppm_maintenance_image',
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
      'action': 'save_ppm_maintenance_image_desc',
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
  }) {
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
    
    return _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: body,
    );
  }

  // ============================================================================
  // FORM D - QUANTITATIVE TASKS
  // ============================================================================

  Future<PPMActionResult> saveQuantitativeTasks({
    required String ppmTaskId,
    required List<Map<String, String>> tasks,
  }) {
    final body = <String, String>{
      'action': 'save_quantitative_tasks',
      'ppmTaskId': ppmTaskId,
    };
    
    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      body['ppmTaskQuant[$i][id]'] = task['id'] ?? '';
      body['ppmTaskQuant[$i][result]'] = task['result'] ?? '';
      body['ppmTaskQuant[$i][remark]'] = task['remark'] ?? '';
    }
    
    return _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: body,
    );
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
    debugPrint('PPMRepository.syncPendingActions: Starting sync...');
    
    final pending = await _database.getPPMPendingActions();
    if (pending.isEmpty) {
      debugPrint('PPMRepository.syncPendingActions: No pending actions');
      return;
    }

    debugPrint('PPMRepository.syncPendingActions: Found ${pending.length} pending actions');
    
    var successCount = 0;
    var failureCount = 0;
    
    for (final action in pending) {
      try {
        debugPrint('PPMRepository.syncPendingActions: Processing action ${action.id}: ${action.action}');
        
        final body = json.decode(action.payloadJson) as Map<String, dynamic>;
        await _post(body);
        
        if (action.id != null) {
          await _database.removePPMPendingAction(action.id!);
          successCount++;
          debugPrint('PPMRepository.syncPendingActions: Action ${action.id} synced and removed');
        }
      } catch (err, st) {
        failureCount++;
        debugPrint('PPMRepository.syncPendingActions: Failed to sync action ${action.id}: $err\n$st');
        // Don't break - continue with other actions
        continue;
      }
    }
    
    debugPrint('PPMRepository.syncPendingActions: Sync complete - Success: $successCount, Failed: $failureCount');
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
  }) async {
    debugPrint('PPMRepository.savePPMStartTimeOffline: Saving start time for task $ppmTaskId');
    
    final actionData = json.encode({
      'ppmTaskId': ppmTaskId,
      'ppmGroupExecution': groupExecution ? '1' : '0',
    });
    
    await _database.savePPMOfflineAction(
      ppmTaskId: ppmTaskId,
      actionType: 'start_time',
      actionData: actionData,
    );
    
    debugPrint('PPMRepository.savePPMStartTimeOffline: Start time saved to local database');
  }

  /// Get all unsynced offline actions
  Future<List<Map<String, dynamic>>> getUnsyncedActions({String? ppmTaskId}) async {
    return await _database.getPPMUnsyncedActions(ppmTaskId: ppmTaskId);
  }

  /// Sync offline actions to server
  Future<void> syncOfflineActions() async {
    debugPrint('PPMRepository.syncOfflineActions: Starting sync');
    final actions = await _database.getPPMUnsyncedActions();
    
    for (var action in actions) {
      try {
        if (action['action_type'] == 'start_time') {
          final actionData = json.decode(action['action_data']);
          
          // Create provider and call the API
          final provider = Provider(
            fetchURL: "/api/m_ppm.php",
          );
          
          await provider.post(
            url: "/api/m_ppm.php",
            body: {
              "action": "save_scan_start_time",
              "ppmTaskId": actionData['ppmTaskId'],
              "ppmGroupExecution": actionData['ppmGroupExecution'],
              "startTime": action['timestamp'], // Send actual offline start time
            },
          );
          
          // Mark as synced
          await _database.markPPMActionSynced(action['id']);
          debugPrint('PPMRepository.syncOfflineActions: Synced action ${action['id']} with timestamp ${action['timestamp']}');
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
}

