# GEMS App Variants - Apple Compliance Guide

## Overview

This setup allows you to build different variants of the GEMS app while using the same bundle ident# Get app display name
String appName = AppConfig.appDisplayName; // "GEMS 2.0" or "GEMS 2.0 Client"ier (`com.GFM.GEMS`) to comply with Apple's App Store requirements. Apple requires that apps with the same functionality use the same bundle identifier.

## Bundle Identifier Compliance

✅ **Both variants use:** `com.GFM.GEMS`
✅ **Apple compliant:** Same bundle ID for same functionality
✅ **Different app names:** "GEMS 2.0" vs "GEMS 2.0 Client"
✅ **Different features:** Classic (basic) vs Client (premium)

## App Variants

### 1. Classic Variant (`classic`)
- **Display Name:** GEMS 2.0
- **Subtitle:** Classic
- **Theme:** Teal/Cyan (#58c2c4)
- **Features:** Basic functionality only
- **Target:** Standard users
- **Watermark:** None

### 2. Client Variant (`client`)
- **Display Name:** GEMS 2.0 Client
- **Subtitle:** Client Version
- **Theme:** Blue (#2367f6)
- **Features:** All premium features enabled
- **Target:** Premium clients
- **Watermark:** "CLIENT" text overlay

## Building Different Variants

### Using Build Script (Recommended)

```bash
# Build Classic variant AAB for Play Store
./build_variants.sh classic-aab

# Build Client variant AAB for Play Store
./build_variants.sh client-aab

# Build both Android variants
./build_variants.sh all-android

# Build iOS variants
./build_variants.sh classic-ios
./build_variants.sh client-ios

# Build everything
./build_variants.sh all

# Clean builds
./build_variants.sh clean
```

### Manual Flutter Commands

```bash
# Classic variant
flutter build appbundle --dart-define=APP_VARIANT=classic --release
flutter build apk --dart-define=APP_VARIANT=classic --release
flutter build ios --dart-define=APP_VARIANT=classic --release

# Client variant
flutter build appbundle --dart-define=APP_VARIANT=client --release
flutter build apk --dart-define=APP_VARIANT=client --release
flutter build ios --dart-define=APP_VARIANT=client --release
```

## Configuration Details

### App Features by Variant

| Feature | Classic | Client |
|---------|---------|--------|
| Advanced Reporting | ❌ | ✅ |
| Custom Dashboard | ❌ | ✅ |
| Premium Support | ❌ | ✅ |
| Bulk Operations | ❌ | ✅ |
| Analytics Insights | ❌ | ✅ |

### Theme Configuration

| Property | Classic | Client |
|----------|---------|--------|
| Primary Color | #58c2c4 (Teal) | #2367f6 (Blue) |
| Accent Color | #022c41 (Dark Blue) | #022c41 (Dark Blue) |
| Watermark | None | "CLIENT" |

## Implementation Architecture

### Configuration System
- **File:** `lib/config/app_config.dart`
- **Method:** Dart environment variables (`--dart-define`)
- **Runtime:** Configuration determined at build time

### Bundle Identifier Strategy
- **Android:** `com.GFM.GEMS` (in `android/app/build.gradle`)
- **iOS:** `com.GFM.GEMS` (in iOS project settings)
- **Compliance:** Single bundle ID for both variants

### Build Output
- **Classic AAB:** `app-classic-release.aab`
- **Client AAB:** `app-client-release.aab`
- **Both use same bundle ID internally**

## Deployment Strategy

### Play Store Deployment
1. **Option A - Internal Testing Tracks:**
   - Upload Classic to "Internal Testing"
   - Upload Client to "Alpha" track
   - Both share same package name

2. **Option B - Multiple Release Versions:**
   - Release Classic as v1.0.0
   - Release Client as v1.1.0 (with premium features)

### App Store Deployment
1. **Compliant with Apple requirements**
2. **Same bundle identifier:** `com.GFM.GEMS`
3. **Different app display names**
4. **Can be distributed as separate builds**

## Development Workflow

### Testing Different Variants
```bash
# Test Classic
flutter run --dart-define=APP_VARIANT=classic

# Test Client
flutter run --dart-define=APP_VARIANT=client
```

### Adding New Features
1. Edit `lib/config/app_config.dart`
2. Add feature flags in `features` map
3. Use `AppConfig.features['featureName']` in code
4. Test both variants

### Adding New Themes
1. Edit `themeConfig` in `app_config.dart`
2. Add color definitions
3. Update UI components to use config

## Code Usage Examples

### Feature Checks
```dart
import 'package:GEMS/config/app_config.dart';

// Check if premium feature is enabled
if (AppConfig.features['advancedReporting'] == true) {
  // Show advanced reporting UI
}

// Get app display name
String appName = AppConfig.appDisplayName; // "GEMS" or "GEMS Client"
```

### Theme Usage
```dart
// Get theme colors
var themeConfig = AppConfig.themeConfig;
Color primaryColor = Color(themeConfig['primaryColor']);

// Check if watermark should be shown
if (themeConfig['showWatermark'] == true) {
  // Show watermark with text: themeConfig['watermarkText']
}
```

## Troubleshooting

### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
./build_variants.sh clean
```

### Configuration Not Working
- Check `--dart-define=APP_VARIANT=variant` is specified
- Verify `APP_VARIANT` environment variable is set correctly
- Restart app/rebuild after configuration changes

### Bundle ID Conflicts
- Ensure both variants use `com.GFM.GEMS`
- Check Android `applicationId` in `build.gradle`
- Verify iOS `PRODUCT_BUNDLE_IDENTIFIER` in Xcode

## Benefits of This Approach

✅ **Apple Compliant:** Same bundle ID for same functionality
✅ **Play Store Compatible:** Different versions possible
✅ **Maintainable:** Single codebase with configuration
✅ **Flexible:** Easy to add new variants or features
✅ **Testable:** Can test different variants locally
✅ **Future-proof:** Easy to modify without breaking compliance

This approach ensures compliance with both Apple and Google store requirements while maintaining development efficiency.
