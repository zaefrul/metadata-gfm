# Secret Debug Menu Implementation

**Date:** 10 November 2025  
**Feature:** Hidden developer tools accessible by tapping version number  

---

## Overview

Implemented a secret debug menu that's hidden from regular users but accessible to developers by tapping the version number on the homepage 10 times.

---

## Implementation Details

### 1. Secret Debug Menu Screen (`lib/view/secret_debug_menu.dart`)

New screen with developer tools:
- **API Test** - Test Return Items API with current session
- **Debug Logs** - View app console logs and errors
- Clean, professional UI with orange theme to indicate developer mode
- Information cards explaining access method and warnings

### 2. Homepage Tap Counter (`lib/controller/Homepage/homepage.dart`)

Added state variables:
```dart
int _versionTapCount = 0; // Secret debug menu tap counter
```

Added tap handler method:
```dart
void _onVersionTap() {
  setState(() {
    _versionTapCount++;
  });

  // Show countdown toast for last 4 taps (6, 7, 8, 9)
  if (_versionTapCount >= 6 && _versionTapCount <= 9) {
    int remaining = 10 - _versionTapCount;
    Toast.show(
      "Navigate to debug menu in $remaining",
      duration: Toast.lengthShort,
      gravity: Toast.bottom,
    );
  } 
  // Navigate on 10th tap
  else if (_versionTapCount == 10) {
    _versionTapCount = 0; // Reset counter
    Toast.show(
      "🔓 Debug menu unlocked!",
      duration: Toast.lengthShort,
      gravity: Toast.bottom,
    );
    Navigator.pushNamed(context, '/secret-debug-menu');
  }

  // Reset counter after 2 seconds of inactivity
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted && _versionTapCount < 10) {
      setState(() {
        _versionTapCount = 0;
      });
    }
  });
}
```

Made version text tappable:
```dart
GestureDetector(
  onTap: _onVersionTap,
  child: Text(
    'Version: $_appVersion',
    style: GoogleFonts.poppins(
      fontSize: 12,
      color: Colors.black54,
    ),
  ),
)
```

### 3. Removed Public Debug Menu Items

Cleaned up drawer menu (`lib/view/drawer.dart`):
- ❌ Removed "🔬 API Test" menu item
- ❌ Removed "Debug Logs" menu item
- ✅ Both now only accessible through secret menu

### 4. Route Registration (`lib/main.dart`)

Added route:
```dart
case '/secret-debug-menu':
  return MaterialPageRoute(
      builder: (_) => SecretDebugMenu(), settings: settings);
```

---

## User Experience Flow

### Accessing Debug Menu

1. Open app and login
2. Navigate to Homepage
3. Tap on "Version: X.X.X" at the bottom of the screen
4. Keep tapping... (no feedback for first 5 taps)
5. On tap 6: Toast shows "Navigate to debug menu in 4"
6. On tap 7: Toast shows "Navigate to debug menu in 3"
7. On tap 8: Toast shows "Navigate to debug menu in 2"
8. On tap 9: Toast shows "Navigate to debug menu in 1"
9. On tap 10: Toast shows "🔓 Debug menu unlocked!" and navigates to secret menu
10. Counter resets after 2 seconds of inactivity

### Debug Menu Features

From the secret menu, developers can access:
1. **API Test** - Opens API test screen with live session token testing
2. **Debug Logs** - Opens debug log viewer with all console output

---

## Security Considerations

### Why This Approach?

1. **Hidden from users** - No visible menu items or obvious UI elements
2. **Not accidental** - Requires 10 deliberate taps, unlikely to happen by chance
3. **User feedback** - Shows countdown for last 4 taps so developer knows progress
4. **Auto-reset** - Counter resets after 2 seconds to prevent accidental activation
5. **Professional look** - Secret menu has proper UI, not a dev hack

### What's Protected?

- API testing tools (could expose backend structure)
- Debug logs (may contain sensitive data like tokens)
- Developer-only features not meant for production users

---

## Testing

### Test the Secret Access

1. Launch app
2. Login with any account
3. Go to Homepage
4. Find version number at bottom (e.g., "Version: 1.0.0")
5. Tap it 10 times quickly
6. Observe:
   - No toast for taps 1-5
   - Countdown toast for taps 6-9
   - "Debug menu unlocked!" toast on tap 10
   - Navigation to Secret Debug Menu screen

### Test Auto-Reset

1. Tap version number 5 times
2. Wait 3 seconds
3. Tap again - should be back to tap 1 (no countdown toast)

### Test Debug Menu Features

1. Access secret menu
2. Tap "API Test" - should open API test screen
3. Go back, tap "Debug Logs" - should open debug log screen

---

## Files Changed

1. ✅ `lib/view/secret_debug_menu.dart` - New secret debug menu screen
2. ✅ `lib/controller/Homepage/homepage.dart` - Added tap counter and handler
3. ✅ `lib/view/drawer.dart` - Removed public debug menu items
4. ✅ `lib/main.dart` - Added `/secret-debug-menu` route

---

## Future Enhancements

Possible additions to the secret menu:
- **Feature Flags** - Toggle experimental features
- **Environment Switcher** - Switch between dev/staging/prod backends
- **Cache Manager** - Clear offline data, view cache stats
- **User Impersonation** - Test as different user roles
- **Performance Monitor** - View memory, network stats
- **Mock Data Generator** - Create test work orders, materials

---

## Usage Notes

- The secret menu is **always available** in all app variants (classic/client)
- Access method is consistent across all screens (tap version number)
- Debug tools use current session, no separate authentication needed
- Counter state is not persisted - resets on app restart

---

## Maintenance

### To Add New Debug Tools

1. Add new card to `secret_debug_menu.dart`:
```dart
_buildDebugCard(
  context,
  icon: Icons.your_icon,
  title: 'Tool Name',
  subtitle: 'Description',
  color: Colors.purple,
  onTap: () {
    Navigator.pushNamed(context, '/your-route');
  },
)
```

2. Register route in `main.dart`
3. Create your debug screen

### To Change Tap Count

Modify the constant in `_onVersionTap()`:
```dart
if (_versionTapCount >= 6 && _versionTapCount <= 9) { // Start countdown at tap 6
  int remaining = 10 - _versionTapCount; // Total taps = 10
  ...
} else if (_versionTapCount == 10) { // Activate on tap 10
```

### To Change Auto-Reset Duration

Modify the delay:
```dart
Future.delayed(const Duration(seconds: 2), () { // Change from 2 seconds
```

---

**Status:** ✅ Complete and Ready for Testing
