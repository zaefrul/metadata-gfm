# Offline Mode Section Loading - Investigation Summary

## Problem Statement
User reports that after:
1. Enabling offline mode for a work order task
2. Closing the app completely
3. Turning on airplane mode
4. Reopening the app and navigating to the offline task

The sections are not visible—only the SLA timer box shows up.

## Investigation Results

### ✅ Data Layer Works Correctly
Created comprehensive test (`test/offline_reopen_scenario_test.dart`) that simulates the EXACT user scenario:
```
=== STEP 1: Enable offline mode ===
Offline mode enabled: true
Cached sections count: 3

=== STEP 2: Simulate app close (repository recreated) ===

=== STEP 3: Reopen app in airplane mode ===
Offline mode after restart: true

=== STEP 4: Load sections (should use cache, not network) ===
getSections(WO-OFFLINE-TEST): hasCache=true (3 items), forcedOffline=true, forceRefresh=false
getSections: Returning 3 cached sections
Sections loaded: 3
  - Section A: General Information (Pending)
  - Section B: Work Assignment (Pending)
  - Section C: Work Execution (Pending)

=== TEST PASSED: Sections available offline after restart ===
```

**Conclusion**: The repository layer is working perfectly. Cached sections are retrieved successfully.

## Changes Made

### 1. Enhanced Logging in `WorkOrderDetailRepository.getSections()`
```dart
debugPrint('getSections($workOrderId): hasCache=$hasCache (${cachedEntities.length} items), forcedOffline=$forcedOffline, forceRefresh=$forceRefresh');
```

This helps track:
- Whether cache exists
- Whether offline mode is enabled
- Whether force refresh is requested
- How many sections are being returned

### 2. Enhanced Logging in `MainBloc._load()`
```dart
debugPrint('MainBloc._load: workOrderId=$_id, forceRefresh=$forceRefresh');
debugPrint('MainBloc._load: forcedOffline=$forcedOffline');
debugPrint('MainBloc._load: Successfully loaded ${data.length} sections');
```

This helps track:
- When sections are loaded
- Offline mode state
- Section count
- Any errors that occur

### 3. Enhanced Logging in `complaintSection_v2.dart` UI
```dart
debugPrint('ComplaintSection UI: snapshot.hasData=${snapshot.hasData}, data=${snapshot.data?.length ?? "null"}');
debugPrint('ComplaintSection UI: Rendering ${sections.length} sections');
```

This helps track:
- Whether the stream has emitted data
- How many sections the UI receives
- Whether the UI updates when data arrives

### 4. Added Empty State Handling
Added explicit check for empty sections with user-friendly message:
```dart
if (sections.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('Loading sections...'),
        // ...
      ],
    ),
  );
}
```

## Debugging Steps for User

### Run in Debug Mode
```bash
flutter run --dart-define=APP_VARIANT=classic
```

### Watch Console Logs
When you reproduce the issue, watch for these log messages:

**Expected flow when opening offline task:**
```
MainBloc._load: workOrderId=WO-XXX, forceRefresh=false
MainBloc._load: forcedOffline=true
getSections(WO-XXX): hasCache=true (X items), forcedOffline=true, forceRefresh=false
getSections: Returning X cached sections
MainBloc._load: Successfully loaded X sections
ComplaintSection UI: snapshot.hasData=true, data=X
ComplaintSection UI: Rendering X sections
```

### Possible Outcomes

#### Outcome A: Logs show sections loaded but UI is empty
```
MainBloc._load: Successfully loaded 3 sections
ComplaintSection UI: snapshot.hasData=true, data=0
ComplaintSection UI: Rendering 0 sections
```
**Issue**: Sections are loaded in MainBloc but not reaching the UI stream
**Likely cause**: Stream update issue in `_updateSections()`

#### Outcome B: Repository returns empty cache
```
getSections(WO-XXX): hasCache=false (0 items), forcedOffline=true, forceRefresh=false
```
**Issue**: Sections were not cached when offline mode was enabled
**Likely cause**: `setOfflineMode()` or `replaceSections()` failed

#### Outcome C: Network call attempted in airplane mode
```
getSections: Attempting remote refresh...
Failed to load sections: SocketException...
```
**Issue**: Offline mode flag not set correctly
**Likely cause**: `setWorkOrderOfflineMode()` didn't persist

#### Outcome D: Everything logs correctly but UI shows empty
```
MainBloc._load: Successfully loaded 3 sections
ComplaintSection UI: snapshot.hasData=true, data=3
ComplaintSection UI: Rendering 3 sections
[But user still sees empty screen]
```
**Issue**: ListView rendering problem or Z-index issue
**Likely cause**: Widget tree layout issue

## Next Steps

1. **Run the app with these changes** and reproduce the issue
2. **Copy all console logs** from the moment you open the offline task
3. **Share the logs** so we can see which of the above outcomes occurred
4. Based on the outcome, we'll know exactly where to fix

## Files Changed
- `lib/data/repository/work_order_detail_repository.dart` - Added cache/offline logging
- `lib/controller/WorkOrder/bloc/mainBloc.dart` - Added load flow logging
- `lib/controller/WorkOrder/complaintSection_v2.dart` - Added UI state logging + empty state handling
- `test/offline_reopen_scenario_test.dart` - Comprehensive test proving data layer works
- `OFFLINE_DEBUG_GUIDE.md` - User-facing debugging guide

## Test Commands
```bash
# Run the offline scenario test (should pass)
flutter test test/offline_reopen_scenario_test.dart

# Run all offline tests
flutter test test/offline_section_cache_test.dart test/offline_reopen_scenario_test.dart
```
