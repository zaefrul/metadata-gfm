import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const _dbName = 'gems_offline.db';
const _dbVersion = 2;

class OfflineDatabase {
  OfflineDatabase._();

  static final OfflineDatabase instance = OfflineDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      singleInstance: true,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_WorkOrderHeadersTable.createSql);
    await db.execute(_WorkOrderTasksTable.createSql);
    await db.execute(_WorkOrderChecklistTable.createSql);
    await db.execute(_WorkOrderAttachmentsTable.createSql);
    await db.execute(_ReferenceDataTable.createSql);
    await db.execute(_WorkOrderListTable.createSql);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == newVersion) return;
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${_WorkOrderHeadersTable.tableName} ADD COLUMN raw_payload TEXT',
      ).catchError((_) => null);
      await db.execute(_WorkOrderListTable.createSql);
    }
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(_WorkOrderAttachmentsTable.tableName);
      await txn.delete(_WorkOrderChecklistTable.tableName);
      await txn.delete(_WorkOrderTasksTable.tableName);
      await txn.delete(_WorkOrderHeadersTable.tableName);
      await txn.delete(_ReferenceDataTable.tableName);
      await txn.delete(_WorkOrderListTable.tableName);
    });
  }

  Future<void> clearWorkOrderData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(_WorkOrderAttachmentsTable.tableName);
      await txn.delete(_WorkOrderChecklistTable.tableName);
      await txn.delete(_WorkOrderTasksTable.tableName);
      await txn.delete(_WorkOrderListTable.tableName);
      await txn.delete(_WorkOrderHeadersTable.tableName);
    });
  }

  Future<void> replaceWorkOrderList(
    String listType,
    List<WorkOrderHeaderEntity> headers,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        _WorkOrderListTable.tableName,
        where: 'list_type = ?',
        whereArgs: [listType],
      );

      final batch = txn.batch();
      for (final header in headers) {
        batch.insert(
          _WorkOrderHeadersTable.tableName,
          header.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        batch.insert(
          _WorkOrderListTable.tableName,
          {
            'work_order_id': header.workOrderId,
            'list_type': listType,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);

      await txn.delete(
        _WorkOrderHeadersTable.tableName,
        where:
            'work_order_id NOT IN (SELECT work_order_id FROM ${_WorkOrderListTable.tableName})',
      );
    });
  }

  Future<List<WorkOrderHeaderEntity>> getWorkOrdersByList(
    String listType,
  ) async {
    final db = await database;
    final result = await db.rawQuery('''
SELECT h.* FROM ${_WorkOrderHeadersTable.tableName} h
INNER JOIN ${_WorkOrderListTable.tableName} l ON h.work_order_id = l.work_order_id
WHERE l.list_type = ?
ORDER BY h.scheduled_start DESC, h.work_order_number DESC
''', [listType]);
    return result.map((row) => WorkOrderHeaderEntity.fromMap(row)).toList();
  }

  Future<void> close() async {
    if (_database == null) return;
    await _database!.close();
    _database = null;
  }
}

@immutable
class WorkOrderHeaderEntity {
  const WorkOrderHeaderEntity({
    required this.workOrderId,
    this.workOrderNumber,
    this.title,
    this.status,
    this.priority,
    this.site,
    this.assetCode,
    this.scheduledStart,
    this.scheduledEnd,
    this.lastSyncedAt,
    this.rawJson,
    this.isDownloaded = true,
  });

  final String workOrderId;
  final String? workOrderNumber;
  final String? title;
  final String? status;
  final String? priority;
  final String? site;
  final String? assetCode;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final DateTime? lastSyncedAt;
  final String? rawJson;
  final bool isDownloaded;

  WorkOrderHeaderEntity copyWith({
    String? workOrderNumber,
    String? title,
    String? status,
    String? priority,
    String? site,
    String? assetCode,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    DateTime? lastSyncedAt,
    String? rawJson,
    bool? isDownloaded,
  }) {
    return WorkOrderHeaderEntity(
      workOrderId: workOrderId,
      workOrderNumber: workOrderNumber ?? this.workOrderNumber,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      site: site ?? this.site,
      assetCode: assetCode ?? this.assetCode,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rawJson: rawJson ?? this.rawJson,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'work_order_id': workOrderId,
      'work_order_number': workOrderNumber,
      'title': title,
      'status': status,
      'priority': priority,
      'site': site,
      'asset_code': assetCode,
      'scheduled_start': scheduledStart?.toIso8601String(),
      'scheduled_end': scheduledEnd?.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'raw_payload': rawJson,
      'is_downloaded': isDownloaded ? 1 : 0,
    };
  }

