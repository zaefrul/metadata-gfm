# Biometric UX Fix - System Picker Support

## Problem Statement

When users trigger native pickers (camera, gallery, file selector) within the app, the biometric authentication prompt appears when the picker closes. This creates a confusing user experience because:

1. **User's perspective**: "I'm still in the app, just taking a photo"
2. **System's perspective**: App went to `paused` → `resumed` lifecycle, triggering biometric lock
3. **Result**: Unexpected authentication prompt that feels like a bug

### Example User Flow (BEFORE Fix)

```
1. User viewing Work Order Section D (Response Images)
2. User taps "Add Photo" button
3. Camera app opens ✅
4. User takes photo
5. Camera closes, returning to app
6. ❌ BIOMETRIC PROMPT APPEARS ← Unexpected!
7. User confused: "Why do I need to authenticate? I never left the app"
```

## Solution Overview

Implemented `BiometricLockManager` utility that **suppresses** biometric re-authentication when opening system pickers. The app now distinguishes between:

- ✅ **System Picker**: Camera/Gallery/File selector opened as part of app workflow → No biometric prompt
- ✅ **App Switch**: User actually leaves app (home button, app switcher) → Biometric prompt required

### User Flow (AFTER Fix)

```
1. User viewing Work Order Section D (Response Images)
2. User taps "Add Photo" button
3. Camera app opens ✅
4. User takes photo
5. Camera closes, returning to app
6. ✅ NO BIOMETRIC PROMPT ← Seamless experience!
7. User continues working
```

---

## Implementation Details

### 1. BiometricLockManager Utility

**File**: `lib/utils/biometric_lock_manager.dart`

**Purpose**: Centralized manager to suppress biometric lock for system picker operations

**Key Methods**:

```dart
// Suppress next biometric prompt
BiometricLockManager.suppressNextLock();

// Wrapper methods (recommended)
final image = await BiometricLockManager.pickImage(source: ImageSource.camera);
final file = await BiometricLockManager.pickFile();
final savePath = await BiometricLockManager.saveFile(fileName: 'export.txt');
```

**How it works**:
1. Before opening picker, call `suppressNextLock()` to set internal flag
2. When app goes to `paused` state, lifecycle handler checks flag
3. If flag is set, skip setting `_shouldLockOnResume = true`
4. When app resumes, no biometric prompt
5. Flag automatically resets after use

### 2. Main App Lifecycle Handler

**File**: `lib/main.dart`

**Modified**: `didChangeAppLifecycleState()`

**Change**:
```dart
// BEFORE
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
    _shouldLockOnResume = true;  // ← Always locks
  } else if (state == AppLifecycleState.resumed && _shouldLockOnResume) {
    _handleResume();
  }
}

// AFTER
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
    // Only lock if NOT opening system picker
    if (!BiometricLockManager.shouldSuppressAndReset()) {
      _shouldLockOnResume = true;
    }
  } else if (state == AppLifecycleState.resumed && _shouldLockOnResume) {
    _handleResume();
  }
}
```

---

## Files Modified

### Core Implementation
- ✅ `lib/utils/biometric_lock_manager.dart` - **NEW** utility class
- ✅ `lib/main.dart` - Updated lifecycle handler

### Updated Components (Using Wrapper)
- ✅ `lib/controller/WorkOrder/complaintSectionResponseImage.dart` - Section D response images
- ✅ `lib/utils/image_compressor.dart` - Image compression utility
- ✅ `lib/view/debug_log_screen.dart` - Debug log export

### Pending Migration (Need Manual Update)

These files still use direct `ImagePicker()/FilePicker` calls and should be migrated:

1. **Work Order Screens**:
   - `lib/controller/WorkOrder/complaintForm.dart` (line 482)
   - `lib/controller/WorkOrder/complaintSectionC.dart` (line 462)

