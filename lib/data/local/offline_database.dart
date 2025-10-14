import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const _dbName = 'gems_offline.db';
const _dbVersion = 7;

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
    await db.execute(_WorkOrderSectionsTable.createSql);
    await db.execute(_WorkOrderExecutionTable.createSql);
    await db.execute(_WorkOrderPendingActionsTable.createSql);
    await db.execute(_WorkOrderComplaintDetailTable.createSql);
    await db.execute(_WorkOrderRepairImagesTable.createSql);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == newVersion) return;
    if (oldVersion < 2) {
      await db.execute(_WorkOrderListTable.createSql);
    }
    if (oldVersion < 3) {
      await db.execute(_WorkOrderSectionsTable.createSql);
      await db.execute(_WorkOrderExecutionTable.createSql);
      await db.execute(_WorkOrderPendingActionsTable.createSql);
    }
    if (oldVersion < 4) {
      await db
          .execute(
            'ALTER TABLE ${_WorkOrderHeadersTable.tableName} ADD COLUMN raw_payload TEXT',
          )
          .catchError((_) => null);
    }
    if (oldVersion < 5) {
      await db
          .execute(
            'ALTER TABLE ${_WorkOrderHeadersTable.tableName} ADD COLUMN offline_mode_enabled INTEGER NOT NULL DEFAULT 0',
          )
          .catchError((_) => null);
    }
    if (oldVersion < 6) {
      await db.execute(_WorkOrderComplaintDetailTable.createSql);
    }
    if (oldVersion < 7) {
      await db.execute(_WorkOrderRepairImagesTable.createSql);
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
      await txn.delete(_WorkOrderSectionsTable.tableName);
      await txn.delete(_WorkOrderExecutionTable.tableName);
      await txn.delete(_WorkOrderPendingActionsTable.tableName);
      await txn.delete(_WorkOrderComplaintDetailTable.tableName);
      await txn.delete(_WorkOrderRepairImagesTable.tableName);
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
      await txn.delete(_WorkOrderSectionsTable.tableName);
      await txn.delete(_WorkOrderExecutionTable.tableName);
      await txn.delete(_WorkOrderPendingActionsTable.tableName);
      await txn.delete(_WorkOrderComplaintDetailTable.tableName);
      await txn.delete(_WorkOrderRepairImagesTable.tableName);
    });
  }

  Future<void> replaceWorkOrderList(
    String listType,
    List<WorkOrderHeaderEntity> headers,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      // Preserve offline mode flags for headers we are about to upsert.
      final existingRows = await txn.query(
        _WorkOrderHeadersTable.tableName,
        columns: ['work_order_id', 'offline_mode_enabled'],
      );
      final offlineLookup = <String, bool>{
        for (final row in existingRows)
          if (row['work_order_id'] != null)
            row['work_order_id'] as String:
                (row['offline_mode_enabled'] as int? ?? 0) == 1,
      };

      await txn.delete(
        _WorkOrderListTable.tableName,
        where: 'list_type = ?',
        whereArgs: [listType],
      );

      final batch = txn.batch();
      for (final header in headers) {
        final preservedOffline =
            offlineLookup[header.workOrderId] ?? header.isOfflineMode;
        batch.insert(
          _WorkOrderHeadersTable.tableName,
          header.copyWith(isOfflineMode: preservedOffline).toMap(),
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

  Future<void> replaceRepairImages(
    String workOrderId,
    List<WorkOrderRepairImageEntity> images,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        _WorkOrderRepairImagesTable.tableName,
        where: 'work_order_id = ?',
        whereArgs: [workOrderId],
      );

      final batch = txn.batch();
      for (final image in images) {
        batch.insert(
          _WorkOrderRepairImagesTable.tableName,
          image.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
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

  Future<WorkOrderHeaderEntity?> getWorkOrderHeader(String workOrderId) async {
    final db = await database;
    final rows = await db.query(
      _WorkOrderHeadersTable.tableName,
      where: 'work_order_id = ?',
      whereArgs: [workOrderId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WorkOrderHeaderEntity.fromMap(rows.first);
  }

  Future<List<WorkOrderRepairImageEntity>> getRepairImages(
    String workOrderId,
  ) async {
    final db = await database;
    final rows = await db.query(
      _WorkOrderRepairImagesTable.tableName,
      where: 'work_order_id = ?',
      whereArgs: [workOrderId],
      orderBy: 'captured_at DESC, upload_id DESC',
    );
    return rows.map(WorkOrderRepairImageEntity.fromMap).toList();
  }

  Future<void> upsertWorkOrderHeader(WorkOrderHeaderEntity entity) async {
    final db = await database;
    await db.insert(
      _WorkOrderHeadersTable.tableName,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> ensureWorkOrderHeader(String workOrderId) async {
    final db = await database;
    await db.insert(
      _WorkOrderHeadersTable.tableName,
      {
        'work_order_id': workOrderId,
        'is_downloaded': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> setWorkOrderOfflineMode(
    String workOrderId,
    bool enabled,
  ) async {
    final db = await database;
    await ensureWorkOrderHeader(workOrderId);
    await db.update(
      _WorkOrderHeadersTable.tableName,
      {'offline_mode_enabled': enabled ? 1 : 0},
      where: 'work_order_id = ?',
      whereArgs: [workOrderId],
    );
  }

  Future<bool> isWorkOrderOfflineMode(String workOrderId) async {
    final db = await database;
    final result = await db.query(
      _WorkOrderHeadersTable.tableName,
      columns: ['offline_mode_enabled'],
      where: 'work_order_id = ?',
      whereArgs: [workOrderId],
      limit: 1,
    );
    if (result.isEmpty) {
      return false;
    }
    return (result.first['offline_mode_enabled'] as int? ?? 0) == 1;
  }

  Future<void> replaceSections(
    String workOrderId,
    List<WorkOrderSectionEntity> sections,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        _WorkOrderSectionsTable.tableName,
        where: 'work_order_id = ?',
        whereArgs: [workOrderId],
      );

      final batch = txn.batch();
      for (final section in sections) {
        batch.insert(
          _WorkOrderSectionsTable.tableName,
          section.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<WorkOrderSectionEntity>> getSections(String workOrderId) async {
    final db = await database;
    final rows = await db.query(
      _WorkOrderSectionsTable.tableName,
      where: 'work_order_id = ?',
      whereArgs: [workOrderId],
      orderBy: 'section_name ASC',
    );
    return rows.map(WorkOrderSectionEntity.fromMap).toList();
  }

  Future<void> upsertExecution(WorkOrderExecutionEntity entity) async {
    final db = await database;
    await db.insert(
      _WorkOrderExecutionTable.tableName,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<WorkOrderExecutionEntity?> getExecution(String workOrderId) async {
    final db = await database;
    final rows = await db.query(
      _WorkOrderExecutionTable.tableName,
      where: 'work_order_id = ?',
      whereArgs: [workOrderId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WorkOrderExecutionEntity.fromMap(rows.first);
  }

  Future<int> enqueuePendingAction(WorkOrderPendingActionEntity action) async {
    final db = await database;
    return db.insert(_WorkOrderPendingActionsTable.tableName, action.toMap());
  }

  Future<List<WorkOrderPendingActionEntity>> getPendingActions() async {
    final db = await database;
    final rows = await db.query(
      _WorkOrderPendingActionsTable.tableName,
      orderBy: 'created_at ASC',
    );
    return rows.map(WorkOrderPendingActionEntity.fromMap).toList();
  }

  Future<void> removePendingAction(int id) async {
    final db = await database;
    await db.delete(
      _WorkOrderPendingActionsTable.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getPendingActionCount({String? workOrderId}) async {
    final db = await database;
    final whereClause = workOrderId != null ? ' WHERE work_order_id = ?' : '';
    final args = workOrderId != null ? <Object?>[workOrderId] : const <Object?>[];
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${_WorkOrderPendingActionsTable.tableName}$whereClause',
      args,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> upsertComplaintDetail(
    WorkOrderComplaintDetailEntity entity,
  ) async {
    final db = await database;
    await db.insert(
      _WorkOrderComplaintDetailTable.tableName,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<WorkOrderComplaintDetailEntity?> getComplaintDetail(
    String workOrderId,
  ) async {
    final db = await database;
    final rows = await db.query(
      _WorkOrderComplaintDetailTable.tableName,
      where: 'work_order_id = ?',
      whereArgs: [workOrderId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WorkOrderComplaintDetailEntity.fromMap(rows.first);
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
    this.isOfflineMode = false,
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
  final bool isOfflineMode;

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
    bool? isOfflineMode,
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
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
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
      'offline_mode_enabled': isOfflineMode ? 1 : 0,
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
      isOfflineMode: (map['offline_mode_enabled'] as int? ?? 0) == 1,
    );
  }
}

@immutable
class WorkOrderComplaintDetailEntity {
  const WorkOrderComplaintDetailEntity({
    required this.workOrderId,
    required this.payloadJson,
    required this.lastSyncedAt,
  });

  final String workOrderId;
  final String payloadJson;
  final DateTime lastSyncedAt;

  Map<String, Object?> toMap() {
    return {
      'work_order_id': workOrderId,
      'payload_json': payloadJson,
      'last_synced_at': lastSyncedAt.toIso8601String(),
    };
  }

  static WorkOrderComplaintDetailEntity fromMap(
    Map<String, Object?> map,
  ) {
    return WorkOrderComplaintDetailEntity(
      workOrderId: map['work_order_id'] as String,
      payloadJson: map['payload_json'] as String,
      lastSyncedAt: DateTime.parse(map['last_synced_at'] as String),
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
  raw_payload TEXT,
  is_downloaded INTEGER NOT NULL DEFAULT 1,
  offline_mode_enabled INTEGER NOT NULL DEFAULT 0
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

class _WorkOrderRepairImagesTable {
  static const tableName = 'work_order_repair_images';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  upload_id TEXT PRIMARY KEY,
  work_order_id TEXT NOT NULL,
  upload_type TEXT,
  document_desc TEXT,
  document_src TEXT,
  payload TEXT NOT NULL,
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

@immutable
class WorkOrderSectionEntity {
  const WorkOrderSectionEntity({
    required this.workOrderId,
    required this.sectionName,
    this.sectionDesc,
    required this.payloadJson,
    this.lastSyncedAt,
  });

  final String workOrderId;
  final String sectionName;
  final String? sectionDesc;
  final String payloadJson;
  final DateTime? lastSyncedAt;

  Map<String, Object?> toMap() {
    return {
      'work_order_id': workOrderId,
      'section_name': sectionName,
      'section_desc': sectionDesc,
      'payload': payloadJson,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  static WorkOrderSectionEntity fromMap(Map<String, Object?> map) {
    return WorkOrderSectionEntity(
      workOrderId: map['work_order_id'] as String,
      sectionName: map['section_name'] as String,
      sectionDesc: map['section_desc'] as String?,
      payloadJson: map['payload'] as String,
      lastSyncedAt: _parseDate(map['last_synced_at']),
    );
  }
}

@immutable
class WorkOrderRepairImageEntity {
  const WorkOrderRepairImageEntity({
    required this.uploadId,
    required this.workOrderId,
    required this.payloadJson,
    this.uploadType,
    this.documentDesc,
    this.documentSrc,
    this.capturedAt,
    this.lastSyncedAt,
  });

  final String uploadId;
  final String workOrderId;
  final String payloadJson;
  final String? uploadType;
  final String? documentDesc;
  final String? documentSrc;
  final DateTime? capturedAt;
  final DateTime? lastSyncedAt;

  Map<String, Object?> toMap() {
    return {
      'upload_id': uploadId,
      'work_order_id': workOrderId,
      'upload_type': uploadType,
      'document_desc': documentDesc,
      'document_src': documentSrc,
      'payload': payloadJson,
      'captured_at': capturedAt?.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  static WorkOrderRepairImageEntity fromMap(Map<String, Object?> map) {
    return WorkOrderRepairImageEntity(
      uploadId: map['upload_id'] as String,
      workOrderId: map['work_order_id'] as String,
      payloadJson: map['payload'] as String,
      uploadType: map['upload_type'] as String?,
      documentDesc: map['document_desc'] as String?,
      documentSrc: map['document_src'] as String?,
      capturedAt: _parseDate(map['captured_at']),
      lastSyncedAt: _parseDate(map['last_synced_at']),
    );
  }
}

@immutable
class WorkOrderExecutionEntity {
  const WorkOrderExecutionEntity({
    required this.workOrderId,
    required this.payloadJson,
    this.lastSyncedAt,
  });

  final String workOrderId;
  final String payloadJson;
  final DateTime? lastSyncedAt;

  Map<String, Object?> toMap() {
    return {
      'work_order_id': workOrderId,
      'payload': payloadJson,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  static WorkOrderExecutionEntity fromMap(Map<String, Object?> map) {
    return WorkOrderExecutionEntity(
      workOrderId: map['work_order_id'] as String,
      payloadJson: map['payload'] as String,
      lastSyncedAt: _parseDate(map['last_synced_at']),
    );
  }
}

@immutable
class WorkOrderPendingActionEntity {
  const WorkOrderPendingActionEntity({
    this.id,
    required this.workOrderId,
    required this.action,
    required this.payloadJson,
    required this.createdAt,
  });

  final int? id;
  final String workOrderId;
  final String action;
  final String payloadJson;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'work_order_id': workOrderId,
      'action': action,
      'payload': payloadJson,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static WorkOrderPendingActionEntity fromMap(Map<String, Object?> map) {
    return WorkOrderPendingActionEntity(
      id: map['id'] as int?,
      workOrderId: map['work_order_id'] as String,
      action: map['action'] as String,
      payloadJson: map['payload'] as String,
      createdAt: _parseDate(map['created_at']) ?? DateTime.now(),
    );
  }
}

class _WorkOrderSectionsTable {
  static const tableName = 'work_order_sections';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  work_order_id TEXT NOT NULL,
  section_name TEXT NOT NULL,
  section_desc TEXT,
  payload TEXT NOT NULL,
  last_synced_at TEXT,
  PRIMARY KEY(work_order_id, section_name),
  FOREIGN KEY(work_order_id) REFERENCES ${_WorkOrderHeadersTable.tableName}(work_order_id) ON DELETE CASCADE
)
''';
}

class _WorkOrderExecutionTable {
  static const tableName = 'work_order_execution';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  work_order_id TEXT PRIMARY KEY,
  payload TEXT NOT NULL,
  last_synced_at TEXT
)
''';
}

class _WorkOrderPendingActionsTable {
  static const tableName = 'work_order_pending_actions';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  work_order_id TEXT NOT NULL,
  action TEXT NOT NULL,
  payload TEXT NOT NULL,
  created_at TEXT NOT NULL
)
''';
}

class _WorkOrderComplaintDetailTable {
  static const tableName = 'work_order_complaint_detail';
  static const createSql = '''
CREATE TABLE $tableName (
  work_order_id TEXT PRIMARY KEY,
  payload_json TEXT NOT NULL,
  last_synced_at TEXT NOT NULL
)
''';
}
