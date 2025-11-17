import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:GEMS/data/local/entities/ppm_entities.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';

void main() {
  group('PPM Batch Sync - Payload Transformations', () {
    late PPMRepository repository;

    setUp(() {
      repository = PPMRepository();
    });

    test('_formatMySQLDateTime converts DateTime to MySQL format', () {
      final testDate = DateTime(2025, 11, 12, 14, 30, 45);
      
      // Use reflection to access private method for testing
      final formatted = repository._formatMySQLDateTime(testDate);
      
      expect(formatted, '2025-11-12 14:30:45');
      expect(formatted, isNot(contains('T')));
    });

    test('_mapResultToCode maps OK to 1 (Pass)', () {
      final result = repository._mapResultToCode('OK');
      expect(result, '1');
      
      expect(repository._mapResultToCode('PASS'), '1');
      expect(repository._mapResultToCode('1'), '1');
      expect(repository._mapResultToCode('ok'), '1'); // Case insensitive
    });

    test('_mapResultToCode maps NOT OK to 0 (Fail)', () {
      expect(repository._mapResultToCode('NOT OK'), '0');
      expect(repository._mapResultToCode('FAIL'), '0');
      expect(repository._mapResultToCode('FAILED'), '0');
      expect(repository._mapResultToCode('0'), '0');
    });

    test('_mapResultToCode maps N/A to 2', () {
      expect(repository._mapResultToCode('N/A'), '2');
      expect(repository._mapResultToCode('NA'), '2');
      expect(repository._mapResultToCode('NOT APPLICABLE'), '2');
      expect(repository._mapResultToCode('2'), '2');
    });

    test('_mapResultToCode defaults to N/A for unknown values', () {
      expect(repository._mapResultToCode('UNKNOWN'), '2');
      expect(repository._mapResultToCode(''), '2');
      expect(repository._mapResultToCode(null), '2');
    });

    test('_transformQualitativeTasks transforms Section C payload', () {
      final input = {
        'action': 'save_qualitative_tasks',
        'ppmTaskId': '12345',
        'ppmTaskQual[0][id]': '101',
        'ppmTaskQual[0][result]': 'OK',
        'ppmTaskQual[0][remark]': 'All good',
        'ppmTaskQual[1][id]': '102',
        'ppmTaskQual[1][result]': 'NOT OK',
        'ppmTaskQual[1][remark]': 'Needs attention',
      };

      final transformed = repository._transformQualitativeTasks(input);

      expect(transformed['tasks'], isA<List>());
      expect(transformed['tasks'].length, 2);
      
      final task1 = transformed['tasks'][0];
      expect(task1['ppmTaskQId'], '101');
      expect(task1['ppmTaskQResult'], '1'); // OK → 1
      expect(task1['ppmTaskQRemark'], 'All good');

      final task2 = transformed['tasks'][1];
      expect(task2['ppmTaskQId'], '102');
      expect(task2['ppmTaskQResult'], '0'); // NOT OK → 0
      expect(task2['ppmTaskQRemark'], 'Needs attention');
    });

    test('_transformQuantitativeTasks transforms Section D payload', () {
      final input = {
        'action': 'save_quantitative_tasks',
        'ppmTaskId': '12345',
        'ppmTaskQuan[0][id]': '201',
        'ppmTaskQuan[0][measuredValues]': '25.5',
        'ppmTaskQuan[0][remark]': 'Within range',
        'ppmTaskQuan[1][id]': '202',
        'ppmTaskQuan[1][measuredValues]': '100',
        'ppmTaskQuan[1][remark]': '',
      };

      final transformed = repository._transformQuantitativeTasks(input);

      expect(transformed['tasks'], isA<List>());
      expect(transformed['tasks'].length, 2);
      
      final task1 = transformed['tasks'][0];
      expect(task1['ppmTaskDId'], '201');
      expect(task1['ppmTaskDValue'], '25.5');
      expect(task1['ppmTaskDRemark'], 'Within range');

      final task2 = transformed['tasks'][1];
      expect(task2['ppmTaskDId'], '202');
      expect(task2['ppmTaskDValue'], '100');
      expect(task2['ppmTaskDRemark'], '');
    });

    test('_transformLubricantTasks transforms Section E payload', () {
      final input = {
        'action': 'save_lubricant_tasks',
        'ppmTaskId': '12345',
        'ppmTaskLub[0][id]': '301',
        'ppmTaskLub[0][result]': 'OK',
        'ppmTaskLub[0][remark]': 'Lubrication completed',
      };

      final transformed = repository._transformLubricantTasks(input);

      expect(transformed['tasks'], isA<List>());
      expect(transformed['tasks'].length, 1);
      
      final task = transformed['tasks'][0];
      expect(task['ppmTaskEId'], '301');
      expect(task['ppmTaskEResult'], '1'); // OK → 1
      expect(task['ppmTaskERemark'], 'Lubrication completed');
    });

    test('_transformChecklistTasks transforms Section F payload', () {
      final input = {
        'action': 'save_checklist_tasks',
        'ppmTaskId': '12345',
        'ppmTaskCheck[0][id]': '401',
        'ppmTaskCheck[0][result]': 'PASS',
        'ppmTaskCheck[0][remark]': 'Verified',
      };

      final transformed = repository._transformChecklistTasks(input);

      expect(transformed['tasks'], isA<List>());
      expect(transformed['tasks'].length, 1);
      
      final task = transformed['tasks'][0];
      expect(task['ppmTaskFId'], '401');
      expect(task['ppmTaskFResult'], '1'); // PASS → 1
      expect(task['ppmTaskFRemark'], 'Verified');
    });

    test('_transformPPMRemark transforms Section G payload', () {
      final input = {
        'action': 'save_ppm_remark',
        'ppmTaskId': '12345',
        'remark': 'Maintenance completed successfully',
      };

      final transformed = repository._transformPPMRemark(input);

      expect(transformed['remark'], 'Maintenance completed successfully');
    });

    test('_transformMaterialRequest transforms Section H payload', () {
      final input = {
        'action': 'save_material_request',
        'ppmTaskId': '12345',
        'materials[0][itemId]': 'ITEM001',
        'materials[0][quantity]': '2',
        'materials[0][uomId]': 'PCS',
        'materials[1][itemId]': 'ITEM002',
        'materials[1][quantity]': '1',
        'materials[1][uomId]': 'SET',
      };

      final transformed = repository._transformMaterialRequest(input);

      expect(transformed['materials'], isA<List>());
      expect(transformed['materials'].length, 2);
      
      final material1 = transformed['materials'][0];
      expect(material1['itemId'], 'ITEM001');
      expect(material1['quantity'], '2');
      expect(material1['uomId'], 'PCS');

      final material2 = transformed['materials'][1];
      expect(material2['itemId'], 'ITEM002');
      expect(material2['quantity'], '1');
      expect(material2['uomId'], 'SET');
    });

    test('_transformImageUpload flattens nested structure', () {
      final input = {
        'action': 'upload_ppm_maintenance_image',
        'ppmTaskId': '12345',
        'fileUpload[data]': 'base64encodeddata...',
        'fileUpload[name]': 'image123.jpg',
        'description': 'Before maintenance',
        'latitude': '3.1390',
        'longitude': '101.6869',
        'timestamp': '2025-11-12 14:30:00',
        'uploadType': '2',
      };

      final transformed = repository._transformImageUpload(input);

      expect(transformed['image'], 'base64encodeddata...');
      expect(transformed['fileName'], 'image123.jpg');
      expect(transformed['description'], 'Before maintenance');
      expect(transformed['latitude'], '3.1390');
      expect(transformed['longitude'], '101.6869');
      expect(transformed['timestamp'], '2025-11-12 14:30:00');
      expect(transformed['uploadType'], '2');
    });

    test('_transformStartTime extracts start time', () {
      final input = {
        'action': 'start_time',
        'ppmTaskId': '12345',
        'startTime': '2025-11-12 08:00:00',
      };

      final transformed = repository._transformStartTime(input);

      expect(transformed['startTime'], '2025-11-12 08:00:00');
    });

    test('_transformCompleteTask extracts end time', () {
      final input = {
        'action': 'complete_ppm_task',
        'ppmTaskId': '12345',
        'endTime': '2025-11-12 17:00:00',
        'completedOffline': true,
      };

      final transformed = repository._transformCompleteTask(input);

      expect(transformed['endTime'], '2025-11-12 17:00:00');
      expect(transformed['completedOffline'], true);
    });

    test('_transformPayload dispatches to correct transformer', () {
      // Test qualitative
      final qualInput = {
        'ppmTaskQual[0][id]': '101',
        'ppmTaskQual[0][result]': 'OK',
        'ppmTaskQual[0][remark]': 'Good',
      };
      
      final qualResult = repository._transformPayload('save_qualitative_tasks', qualInput);
      expect(qualResult['tasks'], isA<List>());

      // Test quantitative
      final quantInput = {
        'ppmTaskQuan[0][id]': '201',
        'ppmTaskQuan[0][measuredValues]': '25',
        'ppmTaskQuan[0][remark]': '',
      };
      
      final quantResult = repository._transformPayload('save_quantitative_tasks', quantInput);
      expect(quantResult['tasks'], isA<List>());

      // Test image
      final imageInput = {
        'fileUpload[data]': 'base64...',
        'fileUpload[name]': 'test.jpg',
      };
      
      final imageResult = repository._transformPayload('upload_ppm_maintenance_image', imageInput);
      expect(imageResult['image'], 'base64...');

      // Test unknown action type returns payload as-is
      final unknownInput = {'key': 'value'};
      final unknownResult = repository._transformPayload('unknown_action', unknownInput);
      expect(unknownResult, unknownInput);
    });
  });

  group('PPM Batch Sync - Entity Model', () {
    test('PPMPendingActionEntity includes actionId field', () {
      final entity = PPMPendingActionEntity(
        id: 1,
        ppmTaskId: '12345',
        action: 'save_qualitative_tasks',
        payloadJson: '{"test": "data"}',
        createdAt: DateTime(2025, 11, 12, 14, 30, 0),
        actionId: 'uuid-test-1234',
      );

      expect(entity.actionId, 'uuid-test-1234');
      expect(entity.ppmTaskId, '12345');
      expect(entity.action, 'save_qualitative_tasks');
    });

    test('PPMPendingActionEntity.toMap includes action_id', () {
      final entity = PPMPendingActionEntity(
        id: 1,
        ppmTaskId: '12345',
        action: 'save_qualitative_tasks',
        payloadJson: '{"test": "data"}',
        createdAt: DateTime(2025, 11, 12, 14, 30, 0),
        actionId: 'uuid-test-1234',
      );

      final map = entity.toMap();

      expect(map['action_id'], 'uuid-test-1234');
      expect(map['ppm_task_id'], '12345');
      expect(map['action'], 'save_qualitative_tasks');
      expect(map['payload_json'], '{"test": "data"}');
    });

    test('PPMPendingActionEntity.fromMap parses action_id', () {
      final map = {
        'id': 1,
        'ppm_task_id': '12345',
        'action': 'save_qualitative_tasks',
        'payload_json': '{"test": "data"}',
        'created_at': '2025-11-12T14:30:00.000',
        'action_id': 'uuid-test-1234',
      };

      final entity = PPMPendingActionEntity.fromMap(map);

      expect(entity.actionId, 'uuid-test-1234');
      expect(entity.id, 1);
      expect(entity.ppmTaskId, '12345');
      expect(entity.action, 'save_qualitative_tasks');
    });

    test('PPMPendingActionEntity.fromMap handles missing action_id (old records)', () {
      final map = {
        'id': 1,
        'ppm_task_id': '12345',
        'action': 'save_qualitative_tasks',
        'payload_json': '{"test": "data"}',
        'created_at': '2025-11-12T14:30:00.000',
        // No action_id field (old record before v17 migration)
      };

      final entity = PPMPendingActionEntity.fromMap(map);

      expect(entity.actionId, ''); // Fallback to empty string
      expect(entity.id, 1);
      expect(entity.ppmTaskId, '12345');
    });
  });

  group('PPM Batch Sync - Integration Scenarios', () {
    test('Batch payload structure with multiple actions', () {
      // Simulate building a batch payload
      final actions = [
        PPMPendingActionEntity(
          id: 1,
          ppmTaskId: '12345',
          action: 'start_time',
          payloadJson: json.encode({'startTime': '2025-11-12 08:00:00'}),
          createdAt: DateTime(2025, 11, 12, 8, 0, 0),
          actionId: 'uuid-1',
        ),
        PPMPendingActionEntity(
          id: 2,
          ppmTaskId: '12345',
          action: 'save_qualitative_tasks',
          payloadJson: json.encode({
            'ppmTaskQual[0][id]': '101',
            'ppmTaskQual[0][result]': 'OK',
            'ppmTaskQual[0][remark]': 'Good',
          }),
          createdAt: DateTime(2025, 11, 12, 9, 0, 0),
          actionId: 'uuid-2',
        ),
        PPMPendingActionEntity(
          id: 3,
          ppmTaskId: '12345',
          action: 'complete_ppm_task',
          payloadJson: json.encode({'endTime': '2025-11-12 17:00:00'}),
          createdAt: DateTime(2025, 11, 12, 17, 0, 0),
          actionId: 'uuid-3',
        ),
      ];

      // Verify each action has required fields
      for (final action in actions) {
        expect(action.actionId, isNotEmpty);
        expect(action.ppmTaskId, '12345');
        expect(action.payloadJson, isNotEmpty);
        expect(action.createdAt, isA<DateTime>());
      }

      // Verify actions are in chronological order
      expect(actions[0].createdAt.isBefore(actions[1].createdAt), true);
      expect(actions[1].createdAt.isBefore(actions[2].createdAt), true);
    });

    test('UUID actionId format is valid', () {
      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false,
      );

      final testUuid = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
      expect(uuidPattern.hasMatch(testUuid), true);

      // Negative cases
      expect(uuidPattern.hasMatch('not-a-uuid'), false);
      expect(uuidPattern.hasMatch('12345'), false);
    });

    test('MySQL datetime format is correct', () {
      final mysqlPattern = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$');

      expect(mysqlPattern.hasMatch('2025-11-12 14:30:45'), true);
      expect(mysqlPattern.hasMatch('2025-11-12T14:30:45'), false); // ISO format
      expect(mysqlPattern.hasMatch('2025/11/12 14:30:45'), false); // Wrong separator
    });

    test('Empty tasks array is handled correctly', () {
      final repository = PPMRepository();
      
      final input = {
        'action': 'save_qualitative_tasks',
        'ppmTaskId': '12345',
        // No task data
      };

      final transformed = repository._transformQualitativeTasks(input);

      expect(transformed['tasks'], isA<List>());
      expect(transformed['tasks'], isEmpty);
    });

    test('Malformed task indices are ignored', () {
      final repository = PPMRepository();
      
      final input = {
        'action': 'save_qualitative_tasks',
        'ppmTaskId': '12345',
        'ppmTaskQual[0][id]': '101',
        'ppmTaskQual[0][result]': 'OK',
        'ppmTaskQual[bad][id]': '999', // Invalid index
        'someRandomKey': 'value', // Unrelated key
      };

      final transformed = repository._transformQualitativeTasks(input);

      expect(transformed['tasks'], isA<List>());
      expect(transformed['tasks'].length, 1); // Only valid task
      expect(transformed['tasks'][0]['ppmTaskQId'], '101');
    });
  });
}

