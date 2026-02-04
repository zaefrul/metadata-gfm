import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';
import 'package:rxdart/rxdart.dart';

/// Controller for PPM pending sync operations.
/// 
/// Note: Each form creates its own instance, so the pending count is per-instance.
/// Call [refreshPendingCount] immediately after queuing actions to ensure
/// the banner shows up correctly.
class PPMPendingSyncController {
  final PPMRepository _repository;
  final OfflineDatabase _database;
  final BehaviorSubject<int> _pendingCount$;
  Timer? _periodicRetry;
  String? _ppmTaskId;

  PPMPendingSyncController({
    PPMRepository? repository,
    OfflineDatabase? database,
  })  : _repository = repository ?? PPMRepository(),
        _database = database ?? OfflineDatabase.instance,
        _pendingCount$ = BehaviorSubject<int>.seeded(0) {
    _startPeriodicRetry();
  }

  Stream<int> get pendingCount$ => _pendingCount$.stream;
  
  // Expose sync progress from repository
  Stream<PPMSyncProgress?> get syncProgress$ => _repository.syncProgress$;

  int get currentPendingCount => _pendingCount$.value;

  void setPPMTaskId(String? ppmTaskId) {
    _ppmTaskId = ppmTaskId;
    // Immediately refresh on set
    unawaited(_updatePendingCount());
  }

  void _startPeriodicRetry() {
    _periodicRetry = Timer.periodic(
      const Duration(seconds: 30),
      (_) => retry(),
    );
  }

  Future<void> retry() async {
    try {
      debugPrint('PPMPendingSyncController: Attempting ORDERED sync (start times → pending actions)...');
      await _repository.syncAllPPMActions();
      await _updatePendingCount();
      debugPrint('PPMPendingSyncController: ORDERED sync completed successfully');
    } catch (err, st) {
      debugPrint('PPMPendingSyncController: ORDERED sync failed: $err\n$st');
      // Still update pending count after failure so UI reflects current state
      await _updatePendingCount();
    }
  }

  /// Refresh the pending count immediately.
  /// Call this after queuing an action to ensure the banner updates promptly.
  Future<void> refreshPendingCount() async {
    await _updatePendingCount();
  }

  Future<void> _updatePendingCount() async {
    if (_ppmTaskId == null) {
      debugPrint('PPMPendingSyncController: No ppmTaskId set, skipping count update');
      return;
    }
    
    try {
      // Use the comprehensive count method that includes both tables
      final count = await _database.getPPMUnsyncedActionCount(_ppmTaskId!);
      _pendingCount$.add(count);
      debugPrint('PPMPendingSyncController: Updated pending count to $count for task $_ppmTaskId');
    } catch (err) {
      debugPrint('PPMPendingSyncController: Failed to update pending count: $err');
    }
  }

  void dispose() {
    _periodicRetry?.cancel();
    _pendingCount$.close();
  }
}
