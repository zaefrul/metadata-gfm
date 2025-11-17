# PPM Batch Sync Reversion

**Date**: 12 November 2025  
**Status**: ✅ Complete  
**Decision**: Revert from batch sync to original sequential sync approach

---

## Summary

Reverted the PPM offline batch sync implementation back to the original sequential individual API call approach. While the batch sync provided 20x performance improvement (3-5s vs 48-72s), deployment blockers and increased complexity made the simpler solution more pragmatic.

---

## What Was Reverted

### Removed Code (Preserved in Git History)

**From `lib/data/repository/ppm_repository.dart`**:
- ❌ `syncPendingActions()` - Batch sync implementation (~160 lines)
- ❌ `_postBatchJson()` - JSON POST helper (~50 lines)
- ❌ `_transformPayload()` - Payload transformation router (~30 lines)
- ❌ `_transformQualitativeTasks()` through `_transformCheckAdditionalReport()` - 11 transformation methods (~250 lines)
- ❌ `_formatMySQLDateTime()` - MySQL date formatter
- ❌ `_mapResultToCode()` - Result string to code mapper
- ❌ `_autoSubmitToWorkflow()` - Auto-submission on sync complete
- ❌ Import: `package:http/http.dart` (no longer needed)

**Total Lines Removed**: ~500 lines

---

## What Was Restored

### New `syncPendingActions()` Implementation

```dart
Future<void> syncPendingActions() async {
  final pending = await _database.getPPMPendingActions();
  if (pending.isEmpty) return;

  var successCount = 0;
  var failedCount = 0;
  
  // Process each action sequentially (original approach)
  for (final action in pending) {
    try {
      final payload = json.decode(action.payloadJson) as Map<String, dynamic>;
      await _post(payload); // Send to original endpoint
      
      if (action.id != null) {
        await _database.removePPMPendingAction(action.id!);
        successCount++;
      }
    } catch (err) {
      failedCount++;
      // Continue with next action
    }
  }
}
```

**Key Characteristics**:
- ✅ **Simple**: One action → one API call
- ✅ **Reliable**: Uses existing, proven endpoints
- ✅ **No Backend Changes Required**: Works with current backend as-is
- ✅ **Predictable**: Clear 1:1 mapping between queue and requests
- ❌ **Slower**: 48-72 seconds for full sync (vs 3-5s with batch)
- ❌ **More Network Requests**: 22-30 individual calls

---

## What Remains Unchanged

### Still Working ✅
- **Offline Mode Toggle**: Enable/disable offline mode per PPM task
- **Auto-Sync on Disable**: Automatically syncs pending actions when offline mode is turned off
- **Confirmation Dialog**: Warns users about pending changes before disabling
- **Pending Action Queue**: All 11 action types still queueable
- **Local Cache**: Section data, images, execution, technicians all cached
- **Snapshot System**: Full task state download for offline reference

---

## Reasons for Reversion

### 1. **Backend Deployment Blocker**
- Backend fix requires PHP to read JSON from `php://input` instead of `$_POST`
- Backend team deployment timeline unknown
- Mobile team blocked indefinitely waiting for backend changes

### 2. **Complexity vs Benefit Trade-off**
- **Batch Sync**: 500+ lines, complex payload transformations, new endpoint, backend dependency
- **Sequential Sync**: 60 lines, reuses existing endpoints, no backend changes
- Performance gain (20x faster) not critical enough to justify complexity

### 3. **Pragmatic Decision**
- Sequential sync works today with zero backend changes
- Users can tolerate 48-72s sync (happens rarely: only when disabling offline mode)
- Simpler code = easier to maintain = fewer bugs

---

## Performance Comparison

| Metric | Batch Sync | Sequential Sync |
|--------|-----------|----------------|
| **Sync Time** | 3-5 seconds | 48-72 seconds |
| **API Calls** | 1 per task | 22-30 per task |
| **Code Complexity** | ~500 lines | ~60 lines |
| **Backend Changes** | Required (PHP fix) | None needed |
| **Payload Format** | JSON POST | Form-encoded POST |
| **Error Handling** | Per-action in response | Per-request try/catch |
| **Deployment Risk** | High (backend + mobile) | Low (mobile only) |

---

## Technical Details

### Original Flow (Now Restored)
```
For each pending action:
  1. Load from ppm_pending_actions table
  2. Deserialize payloadJson
  3. Call existing API endpoint:
     - /api/m_ppm.php?action=save_qualitative_tasks
     - /api/m_ppm.php?action=save_quantitative_tasks
     - /api/m_ppm.php?action=upload_ppm_maintenance_image
     - etc. (11 different actions)
  4. If success: Remove from queue
  5. If fail: Keep in queue, continue to next
```

### Removed Batch Flow
```
Group actions by ppmTaskId:
  1. Build batch payload:
     {
       "action": "batch_sync_offline_actions",
       "metadata": {...},
       "actions": [
         {"actionId": "...", "actionType": "save_qualitative_tasks", "payload": {...}},
         {"actionId": "...", "actionType": "save_quantitative_tasks", "payload": {...}},
         ...
       ]
     }
  2. Send as JSON POST to /api/m_ppm.php
  3. Backend processes all actions atomically
  4. Returns success/fail per action
  5. Remove synced actions from queue
```

