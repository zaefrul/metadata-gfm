import 'dart:async';
import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/utils/network.dart';
import 'package:flutter/foundation.dart';

class WorkOrderListItem {
  const WorkOrderListItem({
    required this.task,
    required this.isOffline,
  });

  final WorkOrderTask task;
  final bool isOffline;

  WorkOrderListItem copyWith({WorkOrderTask? task, bool? isOffline}) {
    return WorkOrderListItem(
      task: task ?? this.task,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

/// Lists available from the work order endpoint.
enum WorkOrderListType { submittedWo, pendingTask }

extension WorkOrderListTypeX on WorkOrderListType {
  String get _apiPath {
    switch (this) {
      case WorkOrderListType.submittedWo:
        return '/api/m_wo.php?type=submitted_wo';
      case WorkOrderListType.pendingTask:
        return '/api/m_wo.php?type=pending_task';
    }
  }

  String get cacheKey => name;
}

class WorkOrderRepository {
  WorkOrderRepository({OfflineDatabase? database})
      : _database = database ?? OfflineDatabase.instance;

  final OfflineDatabase _database;

  Future<List<WorkOrderListItem>> getWorkOrders({
    required WorkOrderListType type,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _database.getWorkOrdersByList(type.cacheKey);
      if (cached.isNotEmpty) {
        return cached.map(_entityToListItem).toList();
      }
    }

    try {
      final remote = await _fetchRemote(type);
      final entities = remote.map(_taskToEntity).toList();
      await _database.replaceWorkOrderList(type.cacheKey, entities);
      final refreshed = await _database.getWorkOrdersByList(type.cacheKey);
      return refreshed.map(_entityToListItem).toList();
    } catch (error) {
      final fallback = await _database.getWorkOrdersByList(type.cacheKey);
      if (fallback.isNotEmpty) {
        return fallback.map(_entityToListItem).toList();
      }
      rethrow;
    }
  }

  Future<List<WorkOrderListItem>> refreshWorkOrders(WorkOrderListType type) async {
    return getWorkOrders(type: type, forceRefresh: true);
  }

  Future<void> clearCache() => _database.clearWorkOrderData();

  Future<List<WorkOrderTask>> _fetchRemote(WorkOrderListType type) async {
    final provider = Provider(fetchURL: type._apiPath);
    final response = await provider.fetch();
    final remoteList =
        response.workorderTask?.toList() ?? const <WorkOrderTask>[];
    debugPrint('WorkOrderRepository: API returned ${remoteList.length} ${type.name} items');
    return List<WorkOrderTask>.from(remoteList);
  }

  WorkOrderHeaderEntity _taskToEntity(WorkOrderTask task) {
    DateTime? createdAt;
    try {
      createdAt = DateTime.tryParse(task.woTaskTimeCreated);
    } catch (_) {
      createdAt = null;
    }

    return WorkOrderHeaderEntity(
      workOrderId: task.woTaskId,
      workOrderNumber: task.woTaskNo,
      title: task.woTaskType,
      status: task.woTaskStatus,
      priority: task.woTaskSeverity,
      site: task.woTaskLocation,
      assetCode: task.woTaskTypeInit,
      scheduledStart: createdAt,
      lastSyncedAt: DateTime.now().toUtc(),
      rawJson: task.toJson(),
      isDownloaded: true,
    );
  }

  WorkOrderListItem _entityToListItem(WorkOrderHeaderEntity entity) {
    final task = _entityToTask(entity);
    return WorkOrderListItem(task: task, isOffline: entity.isOfflineMode);
  }

  WorkOrderTask _entityToTask(WorkOrderHeaderEntity entity) {
    if (entity.rawJson != null) {
      try {
        return WorkOrderTask.fromJson(entity.rawJson!);
      } catch (error, stackTrace) {
        debugPrint('Failed to decode cached work order: $error\n$stackTrace');
      }
    }

    return WorkOrderTask((builder) {
      builder
        ..woTaskId = entity.workOrderId
        ..woTaskNo = entity.workOrderNumber ?? ''
        ..woTaskLocation = entity.site ?? ''
        ..woTaskType = entity.title ?? ''
        ..woTaskTypeInit = entity.assetCode ?? ''
        ..reportedBy = ''
        ..woTaskTimeCreated = entity.scheduledStart?.toIso8601String() ?? ''
        ..woTaskStatus = entity.status ?? ''
        ..woTaskSeverity = entity.priority ?? '';
    });
  }
}