2. **PPM Screens**:
   - `lib/controller/PPM/Form/formH.dart` (line 431)
   - `lib/controller/PPM/Form/formHV2.dart` (line 364)
   - `lib/controller/PPM/Form/formF.dart` (line 238)

3. **Utilities Screens**:
   - `lib/controller/Utilities/ElectricBill.dart` (line 279)
   - `lib/controller/Utilities/WaterBill.dart` (line 286)

4. **Storekeeper Screens**:
   - `lib/controller/Storekeeper/utils/bloc/bloc_checkin.dart` (line 236)

---

## Migration Guide for Developers

### Option 1: Use Wrapper Methods (Recommended)

**BEFORE**:
```dart
final picked = await ImagePicker().pickImage(
  source: ImageSource.camera,
  imageQuality: 85,
);
```

**AFTER**:
```dart
import 'package:GEMS/utils/biometric_lock_manager.dart';

final picked = await BiometricLockManager.pickImage(
  source: ImageSource.camera,
  imageQuality: 85,
);
```

### Option 2: Manual Suppression

**BEFORE**:
```dart
final result = await FilePicker.platform.pickFiles(type: FileType.image);
```

**AFTER**:
```dart
import 'package:GEMS/utils/biometric_lock_manager.dart';

BiometricLockManager.suppressNextLock();
final result = await FilePicker.platform.pickFiles(type: FileType.image);
```

### Option 3: Gallery Picker (Not Just Camera)

```dart
// Works for both camera AND gallery
final picked = await BiometricLockManager.pickImage(
  source: ImageSource.gallery,  // ← Gallery picker
);
```

---

## Testing Checklist

### Test Scenarios

#### ✅ Scenario 1: Camera Picker
1. Enable biometric lock in app settings
2. Go offline (enable offline mode for a WO)
3. Navigate to Section D (Response Images)
4. Tap "Add Photo" → Camera opens
5. Take a photo
6. Camera closes
7. **Expected**: No biometric prompt, photo appears in list
8. **Actual**: ✅ Works as expected

#### ✅ Scenario 2: File Save Dialog
1. Enable biometric lock
2. Go to Debug Logs screen (`/debug-logs`)
3. Tap "Export" icon
4. File save dialog opens
5. Choose location and save
6. **Expected**: No biometric prompt
7. **Actual**: ✅ Works as expected

#### ✅ Scenario 3: Actual App Switch (Still Locks)
1. Enable biometric lock
2. Open any screen in GEMS
3. Press home button (or switch to another app)
4. Return to GEMS
5. **Expected**: Biometric prompt SHOULD appear
6. **Actual**: ✅ Works as expected

#### ❌ Scenario 4: Pending Migration (Will Show Biometric)
1. Enable biometric lock
2. Go to Work Order complaint form (`complaintForm.dart`)
3. Tap camera icon
4. Take photo
5. Camera closes
6. **Expected (after migration)**: No biometric prompt
7. **Actual (before migration)**: ❌ Biometric prompt appears (needs fix)

---

## Security Considerations

### Is This Safe?

**Yes** - Security is maintained because:

1. **Suppression is One-Time**: Flag resets immediately after one lifecycle event
2. **Time-Bounded**: Picker operations complete within seconds
3. **No Persistent State**: No way to "disable" biometric lock permanently
4. **Still Locks on Real Switch**: Home button, app switcher, notifications still trigger lock

### Attack Vectors Mitigated

❌ **Cannot bypass**: User can't manually suppress lock (no UI for it)
❌ **Cannot persist**: Flag doesn't survive app restarts
❌ **Cannot chain**: One suppression = one picker operation
✅ **Still locks**: Actual app switches still require authentication

### Edge Cases Handled

1. **User cancels picker**: Flag still resets → Next pause will lock ✅
2. **App crash during picker**: On restart, no suppression active ✅
3. **Multiple pickers in sequence**: Each must call `suppressNextLock()` ✅
4. **Picker timeout**: App resumes, flag already reset ✅

---

## Performance Impact