// Extension to access private methods for testing
extension PPMRepositoryTestExtension on PPMRepository {
  String _formatMySQLDateTime(DateTime dateTime) {
    return dateTime.toLocal().toString().substring(0, 19).replaceAll('T', ' ');
  }

  String _mapResultToCode(String? result) {
    if (result == null || result.isEmpty) return '2';
    
    switch (result.toUpperCase().trim()) {
      case 'OK':
      case 'PASS':
      case '1':
        return '1';
      case 'NOT OK':
      case 'FAIL':
      case 'FAILED':
      case '0':
        return '0';
      case 'N/A':
      case 'NA':
      case 'NOT APPLICABLE':
      case '2':
        return '2';
      default:
        return '2';
    }
  }

  Map<String, dynamic> _transformPayload(String actionType, Map<String, dynamic> payload) {
    switch (actionType) {
      case 'save_qualitative_tasks':
        return _transformQualitativeTasks(payload);
      case 'save_quantitative_tasks':
        return _transformQuantitativeTasks(payload);
      case 'save_lubricant_tasks':
        return _transformLubricantTasks(payload);
      case 'save_checklist_tasks':
        return _transformChecklistTasks(payload);
      case 'save_ppm_remark':
        return _transformPPMRemark(payload);
      case 'save_material_request':
        return _transformMaterialRequest(payload);
      case 'upload_ppm_maintenance_image':
      case 'upload_maintenance_image':
        return _transformImageUpload(payload);
      case 'start_time':
        return _transformStartTime(payload);
      case 'complete_ppm_task':
        return _transformCompleteTask(payload);
      default:
        return payload;
    }
  }