---

## Files Changed

### Modified
- `lib/data/repository/ppm_repository.dart` (-440 lines)
  - Replaced `syncPendingActions()` with sequential version
  - Removed all batch sync helper methods
  - Removed `http` package import

### Unchanged
- `lib/data/local/offline_database.dart` (pending actions table remains)
- `lib/controller/PPM/Form/form_view.dart` (offline toggle UI)
- All form screens (Section A-H)
- `lib/data/local/entities/ppm_entities.dart` (action_id column kept)
- `pubspec.yaml` (uuid package still used for action IDs)

---

## Testing Recommendations

### Test Scenarios
1. **Basic Offline Flow**:
   - Enable offline mode → Make changes → Disable offline mode → Verify sync completes

2. **Partial Failures**:
   - Queue 5 actions → Manually break 1 endpoint → Verify other 4 still sync

3. **Network Interruption**:
   - Start sync → Turn off WiFi mid-sync → Verify graceful failure + resume on reconnect

4. **Multiple Tasks**:
   - Queue actions for 3 different PPM tasks → Verify all sync correctly

5. **Session Expiry During Sync**:
   - Queue actions → Let token expire → Trigger sync → Verify re-login prompt

### Acceptance Criteria
- ✅ All 11 action types sync successfully
- ✅ Sync completes within 60-90 seconds for typical workload (5-10 actions)
- ✅ Failed actions remain in queue for retry
- ✅ No data loss on network interruption
- ✅ UI shows accurate pending count

---

## Rollback Plan (If Needed in Future)

### To Re-Enable Batch Sync:
```bash
# Find the commit before reversion
git log --oneline --all --grep="batch sync" --before="2025-11-12"

# Restore batch sync implementation
git show <commit-hash>:lib/data/repository/ppm_repository.dart > lib/data/repository/ppm_repository.dart

# Re-add http import
# pubspec.yaml already has http: ^1.1.0

# Ensure backend has deployed JSON POST fix
curl -X POST https://gems.metadatasystem.my/api/m_ppm.php \
  -H "Content-Type: application/json" \
  -d '{"action":"batch_sync_offline_actions","metadata":{...},"actions":[...]}'
  
# Should return: {"success":true,...}
# NOT: {"success":false,"error":"Parameter action invalid"}
```

---

## Related Documentation

- **Current API Flow**: `PPM_API_FLOW_WITHOUT_OFFLINE.md` (22-30 sequential calls)
- **Offline Auto-Sync Fix**: `PPM_OFFLINE_AUTO_SYNC_FIX.md` (still applies)
- **Backend Fix**: `BACKEND_FIX_REQUIRED.md` (no longer needed, archived)
- **Batch Sync Tests**: `test/ppm_batch_sync_test.dart` (24 tests, can be archived)

---

## Lessons Learned

### What Went Well ✅
- Offline mode core functionality works perfectly
- Local caching and pending action queue robust
- Auto-sync on offline disable prevents data loss
- Good separation between data layer and UI

### What Didn't Go Well ❌
- Batch sync added too much complexity too early
- Backend dependency not validated before implementation
- Transformation layer created tight coupling to backend schema

### Best Practices Going Forward
1. **Minimize Backend Dependencies**: Use existing endpoints first
2. **Incremental Complexity**: Start simple, add optimizations later
3. **Early Backend Validation**: Verify backend changes can be deployed before mobile work
4. **Measure Real Impact**: 48s→5s looks big, but only matters if sync is frequent
5. **Document Decision Points**: This file should've existed _before_ batch sync was coded

---

## Migration Notes for Developers

### If You See Old Batch Sync Code in Branches:
```dart
// OLD - DO NOT USE
final response = await _postBatchJson(provider, batchPayload);

// NEW - Use existing Provider pattern
await _post(payload);
```

### If You See Transformation Methods:
```dart
// OLD - Removed
final transformed = _transformQualitativeTasks(payload);

// NEW - Use original payload format
// No transformation needed - backend already understands it
await _post(payload);
```

### If You See `http` Package Used Directly:
```dart
// OLD - Removed
import 'package:http/http.dart' as http;
final response = await http.post(url, headers: {...}, body: json.encode(data));

// NEW - Use Provider class
final provider = Provider(fetchURL: '/api/m_ppm.php', taskID: ppmTaskId);
await provider.init();
await provider.post(url: '/api/m_ppm.php', body: payload);
```

---

## Conclusion

The reversion to sequential sync is **the right decision** given:
- ✅ No backend changes required
- ✅ Simpler, more maintainable code
- ✅ Proven, stable implementation
- ✅ Acceptable performance for real-world use

While batch sync was technically impressive (20x faster), it introduced too much complexity for a feature that runs infrequently (only when disabling offline mode). The sequential approach is battle-tested, works today, and unblocks the PPM offline feature for production deployment.

If sync performance becomes a bottleneck in the future (e.g., users complain about 60s sync times), batch sync can be revisited once backend is ready to support JSON POST endpoints.

---

**Version**: 1.0  
**Author**: GEMS Development Team  
**Git Commit**: [To be added after commit]
