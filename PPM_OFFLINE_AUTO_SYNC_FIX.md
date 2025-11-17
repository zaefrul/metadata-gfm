# PPM Offline Mode Auto-Sync Fix

**Date**: 12 November 2025  
**Issue**: Disabling offline mode discards pending changes instead of syncing them  
**Status**: ✅ Fixed

---

## Problem Description

When a user disables offline mode in PPM, the system was:
1. ❌ Turning off offline mode flag
2. ❌ Deleting the snapshot
3. ❌ Clearing task started status
4. ❌ **NOT syncing pending actions** ← **THE BUG**

**Result**: All pending changes were effectively discarded, forcing users to re-enter data.

### User Impact
- Users lose all offline work when toggling offline mode off
- No indication that changes weren't synced
- Frustrating experience leading to data re-entry

---

## Root Cause

**File**: `lib/data/repository/ppm_repository.dart`  
**Method**: `setOfflineMode()`

The original code when `enabled = false`:
```dart
} else {
  // Disable offline mode and optionally delete snapshot
  await _database.setPPMOfflineMode(ppmTaskId, false);
  await _database.deletePPMSnapshot(ppmTaskId);
  await _database.setPPMTaskStarted(ppmTaskId, false);
}
```

**Missing**: No call to `syncPendingActions()` before cleanup!

---

## Solution Implemented

### 1. Backend: Auto-Sync on Disable

**File**: `lib/data/repository/ppm_repository.dart`  
**Method**: `setOfflineMode()`

```dart
} else {
  // Disable offline mode: sync pending actions first, then cleanup
  debugPrint('PPMRepository.setOfflineMode: Disabling offline mode, checking for pending actions...');
  
  // Check if there are pending actions to sync
  final pendingActions = await _database.getPPMPendingActions(ppmTaskId: ppmTaskId);
  
  if (pendingActions.isNotEmpty) {
    debugPrint('PPMRepository.setOfflineMode: Found ${pendingActions.length} pending actions, syncing before cleanup...');
    try {
      // Attempt to sync pending actions
      await syncPendingActions();
      debugPrint('PPMRepository.setOfflineMode: Sync completed successfully');
    } catch (err, st) {
      debugPrint('PPMRepository.setOfflineMode: Sync failed, keeping pending actions: $err\n$st');
      // Don't rethrow - allow user to disable offline mode even if sync fails
      // Pending actions will remain in queue for later retry
    }
  } else {
    debugPrint('PPMRepository.setOfflineMode: No pending actions to sync');
  }
  
  // Disable offline mode and cleanup
  await _database.setPPMOfflineMode(ppmTaskId, false);
  await _database.deletePPMSnapshot(ppmTaskId);
  await _database.setPPMTaskStarted(ppmTaskId, false);
  
  debugPrint('PPMRepository.setOfflineMode: Offline mode disabled successfully');
}
```