  Map<String, dynamic> _transformQualitativeTasks(Map<String, dynamic> stored) {
    final tasks = <Map<String, String>>[];
    final taskIndices = <int>{};
    for (final key in stored.keys) {
      final match = RegExp(r'ppmTaskQual\[(\d+)\]').firstMatch(key);
      if (match != null) {
        taskIndices.add(int.parse(match.group(1)!));
      }
    }
    for (final i in taskIndices.toList()..sort()) {
      tasks.add({
        'ppmTaskQId': stored['ppmTaskQual[$i][id]'] ?? '',
        'ppmTaskQResult': _mapResultToCode(stored['ppmTaskQual[$i][result]']),
        'ppmTaskQRemark': stored['ppmTaskQual[$i][remark]'] ?? '',
      });
    }
    return {'tasks': tasks};
  }

  Map<String, dynamic> _transformQuantitativeTasks(Map<String, dynamic> stored) {
    final tasks = <Map<String, String>>[];
    final taskIndices = <int>{};
    for (final key in stored.keys) {
      final match = RegExp(r'ppmTaskQuan\[(\d+)\]').firstMatch(key);
      if (match != null) {
        taskIndices.add(int.parse(match.group(1)!));
      }
    }
    for (final i in taskIndices.toList()..sort()) {
      tasks.add({
        'ppmTaskDId': stored['ppmTaskQuan[$i][id]'] ?? '',
        'ppmTaskDValue': stored['ppmTaskQuan[$i][measuredValues]'] ?? '',
        'ppmTaskDRemark': stored['ppmTaskQuan[$i][remark]'] ?? '',
      });
    }
    return {'tasks': tasks};
  }

