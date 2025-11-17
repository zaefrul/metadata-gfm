# PPM Batch Sync - Mobile App Implementation Changes

**Date:** 12 November 2025  
**Priority:** HIGH - Breaking changes required  
**Status:** Ready for implementation

---

## 🎯 Overview

Backend API is implemented with slight structural differences from our original spec. This document outlines all required mobile app changes to align with the production API.

**Good News:** Backend implementation is excellent and includes bonus features (submission readiness validation)!

---

## 📋 Change Summary

| Change Type | Count | Priority |
|-------------|-------|----------|
| **Request Structure** | 3 changes | HIGH |
| **Field Renaming** | 8 fields | HIGH |
| **Value Format** | 2 changes | MEDIUM |
| **New Features** | 1 bonus | LOW (optional) |

---

## 🔧 Required Changes

### 1. Request Structure Changes

#### Change 1.1: Nest metadata fields

**Current Code:**
```dart
final batchPayload = {
  'action': 'batch_sync_offline_actions',
  'ppmTaskId': ppmTaskId,
  'userId': userId,  // ❌ Remove this
  'syncTimestamp': DateTime.now().toIso8601String(),
  'deviceId': deviceId,
  'actions': [],
};
```

**New Code:**
```dart
final batchPayload = {
  'action': 'batch_sync_offline_actions',
  'metadata': {
    'ppmTaskId': ppmTaskId,
    'deviceId': deviceId,
    'syncTimestamp': _formatMySQLDateTime(DateTime.now()),
  },
  'actions': [],
};
```

**Notes:**
- ✅ Remove `userId` (extracted from JWT by backend)
- ✅ Nest `ppmTaskId`, `deviceId`, `syncTimestamp` under `metadata`
- ⚠️ Use MySQL datetime format: `YYYY-MM-DD HH:MM:SS` (not ISO8601)

---

#### Change 1.2: Use UUID for actionId (not sequenceId)

**Current Code:**
```dart
batchPayload['actions'].add({
  'sequenceId': i + 1,  // ❌ Change this
  'actionType': _mapActionType(action.action),
  'createdAt': action.createdAt.toIso8601String(),  // ❌ Rename this
  'payload': transformedPayload,
});
```

**New Code:**
```dart
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

batchPayload['actions'].add({
  'actionId': _uuid.v4(),  // ✅ Generate UUID
  'actionType': _mapActionType(action.action),
  'timestamp': _formatMySQLDateTime(action.createdAt),  // ✅ Renamed + formatted
  'payload': transformedPayload,
});
```

**Notes:**
- ✅ Add `uuid` package to `pubspec.yaml`
- ✅ Generate UUID v4 for each action
- ✅ Store `actionId` in local DB to track sync status
- ✅ Rename `createdAt` → `timestamp`
- ⚠️ Use MySQL datetime format

---

#### Change 1.3: Add datetime formatting helper

**Add to `PPMRepository`:**
```dart
/// Format DateTime to MySQL datetime string (YYYY-MM-DD HH:MM:SS)
String _formatMySQLDateTime(DateTime dateTime) {
  return dateTime.toLocal().toString().substring(0, 19).replaceAll('T', ' ');
}
```

**Example:**
- Input: `DateTime.parse("2025-11-11T08:00:15+08:00")`
- Output: `"2025-11-11 08:00:00"`

---

### 2. Payload Field Renaming

#### Change 2.1: Qualitative Tasks (Section C)

**Current Transformation:**
```dart
Map<String, dynamic> _transformQualitativeTasks(Map<String, dynamic> stored) {
  final tasks = <Map<String, String>>[];
  // ... parse logic ...
  for (final i in taskIndices.toList()..sort()) {
    tasks.add({
      'id': stored['ppmTaskQual[$i][id]'] ?? '',  // ❌
      'result': stored['ppmTaskQual[$i][result]'] ?? '',  // ❌
      'remark': stored['ppmTaskQual[$i][remark]'] ?? '',  // ❌
    });
  }
  return {'tasks': tasks};
}
```

**New Transformation:**
```dart
Map<String, dynamic> _transformQualitativeTasks(Map<String, dynamic> stored) {
  final tasks = <Map<String, String>>[];
  // ... parse logic ...
  for (final i in taskIndices.toList()..sort()) {
    tasks.add({
      'ppmTaskQId': stored['ppmTaskQual[$i][id]'] ?? '',  // ✅
      'ppmTaskQResult': _mapResultToCode(stored['ppmTaskQual[$i][result]']),  // ✅
      'ppmTaskQRemark': stored['ppmTaskQual[$i][remark]'] ?? '',  // ✅
    });
  }
  return {'tasks': tasks};
}

/// Map mobile result strings to backend codes
String _mapResultToCode(String? result) {
  switch (result?.toUpperCase()) {
    case 'OK':
    case 'PASS':
    case '1':
      return '1';  // Pass
    case 'NOT OK':
    case 'FAIL':
    case '0':
      return '0';  // Fail
    case 'N/A':
    case 'NA':
    case '2':
      return '2';  // N/A
    default:
      return '2';  // Default to N/A
  }
}
```

