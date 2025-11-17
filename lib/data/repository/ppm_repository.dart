import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:GEMS/data/local/entities/ppm_entities.dart';
import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/model/form.dart';
import 'package:GEMS/utils/network.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

enum PPMActionResult {
  success,
  queued, // Stored for offline sync
}

/// Sync progress information
class PPMSyncProgress {
  final int current;
  final int total;
  final String currentAction;
  final bool isComplete;
  final int successCount;
  final int failedCount;

  PPMSyncProgress({
    required this.current,
    required this.total,
    required this.currentAction,
    required this.isComplete,
    required this.successCount,
    required this.failedCount,
  });

  double get percentage => total > 0 ? (current / total) : 0.0;

  String get statusText => isComplete
      ? 'Sync complete: $successCount succeeded, $failedCount failed'
      : 'Syncing $current of $total: $currentAction';
}

class PPMRepository {
  final OfflineDatabase _database = OfflineDatabase.instance;
  final Uuid _uuid = const Uuid();
  DateTime Function() _clock = () => DateTime.now();
  
  // Sync progress stream
  final BehaviorSubject<PPMSyncProgress?> _syncProgress$ = BehaviorSubject<PPMSyncProgress?>.seeded(null);
  Stream<PPMSyncProgress?> get syncProgress$ => _syncProgress$.stream;

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
      