**Negligible** - Only adds:
- 1 static boolean flag check per lifecycle event
- 1 method call before each picker operation
- **No** database access
- **No** network calls
- **No** heavy computation

---

## Future Improvements

### Phase 2: Auto-Detection (Optional)

Instead of requiring manual `suppressNextLock()` calls, detect picker operations automatically:

```dart
// Intercept ImagePicker/FilePicker via dependency injection
class SmartImagePicker extends ImagePicker {
  @override
  Future<XFile?> pickImage({required ImageSource source, ...}) {
    BiometricLockManager.suppressNextLock();  // Auto-suppress
    return super.pickImage(source: source, ...);
  }
}
```

**Pros**:
- No developer intervention needed
- Automatic for all pickers

**Cons**:
- Requires wrapper for all picker packages
- More complex to maintain

**Decision**: Keep manual approach for now (simpler, explicit)

### Phase 3: User Setting (Optional)

Allow users to configure biometric behavior:

```dart
enum BiometricLockPolicy {
  always,              // Lock on all pauses (current strict mode)
  skipSystemPickers,   // Smart mode (current implementation)
  never,               // Disable biometric lock (not recommended)
}
```

---

## Rollout Plan

### Stage 1: Core Implementation ✅ DONE
- [x] Create `BiometricLockManager`
- [x] Update `main.dart` lifecycle handler
- [x] Update 3 high-traffic screens (Section D, image compressor, debug logs)
- [x] Test with real devices

### Stage 2: Migrate Remaining Screens (IN PROGRESS)
- [ ] Update all Work Order camera usages (3 files)
- [ ] Update all PPM form camera usages (3 files)
- [ ] Update utilities camera usages (2 files)
- [ ] Update storekeeper camera usage (1 file)

### Stage 3: Documentation & Training
- [ ] Update developer onboarding docs
- [ ] Add to `.github/copilot-instructions.md`
- [ ] Create video tutorial for team
- [ ] Add lint rule to enforce wrapper usage

### Stage 4: Production Monitoring
- [ ] Add analytics event: `biometric_suppressed`
- [ ] Track picker-related lifecycle events
- [ ] Monitor for unexpected biometric prompts
- [ ] A/B test with user feedback

---

## Developer FAQ

### Q: Do I always need to use the wrapper?
**A**: Yes, for any ImagePicker/FilePicker call. This ensures consistent UX.

### Q: What if I forget to use the wrapper?
**A**: App still works, but users will see the biometric prompt (annoying but not broken).

### Q: Can I suppress biometric for other operations?
**A**: Only for system pickers. Don't suppress for actual navigation or deep links.

### Q: Does this work on both iOS and Android?
**A**: Yes, lifecycle events are cross-platform.

### Q: What about third-party camera plugins?
**A**: If they trigger app pause, use `suppressNextLock()` before calling them.

### Q: How do I test this locally?
**A**: 
1. Enable biometric in Profile settings
2. Use a real device (simulators don't have biometric)
3. Take a photo and observe - no prompt should appear

---

## Related Issues & PRs

- **Issue**: Users confused by biometric prompt when taking photos
- **PR**: [Link to PR implementing this fix]
- **Discussion**: System pickers should not trigger authentication
- **Related**: Offline mode image sync bug (different issue)

---

## Contact

**Questions?** Ask in:
- Slack: #gems-mobile-dev
- Email: mobile-team@company.com
- Code review: Tag @mobile-lead

**Bug Reports**: If biometric prompt still appears for pickers after this fix, report with:
1. Device model & OS version
2. Steps to reproduce
3. Which screen/picker triggered it
4. Debug logs if available

---

## Changelog

**2024-10-26**: Initial implementation
- Created `BiometricLockManager` utility
- Updated main app lifecycle handler
- Migrated 3 critical screens (Section D images, image compressor, debug logs)
- Added comprehensive documentation

**Future**:
- Migrate remaining 9 screens
- Add analytics tracking
- Consider auto-detection for Phase 2