---

#### Change 2.2: Quantitative Tasks (Section D)

**Current Transformation:**
```dart
Map<String, dynamic> _transformQuantitativeTasks(Map<String, dynamic> stored) {
  final tasks = <Map<String, String>>[];
  for (final i in taskIndices.toList()..sort()) {
    tasks.add({
      'id': stored['ppmTaskQuan[$i][id]'] ?? '',
      'setValues': stored['ppmTaskQuan[$i][setValues]'] ?? '',
      'measuredValues': stored['ppmTaskQuan[$i][measuredValues]'] ?? '',
      'limit': stored['ppmTaskQuan[$i][limit]'] ?? '',
      'result': stored['ppmTaskQuan[$i][result]'] ?? '',
      'remark': stored['ppmTaskQuan[$i][remark]'] ?? '',
    });
  }
  return {'tasks': tasks};
}
```

**New Transformation:**
```dart
Map<String, dynamic> _transformQuantitativeTasks(Map<String, dynamic> stored) {
  final tasks = <Map<String, String>>[];
  for (final i in taskIndices.toList()..sort()) {
    tasks.add({
      'ppmTaskDId': stored['ppmTaskQuan[$i][id]'] ?? '',  // ✅ Renamed
      'ppmTaskDValue': stored['ppmTaskQuan[$i][measuredValues]'] ?? '',  // ✅ Changed
      'ppmTaskDRemark': stored['ppmTaskQuan[$i][remark]'] ?? '',  // ✅ Renamed
      // ❌ Remove: setValues, limit, result (backend doesn't use)
    });
  }
  return {'tasks': tasks};
}
```

**Note:** Backend only stores **value + remark**, not set values or limits.

---

#### Change 2.3: Image Upload

**Current Transformation:**
```dart
Map<String, dynamic> _transformImageUpload(Map<String, dynamic> stored) {
  return {
    'fileUpload': {
      'data': stored['fileUpload[data]'],
      'name': stored['fileUpload[name]'],
    },
    'description': stored['description'] ?? '',
    'latitude': stored['latitude'] ?? '',
    'longitude': stored['longitude'] ?? '',
    'timestamp': stored['timestamp'] ?? '',
  };
}
```

**New Transformation:**
```dart
Map<String, dynamic> _transformImageUpload(Map<String, dynamic> stored) {
  return {
    'image': stored['fileUpload[data]'],  // ✅ Flattened
    'fileName': stored['fileUpload[name]'],  // ✅ Renamed
    'uploadType': stored['uploadType'] ?? '0',  // ✅ Added (0=Before, 1=During, 2=After)
    'latitude': stored['latitude'] ?? '',
    'longitude': stored['longitude'] ?? '',
    // ❌ Remove: description, timestamp (not in backend)
  };
}
```

**Note:** Add `uploadType` field when capturing images (default "0" for "Before").

---

### 3. Response Handling Changes

#### Change 3.1: Track actions by actionId (not sequenceId)

**Current Code:**
```dart
if (response['success'] == true) {
  for (final result in response['results']) {
    if (result['status'] == 'success') {
      final actionId = actions[result['sequenceId'] - 1].id;  // ❌ Wrong
      await _database.removePPMPendingAction(actionId!);
    }
  }
}
```

**New Code:**
```dart
if (response['success'] == true) {
  // Build actionId → database ID mapping
  final actionIdMap = <String, int>{};
  for (final action in actions) {
    actionIdMap[action.actionId] = action.id!;
  }
  
  for (final result in response['results']) {
    if (result['success'] == true) {  // ✅ Changed: 'status' → 'success'
      final dbId = actionIdMap[result['actionId']];  // ✅ Use actionId
      if (dbId != null) {
        await _database.removePPMPendingAction(dbId);
      }
    }
  }
}
```

**Note:** Response uses `success: true/false`, not `status: "success"/"failed"`

---

#### Change 3.2: Store actionId in pending actions table

**Update `PPMPendingActionEntity`:**
```dart
class PPMPendingActionEntity {
  final int? id;
  final String ppmTaskId;
  final String action;
  final String payloadJson;
  final DateTime createdAt;
  final String actionId;  // ✅ Add this field

  // ... constructor, toMap, fromMap
}
```

**Update database schema (migration):**
```dart
// In _onUpgrade method
if (oldVersion < 17) {
  await db.execute('''
    ALTER TABLE ppm_pending_actions 
    ADD COLUMN action_id TEXT NOT NULL DEFAULT ''
  ''');
}
```

---

### 4. New Feature: Submission Readiness (Bonus)

Backend returns `submissionReady` object that validates sections and provides submit params!

**Response Structure:**
```json
{
  "submissionReady": {
    "canSubmit": true,
    "checkpoint": "2",
    "requiredSections": {
      "sectionA": true,
      "sectionC": true,
      "taskComplete": true
    },
    "missingRequirements": [],
    "submitParams": {
      "ppmTaskId": "12345",
      "checkpoint": "2",
      "result": "1",
      "remark": "Completed offline"
    },
    "completedOffline": true
  }
}
```