  factory WorkOrderHeaderEntity.fromMap(Map<String, Object?> map) {
    return WorkOrderHeaderEntity(
      workOrderId: map['work_order_id'] as String,
      workOrderNumber: map['work_order_number'] as String?,
      title: map['title'] as String?,
      status: map['status'] as String?,
      priority: map['priority'] as String?,
      site: map['site'] as String?,
      assetCode: map['asset_code'] as String?,
      scheduledStart: _parseDate(map['scheduled_start']),
      scheduledEnd: _parseDate(map['scheduled_end']),
      lastSyncedAt: _parseDate(map['last_synced_at']),
      rawJson: map['raw_payload'] as String?,
      isDownloaded: (map['is_downloaded'] as int? ?? 1) == 1,
    );
  }
}

class _WorkOrderListTable {
  static const tableName = 'work_order_list_entries';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  work_order_id TEXT NOT NULL,
  list_type TEXT NOT NULL,
  PRIMARY KEY(work_order_id, list_type),
  FOREIGN KEY(work_order_id) REFERENCES ${_WorkOrderHeadersTable.tableName}(work_order_id) ON DELETE CASCADE
)
''';
}

@immutable
class WorkOrderTaskEntity {
  const WorkOrderTaskEntity({
    required this.taskId,
    required this.workOrderId,
    this.title,
    this.description,
    this.status,
    this.technicianId,
    this.startedAt,
    this.completedAt,
    this.lastSyncedAt,
  });

  final String taskId;
  final String workOrderId;
  final String? title;
  final String? description;
  final String? status;
  final String? technicianId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastSyncedAt;

  Map<String, Object?> toMap() {
    return {
      'task_id': taskId,
      'work_order_id': workOrderId,
      'title': title,
      'description': description,
      'status': status,
      'technician_id': technicianId,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  factory WorkOrderTaskEntity.fromMap(Map<String, Object?> map) {
    return WorkOrderTaskEntity(
      taskId: map['task_id'] as String,
      workOrderId: map['work_order_id'] as String,
      title: map['title'] as String?,
      description: map['description'] as String?,
      status: map['status'] as String?,
      technicianId: map['technician_id'] as String?,
      startedAt: _parseDate(map['started_at']),
      completedAt: _parseDate(map['completed_at']),
      lastSyncedAt: _parseDate(map['last_synced_at']),
    );
  }
}

@immutable
class WorkOrderChecklistItemEntity {
  const WorkOrderChecklistItemEntity({
    required this.checklistId,
    required this.taskId,
    this.description,
    this.isCompleted = false,
    this.remarks,
    this.lastUpdatedAt,
  });

  final String checklistId;
  final String taskId;
  final String? description;
  final bool isCompleted;
  final String? remarks;
  final DateTime? lastUpdatedAt;

  Map<String, Object?> toMap() {
    return {
      'checklist_id': checklistId,
      'task_id': taskId,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'remarks': remarks,
      'last_updated_at': lastUpdatedAt?.toIso8601String(),
    };
  }

  factory WorkOrderChecklistItemEntity.fromMap(Map<String, Object?> map) {
    return WorkOrderChecklistItemEntity(
      checklistId: map['checklist_id'] as String,
      taskId: map['task_id'] as String,
      description: map['description'] as String?,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      remarks: map['remarks'] as String?,
      lastUpdatedAt: _parseDate(map['last_updated_at']),
    );
  }
}

@immutable
class WorkOrderAttachmentEntity {
  const WorkOrderAttachmentEntity({
    required this.attachmentId,
    required this.workOrderId,
    this.taskId,
    this.fileName,
    this.remoteUrl,
    this.localPath,
    this.capturedAt,
    this.lastSyncedAt,
  });

  final String attachmentId;
  final String workOrderId;
  final String? taskId;
  final String? fileName;
  final String? remoteUrl;
  final String? localPath;
  final DateTime? capturedAt;
  final DateTime? lastSyncedAt;

  Map<String, Object?> toMap() {
    return {
      'attachment_id': attachmentId,
      'work_order_id': workOrderId,
      'task_id': taskId,
      'file_name': fileName,
      'remote_url': remoteUrl,
      'local_path': localPath,
      'captured_at': capturedAt?.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  factory WorkOrderAttachmentEntity.fromMap(Map<String, Object?> map) {
    return WorkOrderAttachmentEntity(
      attachmentId: map['attachment_id'] as String,
      workOrderId: map['work_order_id'] as String,
      taskId: map['task_id'] as String?,
      fileName: map['file_name'] as String?,
      remoteUrl: map['remote_url'] as String?,
      localPath: map['local_path'] as String?,
      capturedAt: _parseDate(map['captured_at']),
      lastSyncedAt: _parseDate(map['last_synced_at']),
    );
  }
}

@immutable
class ReferenceDataEntity {
  const ReferenceDataEntity({
    required this.referenceId,
    required this.category,
    this.code,
    this.label,
    this.updatedAt,
    this.extraJson,
  });

  final String referenceId;
  final String category;
  final String? code;
  final String? label;
  final DateTime? updatedAt;
  final String? extraJson;

  Map<String, Object?> toMap() {
    return {
      'reference_id': referenceId,
      'category': category,
      'code': code,
      'label': label,
      'updated_at': updatedAt?.toIso8601String(),
      'extra_json': extraJson,
    };
  }

  factory ReferenceDataEntity.fromMap(Map<String, Object?> map) {
    return ReferenceDataEntity(
      referenceId: map['reference_id'] as String,
      category: map['category'] as String,
      code: map['code'] as String?,
      label: map['label'] as String?,
      updatedAt: _parseDate(map['updated_at']),
      extraJson: map['extra_json'] as String?,
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

class _WorkOrderHeadersTable {
  static const tableName = 'work_order_headers';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  work_order_id TEXT PRIMARY KEY,
  work_order_number TEXT,
  title TEXT,
  status TEXT,
  priority TEXT,
  site TEXT,
  asset_code TEXT,
  scheduled_start TEXT,
  scheduled_end TEXT,
  last_synced_at TEXT,
  is_downloaded INTEGER NOT NULL DEFAULT 1
)
''';
}