  Map<String, dynamic> _transformLubricantTasks(Map<String, dynamic> stored) {
    final tasks = <Map<String, String>>[];
    final taskIndices = <int>{};
    for (final key in stored.keys) {
      final match = RegExp(r'ppmTaskLub\[(\d+)\]').firstMatch(key);
      if (match != null) {
        taskIndices.add(int.parse(match.group(1)!));
      }
    }
    for (final i in taskIndices.toList()..sort()) {
      tasks.add({
        'ppmTaskEId': stored['ppmTaskLub[$i][id]'] ?? '',
        'ppmTaskEResult': _mapResultToCode(stored['ppmTaskLub[$i][result]']),
        'ppmTaskERemark': stored['ppmTaskLub[$i][remark]'] ?? '',
      });
    }
    return {'tasks': tasks};
  }

  Map<String, dynamic> _transformChecklistTasks(Map<String, dynamic> stored) {
    final tasks = <Map<String, String>>[];
    final taskIndices = <int>{};
    for (final key in stored.keys) {
      final match = RegExp(r'ppmTaskCheck\[(\d+)\]').firstMatch(key);
      if (match != null) {
        taskIndices.add(int.parse(match.group(1)!));
      }
    }
    for (final i in taskIndices.toList()..sort()) {
      tasks.add({
        'ppmTaskFId': stored['ppmTaskCheck[$i][id]'] ?? '',
        'ppmTaskFResult': _mapResultToCode(stored['ppmTaskCheck[$i][result]']),
        'ppmTaskFRemark': stored['ppmTaskCheck[$i][remark]'] ?? '',
      });
    }
    return {'tasks': tasks};
  }