**Implementation (Optional but Recommended):**

```dart
Future<void> syncPendingActions() async {
  // ... existing sync logic ...
  
  final response = await _postBatch(batchPayload);
  
  if (response['success'] == true) {
    // Remove synced actions
    // ...
    
    // ✅ Check submission readiness
    final submissionReady = response['submissionReady'];
    if (submissionReady != null && submissionReady['canSubmit'] == true) {
      // Auto-submit to workflow
      await _autoSubmitToWorkflow(submissionReady['submitParams']);
    } else if (submissionReady != null) {
      // Show missing requirements
      final missing = submissionReady['missingRequirements'] as List?;
      debugPrint('Cannot submit yet. Missing: ${missing?.join(', ')}');
    }
  }
}

Future<void> _autoSubmitToWorkflow(Map<String, dynamic> submitParams) async {
  debugPrint('Auto-submitting PPM task to workflow...');
  
  final provider = Provider(fetchURL: '/api/m_ppm.php');
  await provider.init();
  
  await provider.post(
    url: '/api/m_ppm.php',
    body: {
      'action': 'submit_ppm',
      'ppmTaskId': submitParams['ppmTaskId'],
      'checkpoint': submitParams['checkpoint'],
      'result': submitParams['result'],
      'remark': submitParams['remark'],
    },
  );
  
  debugPrint('✅ PPM task submitted to workflow successfully!');
}
```

**Benefits:**
- ✅ Automatic workflow submission after sync
- ✅ Clear validation feedback to user
- ✅ No need to manually check section completion

---

## 📦 Package Dependencies

### Add to `pubspec.yaml`:

```yaml
dependencies:
  uuid: ^4.0.0  # For generating actionId
```

Run: `flutter pub get`

---

## 🗃️ Database Migration

### Version 17: Add actionId to pending actions

```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  // ... existing migrations ...
  
  if (oldVersion < 17) {
    debugPrint('📦 Migrating database to v17: Add action_id to ppm_pending_actions');
    await db.execute('''
      ALTER TABLE ppm_pending_actions 
      ADD COLUMN action_id TEXT NOT NULL DEFAULT ''
    ''');
  }
}
```

Update `_databaseVersion` constant:
```dart
static const int _databaseVersion = 17;
```

---

## 🧪 Testing Checklist

### Unit Tests
- [ ] `_formatMySQLDateTime()` produces correct format
- [ ] `_mapResultToCode()` handles all result variations
- [ ] Qualitative task transformation uses correct field names
- [ ] Quantitative task transformation uses correct field names
- [ ] Image upload transformation uses correct field names
- [ ] UUID generation works and produces unique IDs

### Integration Tests
- [ ] Batch sync request has correct structure
- [ ] Backend accepts metadata nested structure
- [ ] Backend accepts actionId (UUID)
- [ ] Backend accepts timestamp in MySQL format
- [ ] Response parsing works with new field names
- [ ] Action removal by actionId works correctly

### End-to-End Tests
- [ ] Offline → fill forms → sync → verify data in database
- [ ] Partial failure handling works
- [ ] Idempotency: duplicate sync returns cached response
- [ ] Submission readiness validation works
- [ ] Auto-submit to workflow succeeds

---

## 📋 Implementation Checklist

### Phase 1: Core Changes (2-3 hours)
- [ ] Update request structure (nest metadata)
- [ ] Add UUID package and generate actionId
- [ ] Add datetime formatting helper
- [ ] Update all payload transformations
- [ ] Update response parsing

### Phase 2: Database (30 minutes)
- [ ] Database migration v17 (add action_id column)
- [ ] Update PPMPendingActionEntity model
- [ ] Update enqueuePPMPendingAction method
- [ ] Test migration on existing database

### Phase 3: Testing (2 hours)
- [ ] Unit tests for transformations
- [ ] Integration tests with mock server
- [ ] End-to-end test with staging backend
- [ ] Verify all action types work

### Phase 4: Bonus Feature (1 hour)
- [ ] Implement submission readiness handling
- [ ] Add auto-submit to workflow
- [ ] Update UI to show validation status

### Phase 5: Deployment (30 minutes)
- [ ] Code review
- [ ] Merge to main branch
- [ ] Deploy to production
- [ ] Monitor sync success rate

**Total Estimated Time: 6-7 hours**

---

## 🚨 Critical Notes

1. **Breaking Changes:** Old batch sync format will NOT work with backend. Must implement all changes before enabling batch sync.

2. **DateTime Format:** Backend is STRICT about MySQL datetime format. ISO8601 will fail.

3. **Result Codes:** Qualitative tasks must use "0"/"1"/"2", not "OK"/"NOT OK".

4. **actionId Storage:** Must store UUID in database to track which actions succeeded/failed.

5. **Backward Compatibility:** Keep old sequential sync as fallback during rollout.

---

## 📞 Questions for Backend Team

None! Backend implementation is excellent and well-documented. 🎉

---

**Document Owner:** Mobile Development Team  
**Last Updated:** 12 November 2025  
**Version:** 1.0
