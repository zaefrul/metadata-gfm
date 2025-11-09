# PPM Pending Sync Indicator Implementation

## Summary

Successfully implemented the same pending sync indicator that Work Order offline mode uses, now for PPM tasks. The system shows a banner at the top of the task list indicating how many actions are waiting to sync when back online.

## Changes Made

### 1. Created Shared Components (✅ DONE)

**File: `lib/utils/pending_sync_controller.dart`** (NEW)
- Controller class that manages pending sync state
- Contains:
  - `pendingCount$`: Stream of pending action count
  - `retry`: Function to manually retry syncing

**File: `lib/widgets/common/pending_sync_banner.dart`** (NEW)
- Reusable widget for displaying pending sync status
- Features:
  - Yellow/orange banner with cloud icon
  - Shows count: "Waiting to sync X actions..."
  - "Retry now" button for manual sync
  - Auto-hides when count = 0
  - Responsive to stream updates

**Files Refactored:**
- `lib/controller/WorkOrder/pending_sync.dart` - Now exports shared version
- `lib/controller/WorkOrder/widgets/pending_sync_banner.dart` - Now exports shared version

### 2. Enhanced Database Layer (✅ DONE)

**File: `lib/data/local/offline_database.dart`**
- Updated `getPPMPendingActions()` to accept optional `ppmTaskId` parameter
- Allows filtering pending actions by specific task or all tasks
- Already had `getPPMPendingActionCount()` method (no changes needed)

### 3. Enhanced Repository Layer (✅ DONE)

**File: `lib/data/repository/ppm_repository.dart`**
- Added `getPendingActionCount({String? ppmTaskId})` method
- Added `getPendingActions({String? ppmTaskId})` method
- These methods wrap the database calls for easier access

### 4. Updated Task View (✅ DONE)

**File: `lib/controller/PPM/task_view.dart`**

**Added:**
- Import statements for `PendingSyncController`, `PendingSyncIndicator`, and `rxdart`
- `_pendingSyncController`: Controller instance
- `_pendingCount`: BehaviorSubject to manage pending count stream
- `_refreshPendingCount()`: Refreshes the pending action count
- `_retryPendingSync()`: Manually triggers sync and refreshes list
- `dispose()`: Properly closes the pending count stream

**Modified:**
- `initState()`: Now calls `_refreshPendingCount()` on startup
- `_fetch()`: Syncs pending actions before fetching (when online)
- `_loadOfflineTasks()`: Refreshes pending count when loading offline tasks
- `build()`: Integrated `PendingSyncIndicator` as first item in ListView when online

## How It Works

### Visual Appearance

When there are pending actions, users see:

```
┌────────────────────────────────────────────────────────────┐
│ 🌥️  Waiting to sync 3 actions. We'll retry automatically  │
│     when you're back online.                   [Retry now] │
└────────────────────────────────────────────────────────────┘
```

### User Flow

1. **Online Mode:**
   - Banner appears at top of list if there are pending actions
   - Shows count of actions waiting to sync
   - User can tap "Retry now" to manually trigger sync
   - Auto-syncs on app resume/refresh

2. **Offline Mode:**
   - Banner hidden (no retry possible when offline)
   - Actions queue locally in `ppm_pending_actions` table
   - User continues working normally

3. **Back Online:**
   - App automatically syncs pending actions on refresh
   - Banner updates in real-time as actions sync
   - Banner disappears when count reaches 0

### Technical Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     User Opens Task List                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  _refreshPendingCount() → Query ppm_pending_actions table   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│     _pendingCount.add(count) → Stream updates widget        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  PendingSyncIndicator listens to stream and shows banner    │
│  - count > 0: Show yellow banner with count                 │
│  - count = 0: Hide banner (SizedBox.shrink())               │
└─────────────────────────────────────────────────────────────┘
```

### When Count Updates

The pending count refreshes in these scenarios:

1. ✅ On app startup (`initState()`)
2. ✅ After syncing pending actions (`_retryPendingSync()`)
3. ✅ After fetching tasks online (`_fetch()`)
4. ✅ When loading offline tasks (`_loadOfflineTasks()`)
5. ✅ On manual retry button tap

## Database Structure

The pending actions are stored in `ppm_pending_actions` table:

```sql
CREATE TABLE ppm_pending_actions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ppm_task_id TEXT NOT NULL,
  action TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  created_at TEXT NOT NULL
)
```

## Testing Checklist

### Manual Testing Steps

1. **Test Pending Sync Banner Visibility:**
   - [ ] Enable offline mode for a task
   - [ ] Make changes (add images, update form)
   - [ ] Go back to task list
   - [ ] Verify banner shows "Waiting to sync X actions"

2. **Test Manual Retry:**
   - [ ] While offline, tap "Retry now"
   - [ ] Should show "Still offline" toast
   - [ ] While online, tap "Retry now"
   - [ ] Banner should update/disappear after sync

3. **Test Auto-Sync on Refresh:**
   - [ ] Have pending actions in queue
   - [ ] Go back online
   - [ ] Pull to refresh task list
   - [ ] Verify banner disappears as actions sync

4. **Test Banner Auto-Hide:**
   - [ ] Ensure banner shows when count > 0
   - [ ] Verify banner auto-hides when count = 0
   - [ ] Should not leave empty space

5. **Test Offline Mode:**
   - [ ] Go offline (airplane mode)
   - [ ] Verify banner doesn't show (can't retry when offline)
   - [ ] Make changes to task
   - [ ] Actions should queue silently

6. **Test Multi-Task Scenario:**
   - [ ] Enable offline mode for 3 tasks
   - [ ] Make changes to all 3 tasks
   - [ ] Verify banner shows total count across all tasks
   - [ ] Sync should process all pending actions

## Code Quality

- ✅ No compilation errors
- ✅ Follows existing WO pattern
- ✅ Reusable components (shared between WO and PPM)
- ✅ Proper stream management (closes in dispose)
- ✅ Proper null safety
- ✅ Debug logging for troubleshooting

## Files Modified Summary

### New Files (3)
1. `lib/utils/pending_sync_controller.dart` - Shared controller
2. `lib/widgets/common/pending_sync_banner.dart` - Shared widget
3. `PPM_PENDING_SYNC_IMPLEMENTATION.md` - This documentation

### Modified Files (5)
1. `lib/controller/PPM/task_view.dart` - Integrated pending sync indicator
2. `lib/data/repository/ppm_repository.dart` - Added pending count methods
3. `lib/data/local/offline_database.dart` - Enhanced getPPMPendingActions
4. `lib/controller/WorkOrder/pending_sync.dart` - Refactored to export shared
5. `lib/controller/WorkOrder/widgets/pending_sync_banner.dart` - Refactored to export shared

## Next Steps

1. **Test the implementation:**
   ```bash
   flutter run
   ```

2. **Test offline workflow:**
   - Enable offline mode for a task
   - Make changes while online
   - Go offline
   - Verify banner shows pending actions
   - Go back online
   - Verify auto-sync works

3. **Optional Enhancements (Future):**
   - [ ] Add detailed pending actions list (show what's pending)
   - [ ] Add sync progress indicator
   - [ ] Add conflict resolution UI
   - [ ] Add manual action deletion option

## Benefits

1. ✅ **User Visibility**: Users know what's pending sync
2. ✅ **Manual Control**: Users can trigger sync manually
3. ✅ **Consistent UX**: Same pattern as Work Order
4. ✅ **Code Reuse**: Shared components reduce duplication
5. ✅ **Maintainability**: Changes to banner affect both WO and PPM

---

**Implementation Date**: October 30, 2025
**Status**: ✅ COMPLETE - Ready for testing