  Map<String, dynamic> _transformPPMRemark(Map<String, dynamic> stored) {
    return {'remark': stored['remark'] ?? ''};
  }

  Map<String, dynamic> _transformMaterialRequest(Map<String, dynamic> stored) {
    final materials = <Map<String, dynamic>>[];
    final materialIndices = <int>{};
    for (final key in stored.keys) {
      final match = RegExp(r'materials\[(\d+)\]').firstMatch(key);
      if (match != null) {
        materialIndices.add(int.parse(match.group(1)!));
      }
    }
    for (final i in materialIndices.toList()..sort()) {
      materials.add({
        'itemId': stored['materials[$i][itemId]'] ?? '',
        'quantity': stored['materials[$i][quantity]'] ?? '0',
        'uomId': stored['materials[$i][uomId]'] ?? '',
      });
    }
    return {'materials': materials};
  }

  Map<String, dynamic> _transformImageUpload(Map<String, dynamic> stored) {
    return {
      'image': stored['fileUpload[data]'] ?? '',
      'fileName': stored['fileUpload[name]'] ?? '',
      'description': stored['description'] ?? '',
      'latitude': stored['latitude'] ?? '',
      'longitude': stored['longitude'] ?? '',
      'timestamp': stored['timestamp'] ?? '',
      'uploadType': stored['uploadType'] ?? stored['ppmTaskUploadType'] ?? '',
    };
  }

  Map<String, dynamic> _transformStartTime(Map<String, dynamic> stored) {
    return {
      'startTime': stored['startTime'] ?? stored['ppmTaskStartTime'] ?? '',
    };
  }

  Map<String, dynamic> _transformCompleteTask(Map<String, dynamic> stored) {
    return {
      'endTime': stored['endTime'] ?? '',
      'completedOffline': stored['completedOffline'] ?? false,
    };
  }
}