class _WorkOrderTasksTable {
  static const tableName = 'work_order_tasks';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  task_id TEXT PRIMARY KEY,
  work_order_id TEXT NOT NULL,
  title TEXT,
  description TEXT,
  status TEXT,
  technician_id TEXT,
  started_at TEXT,
  completed_at TEXT,
  last_synced_at TEXT,
  FOREIGN KEY(work_order_id) REFERENCES ${_WorkOrderHeadersTable.tableName}(work_order_id) ON DELETE CASCADE
)
''';
}

class _WorkOrderChecklistTable {
  static const tableName = 'work_order_checklists';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  checklist_id TEXT PRIMARY KEY,
  task_id TEXT NOT NULL,
  description TEXT,
  is_completed INTEGER NOT NULL DEFAULT 0,
  remarks TEXT,
  last_updated_at TEXT,
  FOREIGN KEY(task_id) REFERENCES ${_WorkOrderTasksTable.tableName}(task_id) ON DELETE CASCADE
)
''';
}

class _WorkOrderAttachmentsTable {
  static const tableName = 'work_order_attachments';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  attachment_id TEXT PRIMARY KEY,
  work_order_id TEXT NOT NULL,
  task_id TEXT,
  file_name TEXT,
  remote_url TEXT,
  local_path TEXT,
  captured_at TEXT,
  last_synced_at TEXT,
  FOREIGN KEY(work_order_id) REFERENCES ${_WorkOrderHeadersTable.tableName}(work_order_id) ON DELETE CASCADE
)
''';
}

class _ReferenceDataTable {
  static const tableName = 'reference_data';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  reference_id TEXT PRIMARY KEY,
  category TEXT NOT NULL,
  code TEXT,
  label TEXT,
  updated_at TEXT,
  extra_json TEXT
)
''';
}