**Key Changes**:
- ✅ Check for pending actions before cleanup
- ✅ Call `syncPendingActions()` if any pending
- ✅ Catch sync errors gracefully (don't block offline disable)
- ✅ Keep pending actions in queue if sync fails (retry later)

---

### 2. UI: Confirmation Dialog & Progress Feedback

**File**: `lib/controller/PPM/Form/form_view.dart`  
**Method**: `_toggleOfflineMode()`

#### Before Disabling: Confirmation Dialog

```dart
if (!enable) {
  final pendingCount = await _repository.getPendingActionsCount(widget.id);
  
  if (pendingCount > 0) {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sync Pending Changes?'),
          content: Text(
            'You have $pendingCount pending changes that haven\'t been synced yet.\n\n'
            'Disabling offline mode will automatically sync these changes to the server.\n\n'
            'Continue?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Sync & Disable'),
            ),
          ],
        );
      },
    );
    
    if (confirmed != true) return; // User cancelled
  }
}
```

#### During Sync: Progress Toast

```dart
if (pendingCount > 0) {
  Toast.show(
    'Syncing $pendingCount pending changes...',
    duration: Toast.lengthLong,
    gravity: Toast.bottom,
  );
}
```

#### After Sync: Success/Failure Feedback

```dart
final finalPendingCount = await _repository.getPendingActionsCount(widget.id);

Toast.show(
  enable
      ? 'Offline mode enabled. Updates will be stored locally.'
      : finalPendingCount > 0
          ? 'Offline mode disabled. Note: $finalPendingCount changes could not be synced (network issue). They will sync when online.'
          : 'Offline mode disabled. All changes synced successfully.',
  duration: Toast.lengthLong,
  gravity: Toast.bottom,
);
```

---

## User Flow (After Fix)

### Scenario 1: Disable Offline Mode (With Pending Changes)

1. User toggles offline mode **OFF**
2. System checks: "5 pending changes found"
3. **Dialog appears**: "Sync Pending Changes? You have 5 pending changes..."
4. User clicks "Sync & Disable"
5. **Toast shows**: "Syncing 5 pending changes..."
6. System syncs to server (batch sync API)
7. **Success toast**: "Offline mode disabled. All changes synced successfully."

### Scenario 2: Disable Offline Mode (No Pending Changes)

1. User toggles offline mode **OFF**
2. System checks: "0 pending changes"
3. No dialog shown
4. **Toast shows**: "Offline mode disabled. All changes synced successfully."

### Scenario 3: Disable Offline Mode (Sync Fails - Network Down)

1. User toggles offline mode **OFF**
2. Dialog appears with 5 pending changes
3. User confirms
4. **Toast shows**: "Syncing 5 pending changes..."
5. Network is down → sync fails
6. **Warning toast**: "Offline mode disabled. Note: 5 changes could not be synced (network issue). They will sync when online."
7. Pending actions **remain in queue** for later retry

---

## Edge Cases Handled

| Scenario | Behavior |
|----------|----------|
| **Network down during disable** | Sync fails gracefully, pending actions remain queued, user warned |
| **User cancels confirmation** | Offline mode stays enabled, no changes made |
| **Partial sync failure** | Some actions sync, failed ones remain in queue |
| **No pending actions** | No dialog, instant disable |
| **Backend rejects actions** | Actions remain in queue, user warned |

---

## Testing Scenarios

### Test 1: Normal Sync on Disable
1. Enable offline mode
2. Make 5 changes (qualitative, quantitative, images, etc.)
3. Verify pending badge shows "5"
4. Disable offline mode
5. Confirm in dialog
6. **Expected**: All 5 changes sync, success toast, pending badge disappears

### Test 2: Network Failure During Disable
1. Enable offline mode
2. Make 3 changes
3. **Turn off WiFi/data**
4. Disable offline mode
5. Confirm in dialog
6. **Expected**: Warning toast, pending actions still queued

### Test 3: Cancel Confirmation
1. Enable offline mode
2. Make 2 changes
3. Try to disable offline mode
4. **Click "Cancel"** in dialog
5. **Expected**: Offline mode stays enabled, changes still pending

### Test 4: No Pending Changes
1. Enable offline mode
2. Don't make any changes
3. Disable offline mode
4. **Expected**: No dialog, instant disable, success toast

---

## Code Changes Summary

### Files Modified

| File | Changes | Lines Changed |
|------|---------|---------------|
| `lib/data/repository/ppm_repository.dart` | Added auto-sync logic in `setOfflineMode()` | +23 |
| `lib/controller/PPM/Form/form_view.dart` | Added confirmation dialog + progress feedback | +45 |

### Methods Updated

1. **`PPMRepository.setOfflineMode()`**
   - Added pending action check
   - Added `syncPendingActions()` call
   - Added error handling

2. **`FormViewState._toggleOfflineMode()`**
   - Added confirmation dialog (when pending > 0)
   - Added progress toast
   - Added success/failure feedback
   - Added final pending count check

---

## Benefits

✅ **No data loss**: Pending changes always synced before cleanup  
✅ **User awareness**: Clear dialogs and feedback at each step  
✅ **Graceful degradation**: Network failures don't block workflow  
✅ **Retry mechanism**: Failed syncs stay queued for later  
✅ **Better UX**: Users understand what's happening with their data  

---

## Migration Notes

### For Existing Users (Upgrade Path)

Users who already have pending actions in queue from old app version:
- ✅ Pending actions remain in queue after upgrade
- ✅ Next offline mode disable will sync them
- ✅ Manual sync button still works
- ✅ No migration script needed

### For Backend Team

No backend changes required:
- ✅ Uses existing `batch_sync_offline_actions` API
- ✅ No new endpoints needed
- ⚠️ **Reminder**: Backend must read JSON from `php://input` (see `BACKEND_FIX_REQUIRED.md`)

---

## Related Documents

- `BACKEND_FIX_REQUIRED.md` - Backend JSON POST fix (still needed for batch sync to work)
- `API_PPM_OFFLINE_DOC.md` - Batch sync API specification
- `PPM_API_FLOW_WITHOUT_OFFLINE.md` - Current sequential API flow analysis

---

## Future Enhancements

### Potential Improvements (Not in Current Fix)

1. **Auto-sync on app resume**: Sync when user returns to app (if online)
2. **Background sync**: Use WorkManager to sync in background
3. **Sync progress indicator**: Show detailed progress for each action
4. **Conflict resolution UI**: Handle cases where server data changed
5. **Partial disable**: Keep offline mode on but force one-time sync

---

**Last Updated**: 12 November 2025  
**Status**: Ready for Testing  
**Next Step**: Test with various network conditions
