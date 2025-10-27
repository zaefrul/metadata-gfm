# Offline Mode Debugging Guide

## Issue Summary
User reports that after enabling offline mode, closing the app, and reopening in airplane mode, the work order sections are not visible—only the SLA timer box appears.

## Investigation Results

### Test Results ✅
The automated test `test/offline_reopen_scenario_test.dart` **PASSES**, which confirms:
- ✅ Sections ARE being cached when offline mode is enabled
- ✅ Offline mode flag persists in the database after app restart  
- ✅ Repository correctly loads cached sections when `getSections()` is called
- ✅ No network call is made when in airplane mode—cache is used

### Added Debug Logging
To help identify where the UI issue occurs, comprehensive logging has been added:

**In `WorkOrderDetailRepository.getSections()`:**
- Logs cache status: `hasCache`, `forcedOffline`, `forceRefresh`
- Logs section count when returning from cache
- Logs when attempting remote refresh
- Logs when falling back to cache after network failure

**In `MainBloc._load()`:**
- Logs when load starts with parameters
- Logs offline mode state
- Logs successful section load with count
- Logs errors with full stack trace
- Logs when empty list is seeded to stream

## How to Reproduce & Debug

### Step 1: Enable Debug Mode
Run the app in debug mode (not release):
```bash
flutter run --dart-define=APP_VARIANT=classic
```

### Step 2: Enable Offline Mode
1. Open app and navigate to: **Work Order → My Tasks**
2. Select any task with status "In Progress"
3. Tap the "Enable Offline Mode" button
4. **Watch the logs** - you should see:
   ```
   getSections(WO-XXX): hasCache=true (X items), forcedOffline=true, forceRefresh=false
   getSections: Returning X cached sections
   MainBloc._load: Successfully loaded X sections
   ```

### Step 3: Close App & Enable Airplane Mode
1. Close the app completely (swipe away from recent apps)
2. Enable airplane mode on the device
3. Wait a few seconds

### Step 4: Reopen App & Navigate to Task
1. Open the app
2. Navigate to: **Work Order → My Tasks → Available Offline**
3. Select the same task
4. **Watch the logs carefully** - you should see:
   ```
   MainBloc._load: workOrderId=WO-XXX, forceRefresh=false
   MainBloc._load: forcedOffline=true
   getSections(WO-XXX): hasCache=true (X items), forcedOffline=true, forceRefresh=false
   getSections: Returning X cached sections
   MainBloc._load: Successfully loaded X sections
   ```

### Step 5: Check UI State
If the sections are **still not visible** despite successful logging, check:

1. **StreamBuilder state**: Is `snapshot.hasData` true?
2. **Section count**: Is `sections.length` > 0?
3. **List rendering**: Is `ListView.builder` being called with correct itemCount?

## Possible Root Causes

Based on the test results, the issue is **NOT** in the repository or database layer. The problem is likely one of:

### Hypothesis 1: Stream Timing Issue
The `StreamBuilder` in `complaintSection_v2.dart` might be subscribing to `_bloc.sections$` **before** the initial cached data is loaded.

**Check:** Does the loading indicator appear briefly before sections load?

**Solution:** The `BehaviorSubject` is seeded with `const []`, so `snapshot.hasData` is always true, even when empty. The UI should check `sections.isNotEmpty` instead.

### Hypothesis 2: UI State Not Updating
The `_updateSections()` method might be called, but the UI doesn't rebuild.

**Check logs for:**
```
MainBloc._load: Successfully loaded X sections
```
If you see this but UI doesn't update, it's a Flutter state management issue.

### Hypothesis 3: Error Swallowed Silently
An exception might be thrown that's caught and logged, but sections stream never gets updated.

**Check logs for:**
```
Failed to load sections: <error>
```

## Quick Fix Attempt

If sections ARE being loaded but UI shows empty, try adding this check in `complaintSection_v2.dart`:

```dart
StreamBuilder<List<WorkOrderStatus>>(
  stream: _bloc.sections$,
  builder: (ctx, snapshot) {
    if (!snapshot.hasData) {
      return Center(child: CircularProgressIndicator());
    }
    final sections = snapshot.data!;
    
    // ADD THIS DEBUG LOG
    debugPrint('UI: Rendering ${sections.length} sections');
    
    // ADD THIS EMPTY STATE CHECK
    if (sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No sections available'),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // ... rest of the UI
```

## Next Steps

1. **Run with logging** and share the complete logs from steps 1-4
2. **Check if** the log shows "Successfully loaded X sections" where X > 0
3. **If yes**: The issue is in the UI rendering layer
4. **If no**: Share the error message from the logs

## Test Command
Run the automated test to verify the data layer:
```bash
flutter test test/offline_reopen_scenario_test.dart
```

This test simulates the exact user scenario and **should pass**. If it fails, that indicates a real data layer issue.
