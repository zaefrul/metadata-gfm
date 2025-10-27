import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';
import 'package:rxdart/rxdart.dart';

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

  int get currentPendingCount => _pendingCount$.value;

  void setPPMTaskId(String? ppmTaskId) {
    _ppmTaskId = ppmTaskId;
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
      debugPrint('PPMPendingSyncController: Attempting to sync pending actions...');
      await _repository.syncPendingActions();
      await _updatePendingCount();
      debugPrint('PPMPendingSyncController: Sync completed successfully');
    } catch (err, st) {
      debugPrint('PPMPendingSyncController: Sync failed: $err\n$st');
    }
  }

  Future<void> _updatePendingCount() async {
    try {
      final count = await _database.getPPMPendingActionCount(
        ppmTaskId: _ppmTaskId,
      );
      _pendingCount$.add(count);
      debugPrint('PPMPendingSyncController: Updated pending count to $count');
    } catch (err) {
      debugPrint('PPMPendingSyncController: Failed to update pending count: $err');
    }
  }

  void dispose() {
    _periodicRetry?.cancel();
    _pendingCount$.close();
  }
}