      // Update section status to "Completed" when queuing section-completion actions
      await _updateSectionStatusAfterQueue(ppmTaskId, action);
      
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
      await _updateSectionStatusAfterQueue(ppmTaskId, action);
      debugPrint('PPMRepository._sendOrQueue: Action queued due to SocketException');
      return PPMActionResult.queued;
    } on TimeoutException catch (e) {
      debugPrint('PPMRepository._sendOrQueue: TimeoutException caught: $e');
      await _queueAction(ppmTaskId, body);
      await _updateSectionStatusAfterQueue(ppmTaskId, action);
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
    
    // Ensure snapshot exists when first action is queued
    // This prevents "green but empty" state when syncs fail but actions are queued
    final snapshotExists = await loadSnapshot(ppmTaskId) != null;
    if (!snapshotExists) {
      debugPrint('PPMRepository._queueAction: No snapshot found, creating one to preserve current state...');
      try {
        await downloadSnapshot(ppmTaskId: ppmTaskId);
        debugPrint('PPMRepository._queueAction: Snapshot created successfully');
      } catch (err) {
        debugPrint('PPMRepository._queueAction: Failed to create snapshot (non-fatal): $err');
        // Continue queuing even if snapshot creation fails - action data is more important
      }
    }
    
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
        actionId: _uuid.v4(), // Generate UUID for batch sync tracking
      ),
    );
    
    debugPrint('PPMRepository._queueAction: Action queued successfully');
  }

  /// Update section status after queuing an action (mark as Completed)
  Future<void> _updateSectionStatusAfterQueue(String ppmTaskId, String action) async {
    debugPrint('');
    debugPrint('🔄 PPMRepository._updateSectionStatusAfterQueue');
    debugPrint('   Action: $action');
    
    // Map actions to their corresponding sections
    String? sectionName;
    var targetStatus = 'Completed';
    
    switch (action) {
      case 'check_ppm_parts':
      case 'add_ppm_parts':
        sectionName = 'E'; // Materials/Spare Parts
        break;
      case 'check_additional_report':
      case 'upload_additional_report':
        sectionName = 'F'; // Additional Reports
        break;
      case 'save_ppm_remark':
        sectionName = 'G'; // Remarks
        break;
      case 'upload_maintenance_image':
      case 'upload_ppm_maintenance_image':
      case 'save_image_desc':
      case 'save_ppm_images_description':
        sectionName = 'H'; // Images
        final hasRequiredImages = await _hasRequiredMaintenanceImages(ppmTaskId);
        targetStatus = hasRequiredImages ? 'Completed' : 'Pending';
        debugPrint('   📸 Section H coverage check -> Before/During/After present? $hasRequiredImages');
        break;
      case 'add_assistant':
      case 'remove_assistant':
      case 'save_assistant_list':
        sectionName = 'I'; // Add Technician
        debugPrint('   📍 Detected assistant action, will update Section I');
        break;
      case 'save_qualitative_tasks':
        sectionName = 'C'; // Qualitative Tasks
        break;
      case 'save_quantitative_tasks':
        sectionName = 'D'; // Quantitative Tasks
        break;
      case 'submit_ppm':
        debugPrint('   ⚠️ CRITICAL: Task completion action queued');
        debugPrint('   This should mark the entire PPM as pending completion.');
        return; // Don't update section status for task completion
      default:
        debugPrint('   ℹ️ No section mapping for action=$action');
    }
    
    if (sectionName != null) {
      debugPrint('   📍 Section: $sectionName');
      debugPrint('   🔄 Updating status to: $targetStatus');
      
      try {
        await _database.updatePPMSectionStatus(
          ppmTaskId: ppmTaskId,
          sectionName: sectionName,
          status: targetStatus,
        );
        
        debugPrint('   ✅ Section $sectionName status updated to $targetStatus');
        debugPrint('   ✓ Database update successful');
      } catch (err, stackTrace) {
        debugPrint('   ❌ Error updating status: $err');
        debugPrint('   Stack trace:');
        final stackLines = stackTrace.toString().split('\n');
        for (var i = 0; i < stackLines.length && i < 5; i++) {
          debugPrint('   ${stackLines[i]}');
        }
      }
    }
  }

  Future<void> _post(Map<String, dynamic> body) async {
    final action = body['action'];
    final ppmTaskId = body['ppmTaskId'];
    
    debugPrint('');
    debugPrint('📤 PPMRepository._post: Starting POST request');
    debugPrint('   Action: $action');
    debugPrint('   PPM Task ID: $ppmTaskId');
    
    // Log diagnostic info for image uploads
    if (action == 'upload_ppm_maintenance_image') {
      final base64Data = body['fileUpload[data]'];
      final sizeKB = base64Data != null ? (base64Data.length / 1024).toStringAsFixed(2) : '0';
      debugPrint('   Uploading PPM maintenance image: size=${sizeKB}KB');
    }
    
    // Log all body keys (not values for security)
    debugPrint('   Payload keys: ${body.keys.join(", ")}');
    
    // Special logging for critical actions
    if (action == 'submit_ppm') {
      debugPrint('   ⚠️ CRITICAL: Task completion action');
      debugPrint('   EndTime: ${body['endTime']}');
      debugPrint('   Checkpoint: ${body['checkpoint']}');
      debugPrint('   Result: ${body['result']}');
    } else if (action == 'save_assistant_list') {
      debugPrint('   👥 Section I completion (save_assistant_list)');
      debugPrint('   Endpoint: /api/ppm_v2.php/save_assistant_list/$ppmTaskId');
    } else if (action == 'add_assistant' || action == 'remove_assistant') {
      debugPrint('   Assistant ID: ${body['assistant']}');
    }
    
    if (action == 'save_assistant_list') {
      final provider = Provider(
        fetchURL: '/api/ppm_v2.php/save_assistant_list/',
        taskID: ppmTaskId?.toString(),
      );

      final startTime = DateTime.now();
      try {
        await provider.post(
          url: '/api/ppm_v2.php/save_assistant_list/$ppmTaskId',
          body: const {},
        );
        final duration = DateTime.now().difference(startTime).inMilliseconds;
        debugPrint('   ✅ save_assistant_list POST successful (${duration}ms)');
        debugPrint('');
        return;
      } catch (err) {
        final duration = DateTime.now().difference(startTime).inMilliseconds;
        debugPrint('   ❌ save_assistant_list POST failed after ${duration}ms');
        debugPrint('   Error: $err');
        debugPrint('');
        rethrow;
      }
    }

    // Convert all values to strings for HTTP compatibility
    final bodyAsStrings = body.map((key, value) {
      if (value == null) {
        return MapEntry(key, '');
      } else if (value is bool) {
        return MapEntry(key, value ? '1' : '0');
      } else if (value is num) {
        return MapEntry(key, value.toString());
      } else {
        return MapEntry(key, value.toString());
      }
    });
    
    final provider = Provider(
      taskID: ppmTaskId.toString(),
      fetchURL: '/api/m_ppm.php',
    );
    
    debugPrint('   🌐 Sending POST to /api/m_ppm.php...');
    final startTime = DateTime.now();
    
    try {
      await provider.post(
        url: '/api/m_ppm.php',
        body: bodyAsStrings,
      );
      
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('   ✅ POST successful (${duration}ms)');
      debugPrint('');
    } catch (err) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('   ❌ POST failed after ${duration}ms');
      debugPrint('   Error: $err');
      debugPrint('');
      rethrow;
    }
  }

  /// Syncs ALL PPM actions in the correct order:
  /// 1. Start times (from ppm_offline_actions)
  /// 2. All other actions (from ppm_pending_actions)
  /// 
  /// This ensures backend receives actions in proper sequence,
  /// preventing "task not started" errors when trying to complete tasks.
  Future<void> syncAllPPMActions() async {
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('🔄 PPMRepository.syncAllPPMActions: Starting ORDERED sync...');
    debugPrint('═══════════════════════════════════════════════════════════════');
    
    try {
      // STEP 1: Sync start times first (critical for task initialization)
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ STEP 1: Syncing start times (ppm_offline_actions)...');
      debugPrint('└─────────────────────────────────────────────────────────────');
      
      await syncOfflineActions();
      
      debugPrint('✓ STEP 1 complete: Start times synced');
      
      // Small delay to ensure backend processes start times
      await Future.delayed(Duration(milliseconds: 500));
      
      // STEP 2: Sync all other actions (sections, complete, etc.)
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ STEP 2: Syncing pending actions (ppm_pending_actions)...');
      debugPrint('└─────────────────────────────────────────────────────────────');
      
      await syncPendingActions();
      
      debugPrint('✓ STEP 2 complete: Pending actions synced');
      
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════════');
      debugPrint('✓ PPMRepository.syncAllPPMActions: ORDERED sync complete!');
      debugPrint('═══════════════════════════════════════════════════════════════');
      
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════════');
      debugPrint('❌ PPMRepository.syncAllPPMActions: ORDERED sync failed!');
      debugPrint('Error: $e');
      debugPrint('Stack trace:');
      debugPrint('$stackTrace');
      debugPrint('═══════════════════════════════════════════════════════════════');
      
      // Clear progress on error
      _syncProgress$.add(null);
      
      rethrow;
    }
  }

  Future<void> syncPendingActions() async {
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('🔄 PPMRepository.syncPendingActions: Starting sequential sync...');
    debugPrint('═══════════════════════════════════════════════════════════════');
    
    final allPending = await _database.getPPMPendingActions();
    if (allPending.isEmpty) {
      debugPrint('✓ PPMRepository.syncPendingActions: No pending actions to sync');
      _syncProgress$.add(null); // Clear progress when no actions
      return;
    }

    debugPrint('📋 PPMRepository.syncPendingActions: Found ${allPending.length} pending actions');
    
    // CRITICAL: Separate submit_ppm actions (task completion) from others
    // submit_ppm MUST be synced LAST to ensure sections are completed first
    final regularActions = allPending.where((a) => a.action != 'submit_ppm').toList();
    final completionActions = allPending.where((a) => a.action == 'submit_ppm').toList();
    
    debugPrint('   📊 Regular actions: ${regularActions.length}');
    debugPrint('   🏁 Completion actions (submit_ppm): ${completionActions.length}');
    debugPrint('   🔄 Sync order: Regular actions first, then completions');
    
    // Combine in correct order: regular actions first, completions last
    final pending = [...regularActions, ...completionActions];
    
    var successCount = 0;
    var failedCount = 0;
    var currentIndex = 0;
    
    try {
      // Process each action sequentially (original approach)
      for (final action in pending) {
        currentIndex++;
        
        // Emit progress update
        _syncProgress$.add(PPMSyncProgress(
          current: currentIndex,
          total: pending.length,
          currentAction: _getActionDisplayName(action.action),
          isComplete: false,
          successCount: successCount,
          failedCount: failedCount,
        ));
        
        debugPrint('');
        debugPrint('┌─────────────────────────────────────────────────────────────');
        debugPrint('│ 🔄 SYNC ATTEMPT [$currentIndex/${pending.length}]');
        debugPrint('│ Action: ${action.action}');
        debugPrint('│ Action ID: ${action.id}');
        debugPrint('│ PPM Task: ${action.ppmTaskId}');
        debugPrint('│ Created: ${action.createdAt}');
        debugPrint('│ Batch ID: ${action.actionId}');
        debugPrint('│');
        debugPrint('│ 📦 Full Payload:');
        debugPrint('│ ${action.payloadJson}');
        debugPrint('└─────────────────────────────────────────────────────────────');
        
        try {
          debugPrint('');
          debugPrint('   🔍 Parsing payload...');
          // Parse the original payload
          final payload = json.decode(action.payloadJson) as Map<String, dynamic>;
          debugPrint('   ✓ Payload parsed successfully');
          debugPrint('   Keys: ${payload.keys.join(", ")}');
          
          // Validate critical fields
          if (action.action == 'submit_ppm') {
            debugPrint('');
            debugPrint('   ⚠️ VALIDATING TASK COMPLETION:');
            debugPrint('   - ppmTaskId: ${payload['ppmTaskId']}');
            debugPrint('   - endTime: ${payload['endTime']}');
            debugPrint('   - checkpoint: ${payload['checkpoint']}');
            debugPrint('   - result: ${payload['result']}');
            
            if (payload['endTime'] == null || payload['endTime'].toString().isEmpty) {
              debugPrint('   ❌ ERROR: Missing endTime in submit_ppm payload!');
            }
          } else if (action.action == 'add_assistant' || action.action == 'remove_assistant') {
            debugPrint('');
            debugPrint('   👤 ASSISTANT ACTION:');
            debugPrint('   - ppmTaskId: ${payload['ppmTaskId']}');
            debugPrint('   - assistant: ${payload['assistant']}');
            
            if (payload['assistant'] == null || payload['assistant'].toString().isEmpty) {
              debugPrint('   ❌ ERROR: Missing assistant ID!');
            }
          }
          
          debugPrint('');
          // Send to original endpoint
          await _post(payload);
          
          debugPrint('   🗑️ Removing from pending queue...');
          // Remove from queue on success
          if (action.id != null) {
            await _database.removePPMPendingAction(action.id!);
            successCount++;
            debugPrint('   ✅ Action synced and removed from queue');
            debugPrint('   📊 Current success: $successCount, failed: $failedCount');
          } else {
            debugPrint('   ⚠️ Warning: Action has no ID, cannot remove from queue');
          }
          
        } catch (err, stackTrace) {
          failedCount++;
          debugPrint('');
          debugPrint('   ❌❌❌ SYNC FAILED ❌❌❌');
          debugPrint('   Error Type: ${err.runtimeType}');
          debugPrint('   Error Message: $err');
          debugPrint('');
          debugPrint('   📚 Stack Trace:');
          final stackLines = stackTrace.toString().split('\n');
          for (var i = 0; i < stackLines.length && i < 10; i++) {
            debugPrint('   ${stackLines[i]}');
          }
          debugPrint('');
          debugPrint('   🔄 Action will remain in queue for retry');
          debugPrint('   📊 Current success: $successCount, failed: $failedCount');
          // Don't remove from queue - will retry later
          // Continue with next action
        }
        
        debugPrint('');
        debugPrint('═══════════════════════════════════════════════════════════════');
      }
      
      // Emit final progress
      _syncProgress$.add(PPMSyncProgress(
        current: pending.length,
        total: pending.length,
        currentAction: 'Complete',
        isComplete: true,
        successCount: successCount,
        failedCount: failedCount,
      ));
      
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════════');
      debugPrint('📊 FINAL SYNC SUMMARY');
      debugPrint('═══════════════════════════════════════════════════════════════');
      debugPrint('   ✅ Success: $successCount actions');
      debugPrint('   ❌ Failed: $failedCount actions');
      debugPrint('   📝 Total: ${pending.length} actions');
      debugPrint('   📈 Success Rate: ${pending.length > 0 ? ((successCount / pending.length) * 100).toStringAsFixed(1) : '0'}%');
      debugPrint('═══════════════════════════════════════════════════════════════');
      
      // Log remaining pending actions if any failed
      if (failedCount > 0) {
        debugPrint('');
        debugPrint('⚠️ FAILED ACTIONS REMAINING IN QUEUE:');
        final remainingActions = await _database.getPPMPendingActions();
        for (var i = 0; i < remainingActions.length && i < 5; i++) {
          final act = remainingActions[i];
          debugPrint('   ${i + 1}. ${act.action} (ID: ${act.id}, Task: ${act.ppmTaskId})');
        }
        if (remainingActions.length > 5) {
          debugPrint('   ... and ${remainingActions.length - 5} more');
        }
        debugPrint('');
      }
      
      // Clear progress after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        _syncProgress$.add(null);
      });
    } catch (err, st) {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════════');
      debugPrint('❌❌❌ FATAL SYNC ERROR ❌❌❌');
      debugPrint('═══════════════════════════════════════════════════════════════');
      debugPrint('   Error Type: ${err.runtimeType}');
      debugPrint('   Error: $err');
      debugPrint('');
      debugPrint('   Stack Trace:');
      debugPrint('$st');
      debugPrint('═══════════════════════════════════════════════════════════════');
      
      // Clear progress on fatal error
      _syncProgress$.add(null);
      rethrow;
    }
  }

  /// Get the count of pending actions for a specific task or all tasks
  Future<int> getPendingActionCount({String? ppmTaskId}) async {
    return await _database.getPPMPendingActionCount(ppmTaskId: ppmTaskId);
  }

  /// Get list of pending actions for a specific task or all tasks
  Future<List<PPMPendingActionEntity>> getPendingActions({String? ppmTaskId}) async {
    return await _database.getPPMPendingActions(ppmTaskId: ppmTaskId);
  }

  Future<bool> _hasRequiredMaintenanceImages(String ppmTaskId) async {
    const required = {'Before', 'During', 'After'};
    final present = <String>{};

    try {
      final cached = await _database.getPPMMaintenanceImages(ppmTaskId);
      for (final entity in cached) {
        final normalized = _normalizeMaintenanceUploadType(entity.uploadType);
        if (normalized.isNotEmpty) {
          present.add(normalized);
        }
      }
    } catch (err) {
      debugPrint('   ⚠️ Unable to read cached maintenance images: $err');
    }

    try {
      final pending = await _database.getPPMPendingActions(ppmTaskId: ppmTaskId);
      for (final action in pending) {
        if (action.action == 'upload_maintenance_image' ||
            action.action == 'upload_ppm_maintenance_image') {
          try {
            final payload = json.decode(action.payloadJson) as Map<String, dynamic>;
            final type = _normalizeMaintenanceUploadType(payload['uploadType']?.toString() ?? '');
            if (type.isNotEmpty) {
              present.add(type);
            }
          } catch (err) {
            debugPrint('   ⚠️ Failed to parse maintenance image payload: $err');
          }
        }
      }
    } catch (err) {
      debugPrint('   ⚠️ Unable to read pending maintenance images: $err');
    }

    debugPrint('   📊 Section H available image types: ${present.join(", ")}');
    return required.every(present.contains);
  }

  String _normalizeMaintenanceUploadType(String rawType) {
    final trimmed = rawType.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final lower = trimmed.toLowerCase();
    if (lower == 'before' || lower == 'during' || lower == 'after') {
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }

    final numeric = int.tryParse(lower);
    if (numeric != null) {
      switch (numeric) {
        case 0:
          return 'Before';
        case 1:
          return 'During';
        case 2:
          return 'After';
        case 3:
          return 'During';
        case 4:
          return 'After';
      }
    }

    return trimmed;
  }

  /// Get user-friendly display name for action
  String _getActionDisplayName(String action) {
    switch (action) {
      case 'save_qualitative_tasks':
        return 'Saving qualitative tasks';
      case 'save_quantitative_tasks':
        return 'Saving quantitative tasks';
      case 'check_ppm_parts':
        return 'Checking materials';
      case 'add_ppm_parts':
        return 'Adding material';
      case 'check_additional_report':
        return 'Checking additional report';
      case 'upload_additional_report':
        return 'Uploading report';
      case 'save_ppm_remark':
        return 'Saving remarks';
      case 'upload_maintenance_image':
      case 'upload_ppm_maintenance_image':
        return 'Uploading image';
      case 'save_image_desc':
      case 'save_ppm_images_description':
        return 'Saving image descriptions';
      case 'add_assistant':
        return 'Adding technician';
      case 'remove_assistant':
        return 'Removing technician';
      case 'save_assistant_list':
        return 'Confirming technician list';
      case 'submit_ppm':
        return 'Completing task';
      default:
        return action.replaceAll('_', ' ');
    }
  }

  void dispose() {
    _syncProgress$.close();
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
  // BATCH SYNC HELPER METHODS (REMOVED - Reverted to sequential sync)
  // ============================================================================
  //
  // The following methods were part of the batch sync implementation that has 
  // been reverted back to sequential individual API calls:
  // - _formatMySQLDateTime()
  // - _transformPayload()
  // - _transformQualitativeTasks() through _transformCheckAdditionalReport()
  // - _mapResultToCode()
  // - _transformCheckPPMParts()
  //
  // These methods are preserved in git history (commit before this change).
  // Reason for revert: Backend deployment delays + complexity not worth the benefit.
  //
  // If batch sync is needed again in the future, restore from git history:
  // git log --oneline --all --grep="batch sync"
  // git checkout <commit-hash> -- lib/data/repository/ppm_repository.dart
  // ============================================================================

  // ============================================================================
  // OFFLINE MODE MANAGEMENT
  // ============================================================================

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
      // Disable offline mode: sync pending actions first, then cleanup
      debugPrint('PPMRepository.setOfflineMode: Disabling offline mode, checking for pending actions...');
      
      // Check if there are pending actions to sync
      final pendingActions = await _database.getPPMPendingActions(ppmTaskId: ppmTaskId);
      
      if (pendingActions.isNotEmpty) {
        debugPrint('PPMRepository.setOfflineMode: Found ${pendingActions.length} pending actions, syncing before cleanup...');
        try {
          // Attempt to sync pending actions
          await syncPendingActions();
          debugPrint('PPMRepository.setOfflineMode: Sync completed successfully');
        } catch (err, st) {
          debugPrint('PPMRepository.setOfflineMode: Sync failed, keeping pending actions: $err\n$st');
          // Don't rethrow - allow user to disable offline mode even if sync fails
          // Pending actions will remain in queue for later retry
        }
      } else {
        debugPrint('PPMRepository.setOfflineMode: No pending actions to sync');
      }
      
      // Disable offline mode and cleanup
      await _database.setPPMOfflineMode(ppmTaskId, false);
      await _database.deletePPMSnapshot(ppmTaskId);
      // Clear task started status when disabling offline mode
      await _database.setPPMTaskStarted(ppmTaskId, false);
      
      debugPrint('PPMRepository.setOfflineMode: Offline mode disabled successfully');
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
      // Load existing section A data - returns already decoded Map
      final sectionDataMap = await loadSectionData(ppmTaskId, 'A');
      
      if (sectionDataMap != null) {
        // sectionDataMap is already a Map, no need to decode again
        final sectionData = sectionDataMap is Map<String, dynamic> 
            ? sectionDataMap 
            : (json.decode(sectionDataMap) as Map<String, dynamic>);
        
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

  /// Update Section A (Task Info) end time in local cache after task completion
  Future<void> updateSectionAEndTime({
    required String ppmTaskId,
    required String endTime,
  }) async {
    debugPrint('');
    debugPrint('💾 PPMRepository.updateSectionAEndTime');
    debugPrint('   PPM Task ID: $ppmTaskId');
    debugPrint('   End Time: $endTime');
    
    try {
      // Load existing section A data
      debugPrint('   🔍 Loading cached Section A...');
      final sectionDataMap = await loadSectionData(ppmTaskId, 'A');
      
      if (sectionDataMap != null) {
        debugPrint('   ✓ Section A found in cache');
        
        final sectionData = sectionDataMap is Map<String, dynamic> 
            ? sectionDataMap 
            : (json.decode(sectionDataMap) as Map<String, dynamic>);
        
        debugPrint('   📦 Current section data keys: ${sectionData.keys.join(", ")}');
        
        // Check if start time exists
        if (sectionData['ppmTaskTimeReceive'] == null || 
            sectionData['ppmTaskTimeReceive'].toString().isEmpty) {
          debugPrint('   ⚠️ WARNING: PM Start Date/Time (ppmTaskTimeReceive) is missing!');
        } else {
          debugPrint('   ✓ PM Start Date/Time exists: ${sectionData['ppmTaskTimeReceive']}');
        }
        
        // Update the ppmTaskTimeServiced field (this is the "PM End Date/Time" field)
        debugPrint('   ✏️ Setting ppmTaskTimeServiced = $endTime');
        sectionData['ppmTaskTimeServiced'] = endTime;
        
        // Save back to cache
        debugPrint('   💾 Saving to database...');
        await _database.savePPMSectionData(
          ppmTaskId: ppmTaskId,
          sectionName: 'A',
          sectionData: json.encode(sectionData),
        );
        
        debugPrint('   ✅ Section A cache updated successfully');
        debugPrint('   PM End Date/Time now set to: $endTime');
        
        // Verify the update
        final verifyData = await loadSectionData(ppmTaskId, 'A');
        if (verifyData != null) {
          final verifyJson = verifyData is Map<String, dynamic> ? verifyData : json.decode(verifyData);
          if (verifyJson['ppmTaskTimeServiced'] == endTime) {
            debugPrint('   ✓ VERIFICATION PASSED: End time persisted correctly');
          } else {
            debugPrint('   ❌ VERIFICATION FAILED: End time not persisted!');
            debugPrint('   Expected: $endTime');
            debugPrint('   Got: ${verifyJson['ppmTaskTimeServiced']}');
          }
        }
      } else {
        debugPrint('   ⚠️ WARNING: No Section A cache found!');
        debugPrint('   This means snapshot was never downloaded or was cleared.');
      }
    } catch (err, st) {
      debugPrint('   ❌ Error updating Section A end time: $err');
      debugPrint('   Stack trace: $st');
      // Don't rethrow - this is a cache update, shouldn't block task completion
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
            "startTime": startTime, // Backend expects startTime field (confirmed by backend team)
          };
          
          debugPrint('╔════════════════════════════════════════════════════════════════');
          debugPrint('║ 🔄 SYNCING TO API: /api/m_ppm.php');
          debugPrint('╠════════════════════════════════════════════════════════════════');
          debugPrint('║ Request Body:');
          debugPrint('║   action: ${requestBody['action']}');
          debugPrint('║   ppmTaskId: ${requestBody['ppmTaskId']}');
          debugPrint('║   ppmGroupExecution: ${requestBody['ppmGroupExecution']}');
          debugPrint('║   startTime: ${requestBody['startTime']}');
          debugPrint('╠════════════════════════════════════════════════════════════════');
          debugPrint('║ Note: startTime is the OFFLINE start time, not sync time');
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

  /// Add technician assistant - with offline support
  Future<PPMActionResult> addTechnicianAssistant({
    required String ppmTaskId,
    required String userId,
  }) async {
    debugPrint('PPMRepository.addTechnicianAssistant: Adding assistant $userId to task $ppmTaskId');
    
    final body = <String, String>{
      'action': 'add_assistant',
      'ppmTaskId': ppmTaskId,
      'assistant': userId,
    };

    final result = await _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: body,
    );

    // If queued (offline mode), update the cache so user can see their changes
    if (result == PPMActionResult.queued) {
      debugPrint('PPMRepository.addTechnicianAssistant: Action queued, updating cache');
      await _updateSelectedTechniciansCache(ppmTaskId: ppmTaskId, userId: userId, isAdd: true);
    }

    return result;
  }

  /// Remove technician assistant - with offline support
  Future<PPMActionResult> removeTechnicianAssistant({
    required String ppmTaskId,
    required String userId,
  }) async {
    debugPrint('PPMRepository.removeTechnicianAssistant: Removing assistant $userId from task $ppmTaskId');
    
    final body = <String, String>{
      'action': 'remove_assistant',
      'ppmTaskId': ppmTaskId,
      'assistant': userId,
    };

    final result = await _sendOrQueue(
      ppmTaskId: ppmTaskId,
      body: body,
    );

    // If queued (offline mode), update the cache so user can see their changes
    if (result == PPMActionResult.queued) {
      debugPrint('PPMRepository.removeTechnicianAssistant: Action queued, updating cache');
      await _updateSelectedTechniciansCache(ppmTaskId: ppmTaskId, userId: userId, isAdd: false);
    }

    return result;
  }

  /// Submit the assistant list (even when empty) to mark Section I as completed
  Future<PPMActionResult> submitAssistantList({
    required String ppmTaskId,
  }) async {
    debugPrint('PPMRepository.submitAssistantList: Submitting assistant list for task $ppmTaskId');

    final body = <String, String>{
      'action': 'save_assistant_list',
      'ppmTaskId': ppmTaskId,
    };

    try {
      final result = await _sendOrQueue(
        ppmTaskId: ppmTaskId,
        body: body,
      );

      if (result == PPMActionResult.success) {
        debugPrint('PPMRepository.submitAssistantList: Assistant list submitted successfully');
        await _database.updatePPMSectionStatus(
          ppmTaskId: ppmTaskId,
          sectionName: 'I',
          status: 'Completed',
        );
      } else {
        debugPrint('PPMRepository.submitAssistantList: Assistant list queued for sync');
      }

      return result;
    } catch (err) {
      debugPrint('PPMRepository.submitAssistantList: Failed to submit assistant list: $err');
      rethrow;
    }
  }

  /// Update cached selected technicians after add/remove
  Future<void> _updateSelectedTechniciansCache({
    required String ppmTaskId,
    required String userId,
    required bool isAdd,
  }) async {
    try {
      final db = await _database.database;
      
      if (isAdd) {
        // Mark technician as selected
        await db.rawUpdate(
          'UPDATE ${_getPPMTechnicianCacheTableName()} SET is_selected = 1 WHERE ppm_task_id = ? AND user_id = ?',
          [ppmTaskId, userId],
        );
        debugPrint('PPMRepository._updateSelectedTechniciansCache: Marked $userId as selected');
      } else {
        // Mark technician as not selected
        await db.rawUpdate(
          'UPDATE ${_getPPMTechnicianCacheTableName()} SET is_selected = 0 WHERE ppm_task_id = ? AND user_id = ?',
          [ppmTaskId, userId],
        );
        debugPrint('PPMRepository._updateSelectedTechniciansCache: Unmarked $userId as selected');
      }
    } catch (err) {
      debugPrint('PPMRepository._updateSelectedTechniciansCache: Error updating cache: $err');
    }
  }

  /// Helper to get technician cache table name (private table, need to access it carefully)
  String _getPPMTechnicianCacheTableName() => 'ppm_technician_cache';

  /// Complete PPM task - records end time
  /// Returns PPMActionResult.success if online, PPMActionResult.queued if offline
  Future<PPMActionResult> completeTask({
    required String ppmTaskId,
    required DateTime endTime,
  }) async {
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('🏁 PPMRepository.completeTask');
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('   PPM Task ID: $ppmTaskId');
    debugPrint('   End Time: $endTime');

    final isOffline = await isOfflineModeEnabled(ppmTaskId);
    debugPrint('   Offline Mode: $isOffline');
    
    // Format endTime as MySQL datetime (YYYY-MM-DD HH:MM:SS)
    final formattedEndTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime);
    debugPrint('   Formatted End Time: $formattedEndTime');

    if (isOffline) {
      // Queue the complete action for offline sync
      debugPrint('   📦 Queuing task completion for offline sync...');
      
      final payload = {
        'action': 'submit_ppm',
        'ppmTaskId': ppmTaskId,
        'checkpoint': '1',
        'result': '1',
        'remark': '',  // Required by backend (can be empty string)
        'endTime': formattedEndTime,
      };
      
      debugPrint('   Payload: $payload');
      
      await _database.enqueuePPMPendingAction(
        PPMPendingActionEntity(
          ppmTaskId: ppmTaskId,
          action: 'submit_ppm',
          payloadJson: json.encode(payload),
          createdAt: DateTime.now(),
          actionId: _uuid.v4(),
        ),
      );
      
      debugPrint('   ✓ Task completion queued successfully');
      
      // Update Section A cache with end time
      debugPrint('   💾 Updating Section A cache with end time...');
      await updateSectionAEndTime(ppmTaskId: ppmTaskId, endTime: formattedEndTime);
      debugPrint('   ✓ Section A cache updated');
      
      debugPrint('   ✅ OFFLINE COMPLETION SUCCESSFUL');
      debugPrint('═══════════════════════════════════════════════════════════════');
      return PPMActionResult.queued;
    }

    // Online - call API directly
    debugPrint('   🌐 Online mode - calling API directly...');
    try {
      final provider = Provider(
        taskID: ppmTaskId,
        fetchURL: '/api/m_ppm.php',
      );

      final body = {
        'action': 'submit_ppm',
        'ppmTaskId': ppmTaskId,
        'checkpoint': '1',
        'result': '1',
        'remark': '',  // Required by backend (can be empty string)
        'endTime': formattedEndTime,
      };

      debugPrint('   Request body: $body');
      final response = await provider.post(url: '/api/m_ppm.php', body: body);
      debugPrint('   API Response: $response');
      debugPrint('   ✅ ONLINE COMPLETION SUCCESSFUL');
      debugPrint('═══════════════════════════════════════════════════════════════');

      return PPMActionResult.success;
    } catch (err, st) {
      debugPrint('   ❌ API call failed: $err');
      debugPrint('   Stack: $st');
      debugPrint('═══════════════════════════════════════════════════════════════');
      rethrow;
    }
  }

  /// Queue complete task action for offline sync (called by completeTask when offline)
  Future<void> queueCompleteTask({
    required String ppmTaskId,
    required DateTime endTime,
  }) async {
    // Format endTime as MySQL datetime (YYYY-MM-DD HH:MM:SS)
    final formattedEndTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime);
    
    await _database.enqueuePPMPendingAction(
      PPMPendingActionEntity(
        ppmTaskId: ppmTaskId,
        action: 'submit_ppm',
        payloadJson: json.encode({
          'ppmTaskId': ppmTaskId,
          'checkpoint': '1',
          'result': '1',
          'endTime': formattedEndTime,
        }),
        createdAt: DateTime.now(),
        actionId: _uuid.v4(),
      ),
    );
  }

  /// Get pending actions count for a task
  Future<int> getPendingActionsCount(String ppmTaskId) async {
    return await _database.getPPMUnsyncedActionCount(ppmTaskId);
  }

  /// Get pending actions summary (grouped by section)
  Future<Map<String, int>> getPendingActionsSummary(String ppmTaskId) async {
    return await _database.getPPMPendingActionsSummary(ppmTaskId);
  }

  /// Set task started status (persists across app restarts)
  Future<void> setTaskStarted(String ppmTaskId, bool started) async {
    await _database.setPPMTaskStarted(ppmTaskId, started);
  }

  /// Check if task has been started (persists across app restarts)
  Future<bool> isTaskStarted(String ppmTaskId) async {
    return await _database.isPPMTaskStarted(ppmTaskId);
  }
}

