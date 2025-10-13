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

enum WorkOrderDataSource { remote, cacheWarm, cacheFallback }

class WorkOrderListResult {
  const WorkOrderListResult({
    required this.items,
    required this.source,
  });

  final List<WorkOrderListItem> items;
  final WorkOrderDataSource source;
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

  Future<WorkOrderListResult> getWorkOrders({
    required WorkOrderListType type,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _database.getWorkOrdersByList(type.cacheKey);
      if (cached.isNotEmpty) {
        final items = _prioritizeOffline(
          cached.map(_entityToListItem).toList(),
        );
        return WorkOrderListResult(
          items: items,
          source: WorkOrderDataSource.cacheWarm,
        );
      }
    }

    try {
      final remote = await _fetchRemote(type);
      final entities = remote.map(_taskToEntity).toList();
      await _database.replaceWorkOrderList(type.cacheKey, entities);
      final refreshed = await _database.getWorkOrdersByList(type.cacheKey);
      final items = refreshed.map(_entityToListItem).toList();
      return WorkOrderListResult(
        items: items,
        source: WorkOrderDataSource.remote,
      );
    } catch (error) {
      final fallback = await _database.getWorkOrdersByList(type.cacheKey);
      if (fallback.isNotEmpty) {
        final items = _prioritizeOffline(
          fallback.map(_entityToListItem).toList(),
        );
        return WorkOrderListResult(
          items: items,
          source: WorkOrderDataSource.cacheFallback,
        );
      }
      rethrow;
    }
  }

  Future<WorkOrderListResult> refreshWorkOrders(WorkOrderListType type) async {
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

  List<WorkOrderListItem> _prioritizeOffline(List<WorkOrderListItem> source) {
    if (source.length <= 1) {
      return source;
    }

    final offline = <WorkOrderListItem>[];
    final online = <WorkOrderListItem>[];
    for (final item in source) {
      if (item.isOffline) {
        offline.add(item);
      } else {
        online.add(item);
      }
    }

    return <WorkOrderListItem>[...offline, ...online];
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
