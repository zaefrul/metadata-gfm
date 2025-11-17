import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'entities/ppm_entities.dart';

const _dbName = 'gems_offline.db';
const _dbVersion = 17; // Add action_id column for batch sync tracking

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
    await db.execute(_ReferenceDataTable.categoryCodeIndexSql);
    await db.execute(_WorkOrderMaterialsTable.createSql);
    await db.execute(_WorkOrderListTable.createSql);
    await db.execute(_WorkOrderSectionsTable.createSql);
    await db.execute(_WorkOrderExecutionTable.createSql);
    await db.execute(_WorkOrderPendingActionsTable.createSql);
    await db.execute(_WorkOrderComplaintDetailTable.createSql);
    await db.execute(_WorkOrderRepairImagesTable.createSql);
    await db.execute(_WorkOrderResponseImagesTable.createSql);
    await db.execute(_WorkOrderSnapshotsTable.createSql);
    await db.execute(_WorkOrderSnapshotSectionsTable.createSql);
    await db.execute(_WorkOrderSnapshotSectionsTable.snapshotIndexSql);
    // PPM tables
    await db.execute(_PPMPendingActionsTable.createSql);
    await db.execute(_PPMMaintenanceImagesTable.createSql);
    await db.execute(_PPMTasksTable.createSql);
    await db.execute(_PPMSnapshotsTable.createSql);
    await db.execute(_PPMSnapshotSectionsTable.createSql);
    await db.execute(_PPMSnapshotSectionsTable.snapshotIndexSql);
    await db.execute(_PPMOfflineActionsTable.createSql);
    await db.execute(_PPMTechnicianCacheTable.createSql);
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
    if (oldVersion < 8) {
      await db.execute(_WorkOrderResponseImagesTable.createSql);
    }
    if (oldVersion < 9) {
      await db.execute(_WorkOrderMaterialsTable.createSql);
      await db.execute(_ReferenceDataTable.categoryCodeIndexSql);
    }
    if (oldVersion < 10) {
      await db.execute(_WorkOrderSnapshotsTable.createSql);
      await db.execute(_WorkOrderSnapshotSectionsTable.createSql);
      await db.execute(_WorkOrderSnapshotSectionsTable.snapshotIndexSql);
    }
    if (oldVersion < 11) {
      // Add PPM offline support tables
      await db.execute(_PPMPendingActionsTable.createSql);
      await db.execute(_PPMMaintenanceImagesTable.createSql);
      await db.execute(_PPMTasksTable.createSql);
    }
    if (oldVersion < 12) {
      // Add offline_mode_enabled column to ppm_tasks
      await db
          .execute(
            'ALTER TABLE ${_PPMTasksTable.tableName} ADD COLUMN offline_mode_enabled INTEGER DEFAULT 0',
          )
          .catchError((_) => null);
      // Add PPM snapshot tables
      await db.execute(_PPMSnapshotsTable.createSql);
      await db.execute(_PPMSnapshotSectionsTable.createSql);
      await db.execute(_PPMSnapshotSectionsTable.snapshotIndexSql);
    }
    if (oldVersion < 13) {
      // Add section_data column to ppm_snapshot_sections
      await db
          .execute(
            'ALTER TABLE ${_PPMSnapshotSectionsTable.tableName} ADD COLUMN section_data TEXT',
          )
          .catchError((_) => null);
    }
    if (oldVersion < 14) {
      // Add offline actions table for tracking start time and other offline operations
      await db.execute(_PPMOfflineActionsTable.createSql);
    }
    if (oldVersion < 15) {
      // Add technician cache table for offline technician management
      await db.execute(_PPMTechnicianCacheTable.createSql);
    }
    if (oldVersion < 16) {
      // Add task_started column to track if task has been manually started offline
      await db
          .execute(
            'ALTER TABLE ${_PPMTasksTable.tableName} ADD COLUMN task_started INTEGER DEFAULT 0',
          )
          .catchError((_) => null);
    }
    if (oldVersion < 17) {
      // Add action_id column to ppm_pending_actions for batch sync tracking
      debugPrint('📦 Migrating database to v17: Add action_id to ppm_pending_actions');
      await db
          .execute(
            'ALTER TABLE ${_PPMPendingActionsTable.tableName} ADD COLUMN action_id TEXT NOT NULL DEFAULT ""',
          )
          .catchError((_) => null);
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
      await txn.delete(_WorkOrderMaterialsTable.tableName);
      await txn.delete(_WorkOrderListTable.tableName);
      await txn.delete(_WorkOrderSectionsTable.tableName);
      await txn.delete(_WorkOrderExecutionTable.tableName);
      await txn.delete(_WorkOrderPendingActionsTable.tableName);
      await txn.delete(_WorkOrderComplaintDetailTable.tableName);
      await txn.delete(_WorkOrderRepairImagesTable.tableName);
      await txn.delete(_WorkOrderResponseImagesTable.tableName);
      await txn.delete(_WorkOrderSnapshotSectionsTable.tableName);
      await txn.delete(_WorkOrderSnapshotsTable.tableName);
    });
  }

  /// Recreate PPM tables (useful for fixing migration issues)
  Future<void> recreatePPMTables() async {
    final db = await database;
    try {
      // Drop existing PPM tables if they exist (ignore errors if they don't)
      await db.execute('DROP TABLE IF EXISTS ${_PPMSnapshotSectionsTable.tableName}');
      await db.execute('DROP TABLE IF EXISTS ${_PPMSnapshotsTable.tableName}');
      await db.execute('DROP TABLE IF EXISTS ${_PPMOfflineActionsTable.tableName}');
      await db.execute('DROP TABLE IF EXISTS ${_PPMTechnicianCacheTable.tableName}');
      await db.execute('DROP TABLE IF EXISTS ${_PPMPendingActionsTable.tableName}');
      await db.execute('DROP TABLE IF EXISTS ${_PPMMaintenanceImagesTable.tableName}');
      
      // Recreate all PPM tables with current schema
      await db.execute(_PPMTasksTable.createSql);
      await db.execute(_PPMPendingActionsTable.createSql);
      await db.execute(_PPMMaintenanceImagesTable.createSql);
      await db.execute(_PPMSnapshotsTable.createSql);
      await db.execute(_PPMSnapshotSectionsTable.createSql);
      await db.execute(_PPMSnapshotSectionsTable.snapshotIndexSql);
      await db.execute(_PPMOfflineActionsTable.createSql);
      await db.execute(_PPMTechnicianCacheTable.createSql);
      
      debugPrint('OfflineDatabase: Successfully recreated all PPM tables');
    } catch (err, st) {
      debugPrint('OfflineDatabase: Error recreating PPM tables: $err\n$st');
      rethrow;
    }
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
      await txn.delete(_WorkOrderResponseImagesTable.tableName);
      await txn.delete(_WorkOrderMaterialsTable.tableName);
      await txn.delete(_WorkOrderSnapshotSectionsTable.tableName);
      await txn.delete(_WorkOrderSnapshotsTable.tableName);
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

  Future<void> replaceResponseImages(
    String workOrderId,
    List<WorkOrderResponseImageEntity> images,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        _WorkOrderResponseImagesTable.tableName,
        where: 'work_order_id = ?',
        whereArgs: [workOrderId],
      );

      final batch = txn.batch();
      for (final image in images) {
        batch.insert(
          _WorkOrderResponseImagesTable.tableName,
          image.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> replaceMaterials(
    String workOrderId,
    List<WorkOrderMaterialEntity> materials,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        _WorkOrderMaterialsTable.tableName,
        where: 'work_order_id = ?',
        whereArgs: [workOrderId],
      );

      if (materials.isEmpty) {
        return;
      }

      final batch = txn.batch();
      for (final material in materials) {
        batch.insert(
          _WorkOrderMaterialsTable.tableName,
          material.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<WorkOrderMaterialEntity>> getMaterials(String workOrderId) async {
    final db = await database;
    final rows = await db.query(
      _WorkOrderMaterialsTable.tableName,
      where: 'work_order_id = ?',
      whereArgs: [workOrderId],
      orderBy: 'item_order ASC, material_id ASC',
    );
    return rows.map(WorkOrderMaterialEntity.fromMap).toList();
  }

  Future<void> replaceReferenceData({
    required String category,
    String? code,
    required List<ReferenceDataEntity> items,
  }) async {
    final db = await database;
    final scope = code ?? '';
    await db.transaction((txn) async {
      await txn.delete(
        _ReferenceDataTable.tableName,
        where: 'category = ? AND IFNULL(code, "") = ?',
        whereArgs: [category, scope],
      );

      if (items.isEmpty) {
        return;
      }

      final batch = txn.batch();
      for (final item in items) {
        batch.insert(
          _ReferenceDataTable.tableName,
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<ReferenceDataEntity>> getReferenceData({
    required String category,
    String? code,
  }) async {
    final db = await database;
    final scope = code ?? '';
    final rows = await db.query(
      _ReferenceDataTable.tableName,
      where: 'category = ? AND IFNULL(code, "") = ?',
      whereArgs: [category, scope],
      orderBy: 'label COLLATE NOCASE ASC, reference_id ASC',
    );
    return rows.map(ReferenceDataEntity.fromMap).toList();
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

  Future<List<WorkOrderResponseImageEntity>> getResponseImages(
    String workOrderId,
  ) async {
    final db = await database;
    final rows = await db.query(
      _WorkOrderResponseImagesTable.tableName,
      where: 'work_order_id = ?',
      whereArgs: [workOrderId],
      orderBy: 'captured_at DESC, upload_id DESC',
    );
    return rows.map(WorkOrderResponseImageEntity.fromMap).toList();
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

  Future<void> replaceSnapshot(
    WorkOrderSnapshotEntity snapshot,
    List<WorkOrderSnapshotSectionEntity> sections,
  ) async {
    await ensureWorkOrderHeader(snapshot.workOrderId);
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        _WorkOrderSnapshotsTable.tableName,
        where: 'work_order_id = ?',
        whereArgs: [snapshot.workOrderId],
      );

      await txn.insert(
        _WorkOrderSnapshotsTable.tableName,
        snapshot.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (sections.isEmpty) {
        return;
      }

      final batch = txn.batch();
      for (final section in sections) {
        batch.insert(
          _WorkOrderSnapshotSectionsTable.tableName,
          section.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<WorkOrderSnapshot?> getLatestSnapshot(String workOrderId) async {
    final db = await database;
    final rows = await db.query(
      _WorkOrderSnapshotsTable.tableName,
      where: 'work_order_id = ?',
      whereArgs: [workOrderId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final metadata = WorkOrderSnapshotEntity.fromMap(rows.first);
    final sectionRows = await db.query(
      _WorkOrderSnapshotSectionsTable.tableName,
      where: 'snapshot_id = ?',
      whereArgs: [metadata.snapshotId],
      orderBy: 'position ASC, section_id ASC',
    );
    final sections =
        sectionRows.map(WorkOrderSnapshotSectionEntity.fromMap).toList();
    return WorkOrderSnapshot(metadata: metadata, sections: sections);
  }

  Future<void> deleteSnapshotsForWorkOrder(String workOrderId) async {
    final db = await database;
    await db.delete(
      _WorkOrderSnapshotsTable.tableName,
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

  // ============================================================================
  // PPM OFFLINE MODE
  // ============================================================================

  Future<void> setPPMOfflineMode(
    String ppmTaskId,
    bool enabled,
  ) async {
    final db = await database;
    // Ensure the task exists in the database
    final existing = await db.query(
      _PPMTasksTable.tableName,
      where: 'ppm_task_id = ?',
      whereArgs: [ppmTaskId],
      limit: 1,
    );
    
    if (existing.isEmpty) {
      // Insert a new row if it doesn't exist
      await db.insert(
        _PPMTasksTable.tableName,
        {
          'ppm_task_id': ppmTaskId,
          'task_no': '',
          'offline_mode_enabled': enabled ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // Update existing row
      await db.update(
        _PPMTasksTable.tableName,
        {'offline_mode_enabled': enabled ? 1 : 0},
        where: 'ppm_task_id = ?',
        whereArgs: [ppmTaskId],
      );
    }
  }

  Future<bool> isPPMOfflineMode(String ppmTaskId) async {
    final db = await database;
    final result = await db.query(
      _PPMTasksTable.tableName,
      columns: ['offline_mode_enabled'],
      where: 'ppm_task_id = ?',
      whereArgs: [ppmTaskId],
      limit: 1,
    );
    if (result.isEmpty) {
      return false;
    }
    return (result.first['offline_mode_enabled'] as int? ?? 0) == 1;
  }

  /// Set task started status (for offline manual start)
  Future<void> setPPMTaskStarted(
    String ppmTaskId,
    bool started,
  ) async {
    final db = await database;
    // Ensure the task exists in the database
    final existing = await db.query(
      _PPMTasksTable.tableName,
      where: 'ppm_task_id = ?',
      whereArgs: [ppmTaskId],
      limit: 1,
    );
    
    if (existing.isEmpty) {
      // Insert a new row if it doesn't exist
      await db.insert(
        _PPMTasksTable.tableName,
        {
          'ppm_task_id': ppmTaskId,
          'task_no': '',
          'task_started': started ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // Update existing row
      await db.update(
        _PPMTasksTable.tableName,
        {'task_started': started ? 1 : 0},
        where: 'ppm_task_id = ?',
        whereArgs: [ppmTaskId],
      );
    }
  }

  /// Check if PPM task has been started (for offline mode)
  Future<bool> isPPMTaskStarted(String ppmTaskId) async {
    final db = await database;
    final result = await db.query(
      _PPMTasksTable.tableName,
      columns: ['task_started'],
      where: 'ppm_task_id = ?',
      whereArgs: [ppmTaskId],
      limit: 1,
    );
    if (result.isEmpty) {
      return false;
    }
    return (result.first['task_started'] as int? ?? 0) == 1;
  }

  // ============================================================================
  // PPM SNAPSHOTS
  // ============================================================================

  Future<void> savePPMSnapshot({
    required String ppmTaskId,
    required String taskNo,
    required String siteName,
    required String status,
    required List<Map<String, dynamic>> sections,
    String? executionJson,
    String? sectionAJson,
    String? sectionBJson,
  }) async {
    final db = await database;
    final createdAt = DateTime.now().toUtc().toIso8601String();

    // Ensure tables exist before transaction (handle migration edge case)
    try {
      await db.execute(_PPMSnapshotsTable.createSql);
      await db.execute(_PPMSnapshotSectionsTable.createSql);
      await db.execute(_PPMSnapshotSectionsTable.snapshotIndexSql);
      debugPrint('PPMSnapshot: Created missing tables');
    } catch (err) {
      // Tables already exist - this is expected
      debugPrint('PPMSnapshot: Tables already exist: $err');
    }

    await db.transaction((txn) async {
      // Delete existing snapshot
      await txn.delete(
        _PPMSnapshotsTable.tableName,
        where: 'ppm_task_id = ?',
        whereArgs: [ppmTaskId],
      );

      // Insert snapshot metadata
      await txn.insert(
        _PPMSnapshotsTable.tableName,
        {
          'ppm_task_id': ppmTaskId,
          'task_no': taskNo,
          'site_name': siteName,
          'status': status,
          'created_at': createdAt,
          'execution_json': executionJson,
          'section_a_json': sectionAJson,
          'section_b_json': sectionBJson,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Delete existing sections
      await txn.delete(
        _PPMSnapshotSectionsTable.tableName,
        where: 'ppm_task_id = ?',
        whereArgs: [ppmTaskId],
      );

      // Insert sections
      for (final section in sections) {
        await txn.insert(
          _PPMSnapshotSectionsTable.tableName,
          {
            'ppm_task_id': ppmTaskId,
            'section_name': section['ppmTaskSectionName'] ?? '',
            'section_status': section['ppmTaskSectionStatus'] ?? '',
            'check_parts': section['checkParts'] ?? '',
            'check_additional_report': section['checkAdditionalReport'] ?? '',
            'section_data': section['sectionData'], // Store the full section data JSON
          },
        );
      }
    });
  }

  Future<Map<String, dynamic>?> loadPPMSnapshot(String ppmTaskId) async {
    final db = await database;
    
    try {
      // Load snapshot metadata
      final snapshotRows = await db.query(
        _PPMSnapshotsTable.tableName,
        where: 'ppm_task_id = ?',
        whereArgs: [ppmTaskId],
        limit: 1,
      );

      if (snapshotRows.isEmpty) {
        return null;
      }

      final snapshot = snapshotRows.first;

      // Load sections
      final sectionRows = await db.query(
        _PPMSnapshotSectionsTable.tableName,
        where: 'ppm_task_id = ?',
        whereArgs: [ppmTaskId],
        orderBy: 'section_name ASC',
      );

      final sections = sectionRows.map((row) => {
        'ppmTaskSectionName': row['section_name'] as String,
        'ppmTaskSectionStatus': row['section_status'] as String,
        'checkParts': row['check_parts'] as String,
        'checkAdditionalReport': row['check_additional_report'] as String,
        'sectionData': row['section_data'] as String?, // Include section data
      }).toList();

      return {
        'ppmTaskId': snapshot['ppm_task_id'],
        'taskNo': snapshot['task_no'],
        'siteName': snapshot['site_name'],
        'status': snapshot['status'],
        'createdAt': snapshot['created_at'],
        'executionJson': snapshot['execution_json'],
        'sectionAJson': snapshot['section_a_json'],
        'sectionBJson': snapshot['section_b_json'],
        'sections': sections,
      };
    } catch (err) {
      debugPrint('loadPPMSnapshot: Error loading snapshot (tables may not exist): $err');
      return null;
    }
  }

  Future<void> deletePPMSnapshot(String ppmTaskId) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.delete(
          _PPMSnapshotSectionsTable.tableName,
          where: 'ppm_task_id = ?',
          whereArgs: [ppmTaskId],
        );
        await txn.delete(
          _PPMSnapshotsTable.tableName,
          where: 'ppm_task_id = ?',
          whereArgs: [ppmTaskId],
        );
      });
    } catch (err) {
      debugPrint('deletePPMSnapshot: Error deleting snapshot (tables may not exist): $err');
      // Silently ignore if tables don't exist
    }
  }

  /// Load section data for a specific section
  Future<String?> loadPPMSectionData(String ppmTaskId, String sectionName) async {
    final db = await database;
    try {
      final rows = await db.query(
        _PPMSnapshotSectionsTable.tableName,
        columns: ['section_data'],
        where: 'ppm_task_id = ? AND section_name = ?',
        whereArgs: [ppmTaskId, sectionName],
        limit: 1,
      );

      if (rows.isEmpty) {
        return null;
      }

      return rows.first['section_data'] as String?;
    } catch (err) {
      debugPrint('loadPPMSectionData: Error loading section data (table may not exist): $err');
      return null;
    }
  }

  /// Save/Update section data for a specific section
  /// Save/Update section data for a specific section
  Future<void> savePPMSectionData({
    required String ppmTaskId,
    required String sectionName,
    required String sectionData,
  }) async {
    final db = await database;
    
    try {
      // Ensure table exists
      await db.execute(_PPMSnapshotSectionsTable.createSql);
    } catch (err) {
      debugPrint('savePPMSectionData: Table already exists or error creating: $err');
    }
    
    try {
      // Check if section exists
      final existing = await db.query(
        _PPMSnapshotSectionsTable.tableName,
        where: 'ppm_task_id = ? AND section_name = ?',
        whereArgs: [ppmTaskId, sectionName],
        limit: 1,
      );

      if (existing.isEmpty) {
        // Insert new section
        await db.insert(
          _PPMSnapshotSectionsTable.tableName,
          {
            'ppm_task_id': ppmTaskId,
            'section_name': sectionName,
            'section_data': sectionData,
            'section_status': '',
            'check_parts': '',
            'check_additional_report': '',
          },
        );
      } else {
        // Update existing section
        await db.update(
          _PPMSnapshotSectionsTable.tableName,
          {'section_data': sectionData},
          where: 'ppm_task_id = ? AND section_name = ?',
          whereArgs: [ppmTaskId, sectionName],
        );
      }
    } catch (err) {
      debugPrint('savePPMSectionData: Error saving section data: $err');
      rethrow;
    }
  }

  /// Update section status in cache (e.g., change to "Completed")
  Future<void> updatePPMSectionStatus({
    required String ppmTaskId,
    required String sectionName,
    required String status,
  }) async {
    final db = await database;
    
    try {
      await db.update(
        _PPMSnapshotSectionsTable.tableName,
        {'section_status': status},
        where: 'ppm_task_id = ? AND section_name = ?',
        whereArgs: [ppmTaskId, sectionName],
      );
      debugPrint('updatePPMSectionStatus: Updated $sectionName status to $status for task $ppmTaskId');
    } catch (err) {
      debugPrint('updatePPMSectionStatus: Error updating section status: $err');
      // Non-fatal - continue even if update fails
    }
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
    final args =
        workOrderId != null ? <Object?>[workOrderId] : const <Object?>[];
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

  // ============================================================================
  // PPM METHODS
  // ============================================================================

  /// Check if action_id column exists in ppm_pending_actions table
  Future<bool> _ppmPendingActionsHasActionId() async {
    final db = await database;
    try {
      final result = await db.rawQuery('PRAGMA table_info(${_PPMPendingActionsTable.tableName})');
      return result.any((col) => col['name'] == 'action_id');
    } catch (err) {
      debugPrint('OfflineDatabase: Error checking action_id column: $err');
      return false;
    }
  }

  /// Fix ppm_pending_actions table schema by adding missing action_id column
  Future<void> _fixPPMPendingActionsSchema() async {
    final db = await database;
    try {
      debugPrint('🔧 Fixing ppm_pending_actions schema: Adding action_id column');
      await db.execute(
        'ALTER TABLE ${_PPMPendingActionsTable.tableName} ADD COLUMN action_id TEXT NOT NULL DEFAULT ""',
      );
      debugPrint('✅ Successfully added action_id column');
    } catch (err) {
      debugPrint('❌ Failed to add action_id column: $err');
      rethrow;
    }
  }

  Future<int> enqueuePPMPendingAction(PPMPendingActionEntity action) async {
    final db = await database;
    try {
      return await db.insert(_PPMPendingActionsTable.tableName, action.toMap());
    } catch (err) {
      // If insert fails due to missing action_id column, try to fix the schema
      if (err.toString().contains('action_id')) {
        debugPrint('⚠️ Detected missing action_id column, attempting to fix schema...');
        final hasActionId = await _ppmPendingActionsHasActionId();
        if (!hasActionId) {
          await _fixPPMPendingActionsSchema();
          // Retry insert after fixing schema
          return await db.insert(_PPMPendingActionsTable.tableName, action.toMap());
        }
      }
      rethrow;
    }
  }

  Future<List<PPMPendingActionEntity>> getPPMPendingActions({
    String? ppmTaskId,
  }) async {
    final db = await database;
    final rows = await db.query(
      _PPMPendingActionsTable.tableName,
      where: ppmTaskId != null ? 'ppm_task_id = ?' : null,
      whereArgs: ppmTaskId != null ? [ppmTaskId] : null,
      orderBy: 'created_at ASC',
    );
    return rows.map(PPMPendingActionEntity.fromMap).toList();
  }

  Future<void> removePPMPendingAction(int id) async {
    final db = await database;
    await db.delete(
      _PPMPendingActionsTable.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getPPMPendingActionCount({String? ppmTaskId}) async {
    final db = await database;
    final whereClause = ppmTaskId != null ? ' WHERE ppm_task_id = ?' : '';
    final args = ppmTaskId != null ? <Object?>[ppmTaskId] : const <Object?>[];
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${_PPMPendingActionsTable.tableName}$whereClause',
      args,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> upsertPPMMaintenanceImage(
    PPMMaintenanceImageEntity entity,
  ) async {
    final db = await database;
    await db.insert(
      _PPMMaintenanceImagesTable.tableName,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PPMMaintenanceImageEntity>> getPPMMaintenanceImages(
    String ppmTaskId,
  ) async {
    final db = await database;
    final rows = await db.query(
      _PPMMaintenanceImagesTable.tableName,
      where: 'ppm_task_id = ?',
      whereArgs: [ppmTaskId],
      orderBy: 'timestamp DESC',
    );
    return rows.map(PPMMaintenanceImageEntity.fromMap).toList();
  }

  Future<void> deletePPMMaintenanceImage(String ppmTaskUploadId) async {
    final db = await database;
    await db.delete(
      _PPMMaintenanceImagesTable.tableName,
      where: 'ppm_task_upload_id = ?',
      whereArgs: [ppmTaskUploadId],
    );
  }

  /// Save offline action (e.g., start time, section save)
  Future<int> savePPMOfflineAction({
    required String ppmTaskId,
    required String actionType,
    String? actionData,
    String? timestamp,
  }) async {
    final db = await database;
    return await db.insert(
      _PPMOfflineActionsTable.tableName,
      {
        'ppm_task_id': ppmTaskId,
        'action_type': actionType,
        'action_data': actionData,
        'timestamp': timestamp ?? DateTime.now().toIso8601String(),
        'synced': 0,
      },
    );
  }

  /// Get all unsynced offline actions
  Future<List<Map<String, dynamic>>> getPPMUnsyncedActions({String? ppmTaskId}) async {
    final db = await database;
    if (ppmTaskId != null) {
      return await db.query(
        _PPMOfflineActionsTable.tableName,
        where: 'synced = 0 AND ppm_task_id = ?',
        whereArgs: [ppmTaskId],
        orderBy: 'timestamp ASC',
      );
    }
    return await db.query(
      _PPMOfflineActionsTable.tableName,
      where: 'synced = 0',
      orderBy: 'timestamp ASC',
    );
  }

  /// Mark offline action as synced
  Future<void> markPPMActionSynced(int actionId) async {
    final db = await database;
    await db.update(
      _PPMOfflineActionsTable.tableName,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [actionId],
    );
  }

  /// Mark offline action as failed with error
  Future<void> markPPMActionFailed(int actionId, String error) async {
    final db = await database;
    await db.update(
      _PPMOfflineActionsTable.tableName,
      {'sync_error': error},
      where: 'id = ?',
      whereArgs: [actionId],
    );
  }

  /// Delete synced offline actions
  Future<void> deleteSyncedPPMActions() async {
    final db = await database;
    await db.delete(
      _PPMOfflineActionsTable.tableName,
      where: 'synced = 1',
    );
  }

  /// Get count of unsynced actions for a task
  Future<int> getPPMUnsyncedActionCount(String ppmTaskId) async {
    final db = await database;
    
    // Count unsynced offline actions (start_time, images, assistants)
    final offlineResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${_PPMOfflineActionsTable.tableName} WHERE synced = 0 AND ppm_task_id = ?',
      [ppmTaskId],
    );
    final offlineCount = Sqflite.firstIntValue(offlineResult) ?? 0;
    
    // Count pending actions (section saves like FormC, FormD, etc.)
    final pendingResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${_PPMPendingActionsTable.tableName} WHERE ppm_task_id = ?',
      [ppmTaskId],
    );
    final pendingCount = Sqflite.firstIntValue(pendingResult) ?? 0;
    
    return offlineCount + pendingCount;
  }

  /// Get pending actions summary grouped by section/type
  Future<Map<String, int>> getPPMPendingActionsSummary(String ppmTaskId) async {
    final db = await database;
    
    // Query both ppm_offline_actions (for start_time, images, etc.)
    final offlineActions = await db.query(
      _PPMOfflineActionsTable.tableName,
      where: 'synced = 0 AND ppm_task_id = ?',
      whereArgs: [ppmTaskId],
      orderBy: 'timestamp ASC',
    );
    
    // Query ppm_pending_actions (for section saves like FormC, FormD, etc.)
    final pendingActions = await db.query(
      _PPMPendingActionsTable.tableName,
      where: 'ppm_task_id = ?',
      whereArgs: [ppmTaskId],
      orderBy: 'created_at ASC',
    );
    
    final summary = <String, int>{};

    String _prettify(String raw) {
      return raw
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }

    void _bump(String key) {
      summary[key] = (summary[key] ?? 0) + 1;
    }
    
    String _mapOfflineActionToSection(String actionType) {
      if (actionType == 'start_time') {
        return 'Section A';
      }
      if (actionType.startsWith('section_')) {
        final parts = actionType.split('_');
        if (parts.length >= 2 && parts[1].isNotEmpty) {
          final sectionLetter = parts[1][0].toUpperCase();
          return 'Section $sectionLetter';
        }
      }
      if (actionType.contains('assistant')) {
        return 'Section I';
      }
      if (actionType.contains('image') || actionType.contains('photo')) {
        return 'Section H';
      }
      if (actionType.contains('remark')) {
        return 'Section G';
      }
      return _prettify(actionType);
    }

    String _mapPendingActionToSection(String actionType) {
      switch (actionType) {
        case 'save_qualitative_tasks':
          return 'Section C';
        case 'save_quantitative_tasks':
          return 'Section D';
        case 'save_lubricant_tasks':
        case 'check_ppm_parts':
        case 'add_ppm_parts':
          return 'Section E';
        case 'save_checklist_tasks':
        case 'check_additional_report':
        case 'upload_additional_report':
          return 'Section F';
        case 'save_rectification_tasks':
        case 'save_ppm_remark':
          return 'Section G';
        case 'save_material_request':
        case 'upload_maintenance_image':
        case 'upload_ppm_maintenance_image':
        case 'save_image_desc':
        case 'save_ppm_images_description':
          return 'Section H';
        case 'add_assistant':
        case 'remove_assistant':
        case 'save_assistant_list':
          return 'Section I';
        case 'complete_ppm_task':
        case 'submit_ppm':
          return 'Task Completion';
        default:
          return _prettify(actionType);
      }
    }
    
    // Process offline actions (start_time, images, assistants)
    for (final action in offlineActions) {
      final actionType = action['action_type'] as String;
      final sectionName = _mapOfflineActionToSection(actionType);
      _bump(sectionName);
    }
    
    // Process pending actions (section saves: FormC, FormD, FormE, FormF, etc.)
    for (final action in pendingActions) {
      final actionType = action['action'] as String;
      final sectionName = _mapPendingActionToSection(actionType);
      _bump(sectionName);
    }
    
    return summary;
  }

  // ============================================================================
  // PPM TECHNICIAN CACHE METHODS
  // ============================================================================

  /// Cache technician list for a PPM task
  Future<void> cachePPMTechnicians({
    required String ppmTaskId,
    required List<Map<String, dynamic>> technicians,
    required List<Map<String, dynamic>> selectedTechnicians,
  }) async {
    final db = await database;
    final timestamp = DateTime.now().toIso8601String();
    
    await db.transaction((txn) async {
      // Clear existing cache for this task
      await txn.delete(
        _PPMTechnicianCacheTable.tableName,
        where: 'ppm_task_id = ?',
        whereArgs: [ppmTaskId],
      );
      
      // Insert all technicians
      for (final tech in technicians) {
        await txn.insert(
          _PPMTechnicianCacheTable.tableName,
          {
            'ppm_task_id': ppmTaskId,
            'user_id': tech['userId'],
            'user_full_name': tech['userFullName'],
            'assistant_id': null,
            'is_selected': 0,
            'cached_at': timestamp,
          },
        );
      }
      
      // Update selected technicians
      for (final tech in selectedTechnicians) {
        await txn.update(
          _PPMTechnicianCacheTable.tableName,
          {
            'assistant_id': tech['ppmTaskAssistId'],
            'is_selected': 1,
          },
          where: 'ppm_task_id = ? AND user_id = ?',
          whereArgs: [ppmTaskId, tech['userId']],
        );
      }
    });
  }

  /// Get cached technician list for a PPM task
  Future<List<Map<String, dynamic>>> getCachedPPMTechnicians(
    String ppmTaskId,
  ) async {
    final db = await database;
    return await db.query(
      _PPMTechnicianCacheTable.tableName,
      where: 'ppm_task_id = ? AND is_selected = 0',
      whereArgs: [ppmTaskId],
      orderBy: 'user_full_name ASC',
    );
  }

  /// Get cached selected technicians for a PPM task
  Future<List<Map<String, dynamic>>> getCachedPPMSelectedTechnicians(
    String ppmTaskId,
  ) async {
    final db = await database;
    return await db.query(
      _PPMTechnicianCacheTable.tableName,
      where: 'ppm_task_id = ? AND is_selected = 1',
      whereArgs: [ppmTaskId],
      orderBy: 'user_full_name ASC',
    );
  }

  /// Check if technician cache exists for a task
  Future<bool> hasCachedPPMTechnicians(String ppmTaskId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${_PPMTechnicianCacheTable.tableName} WHERE ppm_task_id = ?',
      [ppmTaskId],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  /// Clear technician cache for a task
  Future<void> clearPPMTechnicianCache(String ppmTaskId) async {
    final db = await database;
    await db.delete(
      _PPMTechnicianCacheTable.tableName,
      where: 'ppm_task_id = ?',
      whereArgs: [ppmTaskId],
    );
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

@immutable
class WorkOrderSnapshot {
  const WorkOrderSnapshot({
    required this.metadata,
    required this.sections,
  });

  final WorkOrderSnapshotEntity metadata;
  final List<WorkOrderSnapshotSectionEntity> sections;
}

@immutable
class WorkOrderSnapshotEntity {
  const WorkOrderSnapshotEntity({
    required this.snapshotId,
    required this.workOrderId,
    required this.createdAt,
    this.status,
    this.summaryJson,
  });

  final String snapshotId;
  final String workOrderId;
  final DateTime createdAt;
  final String? status;
  final String? summaryJson;

  Map<String, Object?> toMap() {
    return {
      'snapshot_id': snapshotId,
      'work_order_id': workOrderId,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'summary_json': summaryJson,
    };
  }

  static WorkOrderSnapshotEntity fromMap(Map<String, Object?> map) {
    return WorkOrderSnapshotEntity(
      snapshotId: map['snapshot_id'] as String,
      workOrderId: map['work_order_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      status: map['status'] as String?,
      summaryJson: map['summary_json'] as String?,
    );
  }
}

@immutable
class WorkOrderSnapshotSectionEntity {
  const WorkOrderSnapshotSectionEntity({
    required this.snapshotId,
    required this.sectionId,
    this.sectionName,
    this.position = 0,
    this.payloadJson,
  });

  final String snapshotId;
  final String sectionId;
  final String? sectionName;
  final int position;
  final String? payloadJson;

  Map<String, Object?> toMap() {
    return {
      'snapshot_id': snapshotId,
      'section_id': sectionId,
      'section_name': sectionName,
      'position': position,
      'payload_json': payloadJson,
    };
  }

  static WorkOrderSnapshotSectionEntity fromMap(Map<String, Object?> map) {
    return WorkOrderSnapshotSectionEntity(
      snapshotId: map['snapshot_id'] as String,
      sectionId: map['section_id'] as String,
      sectionName: map['section_name'] as String?,
      position: map['position'] as int? ?? 0,
      payloadJson: map['payload_json'] as String?,
    );
  }
}

class _WorkOrderSnapshotsTable {
  static const tableName = 'work_order_snapshots';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  snapshot_id TEXT PRIMARY KEY,
  work_order_id TEXT NOT NULL,
  created_at TEXT NOT NULL,
  status TEXT,
  summary_json TEXT,
  FOREIGN KEY(work_order_id) REFERENCES ${_WorkOrderHeadersTable.tableName}(work_order_id) ON DELETE CASCADE
)
''';
}

class _WorkOrderSnapshotSectionsTable {
  static const tableName = 'work_order_snapshot_sections';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  snapshot_id TEXT NOT NULL,
  section_id TEXT NOT NULL,
  section_name TEXT,
  position INTEGER NOT NULL DEFAULT 0,
  payload_json TEXT,
  PRIMARY KEY(snapshot_id, section_id),
  FOREIGN KEY(snapshot_id) REFERENCES ${_WorkOrderSnapshotsTable.tableName}(snapshot_id) ON DELETE CASCADE
)
''';

  static const snapshotIndexSql =
      'CREATE INDEX IF NOT EXISTS idx_snapshot_sections_snapshot ON $tableName(snapshot_id, position)';
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

class _WorkOrderResponseImagesTable {
  static const tableName = 'work_order_response_images';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  upload_id TEXT PRIMARY KEY,
  work_order_id TEXT NOT NULL,
  document_filename TEXT,
  document_desc TEXT,
  document_src TEXT,
  payload TEXT NOT NULL,
  captured_at TEXT,
  last_synced_at TEXT,
  FOREIGN KEY(work_order_id) REFERENCES ${_WorkOrderHeadersTable.tableName}(work_order_id) ON DELETE CASCADE
)
''';
}

class _WorkOrderMaterialsTable {
  static const tableName = 'work_order_materials';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  material_id TEXT PRIMARY KEY,
  work_order_id TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  item_order INTEGER NOT NULL DEFAULT 0,
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

  static const categoryCodeIndexSql = '''
CREATE INDEX IF NOT EXISTS reference_data_category_code_idx
ON $tableName(category, COALESCE(code, ''))
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
class WorkOrderResponseImageEntity {
  const WorkOrderResponseImageEntity({
    required this.uploadId,
    required this.workOrderId,
    required this.payloadJson,
    this.documentFilename,
    this.documentDesc,
    this.documentSrc,
    this.capturedAt,
    this.lastSyncedAt,
  });

  final String uploadId;
  final String workOrderId;
  final String payloadJson;
  final String? documentFilename;
  final String? documentDesc;
  final String? documentSrc;
  final DateTime? capturedAt;
  final DateTime? lastSyncedAt;

  Map<String, Object?> toMap() {
    return {
      'upload_id': uploadId,
      'work_order_id': workOrderId,
      'document_filename': documentFilename,
      'document_desc': documentDesc,
      'document_src': documentSrc,
      'payload': payloadJson,
      'captured_at': capturedAt?.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  static WorkOrderResponseImageEntity fromMap(Map<String, Object?> map) {
    return WorkOrderResponseImageEntity(
      uploadId: map['upload_id'] as String,
      workOrderId: map['work_order_id'] as String,
      payloadJson: map['payload'] as String,
      documentFilename: map['document_filename'] as String?,
      documentDesc: map['document_desc'] as String?,
      documentSrc: map['document_src'] as String?,
      capturedAt: _parseDate(map['captured_at']),
      lastSyncedAt: _parseDate(map['last_synced_at']),
    );
  }
}

@immutable
class WorkOrderMaterialEntity {
  const WorkOrderMaterialEntity({
    required this.materialId,
    required this.workOrderId,
    required this.payloadJson,
    required this.itemOrder,
    this.lastSyncedAt,
  });

  final String materialId;
  final String workOrderId;
  final String payloadJson;
  final int itemOrder;
  final DateTime? lastSyncedAt;

  Map<String, Object?> toMap() {
    return {
      'material_id': materialId,
      'work_order_id': workOrderId,
      'payload_json': payloadJson,
      'item_order': itemOrder,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  static WorkOrderMaterialEntity fromMap(Map<String, Object?> map) {
    return WorkOrderMaterialEntity(
      materialId: map['material_id'] as String,
      workOrderId: map['work_order_id'] as String,
      payloadJson: map['payload_json'] as String,
      itemOrder: (map['item_order'] as int?) ?? 0,
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

// ============================================================================
// PPM TABLES (Preventive Maintenance Module)
// ============================================================================

class _PPMPendingActionsTable {
  static const tableName = 'ppm_pending_actions';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ppm_task_id TEXT NOT NULL,
  action TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  created_at TEXT NOT NULL,
  action_id TEXT NOT NULL DEFAULT ""
)
''';
}

class _PPMMaintenanceImagesTable {
  static const tableName = 'ppm_maintenance_images';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  ppm_task_upload_id TEXT PRIMARY KEY,
  ppm_task_id TEXT NOT NULL,
  upload_type TEXT NOT NULL,
  latitude TEXT,
  longitude TEXT,
  timestamp TEXT,
  description TEXT,
  upload_id TEXT,
  upload_name TEXT,
  document_desc TEXT,
  document_filename TEXT,
  document_src TEXT
)
''';
}

class _PPMTasksTable {
  static const tableName = 'ppm_tasks';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  ppm_task_id TEXT PRIMARY KEY,
  task_no TEXT NOT NULL,
  site_name TEXT,
  status TEXT,
  last_sync TEXT,
  data_json TEXT,
  offline_mode_enabled INTEGER DEFAULT 0,
  task_started INTEGER DEFAULT 0
)
''';
}

class _PPMSnapshotsTable {
  static const tableName = 'ppm_snapshots';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  ppm_task_id TEXT PRIMARY KEY,
  task_no TEXT NOT NULL,
  site_name TEXT,
  status TEXT,
  created_at TEXT NOT NULL,
  execution_json TEXT,
  section_a_json TEXT,
  section_b_json TEXT
)
''';
}

class _PPMSnapshotSectionsTable {
  static const tableName = 'ppm_snapshot_sections';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ppm_task_id TEXT NOT NULL,
  section_name TEXT NOT NULL,
  section_status TEXT NOT NULL,
  check_parts TEXT NOT NULL,
  check_additional_report TEXT NOT NULL,
  section_data TEXT,
  FOREIGN KEY (ppm_task_id) REFERENCES ${_PPMSnapshotsTable.tableName}(ppm_task_id) ON DELETE CASCADE
)
''';

  static const snapshotIndexSql = '''
CREATE INDEX IF NOT EXISTS idx_ppm_snapshot_sections_task 
ON $tableName(ppm_task_id)
''';
}

class _PPMOfflineActionsTable {
  static const tableName = 'ppm_offline_actions';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ppm_task_id TEXT NOT NULL,
  action_type TEXT NOT NULL,
  action_data TEXT,
  timestamp TEXT NOT NULL,
  synced INTEGER DEFAULT 0,
  sync_error TEXT
)
''';
}

class _PPMTechnicianCacheTable {
  static const tableName = 'ppm_technician_cache';
  static const createSql = '''
CREATE TABLE IF NOT EXISTS $tableName (
  ppm_task_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  user_full_name TEXT NOT NULL,
  assistant_id TEXT,
  is_selected INTEGER NOT NULL DEFAULT 0,
  cached_at TEXT NOT NULL,
  PRIMARY KEY (ppm_task_id, user_id)
)
''';
}
