# 📱 GEMS 2.0 - Build, Deploy & Maintenance Guide

> Complete guide for building, publishing, and maintaining the GEMS 2.0 (GFM Enterprise Management System) Flutter application

## 📋 Table of Contents

- [🚀 Quick Start](#-quick-start)
- [🔧 Build Instructions](#-build-instructions)
- [📦 App Store Publishing](#-app-store-publishing)
- [🎨 Customization Guide](#-customization-guide)
- [🔄 App Variants](#-app-variants)
- [🛠️ Maintenance Tasks](#️-maintenance-tasks)
- [🐛 Troubleshooting](#-troubleshooting)
- [📚 Reference](#-reference)

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Xcode (for iOS builds)
- Android Studio (for Android builds)
- Apple Developer Account (for App Store)
- Google Play Developer Account (for Play Store)

### Initial Setup
```bash
# Clone the repository
git clone <repository-url>
cd metadata-gfm

# Install dependencies
flutter pub get

# Check Flutter setup
flutter doctor
```

---

## 🔧 Build Instructions

### 📱 Android Builds

#### 🎯 Quick Commands
```bash
# Build Classic AAB (recommended for Play Store)
./build_variants.sh classic-aab

# Build Client AAB (premium version)
./build_variants.sh client-aab

# Build both Android variants
./build_variants.sh all-android
```

#### 📋 Manual Commands
```bash
# Classic variant
flutter build appbundle --dart-define=APP_VARIANT=classic --release

# Client variant  
flutter build appbundle --dart-define=APP_VARIANT=client --release

# Debug APK for testing
flutter build apk --dart-define=APP_VARIANT=classic --debug
```

#### 📁 Output Locations
```
build/app/outputs/bundle/release/
├── app-classic-release.aab    ← Use this for Play Store
├── app-client-release.aab     ← Premium version
└── app-release.aab           ← Don't use (unversioned)

build/app/outputs/flutter-apk/
├── app-classic-release.apk    ← For testing/sideloading
└── app-client-release.apk     ← Premium testing version
```

### 🍎 iOS Builds

#### 🎯 Quick Commands
```bash
# Open Xcode workspace
open ios/Runner.xcworkspace

# Build Classic iOS
./build_variants.sh classic-ios

# Build Client iOS
./build_variants.sh client-ios
```

#### 📋 Manual Commands
```bash
# Classic variant
flutter build ios --dart-define=APP_VARIANT=classic --release

# Client variant
flutter build ios --dart-define=APP_VARIANT=client --release
```

#### 🏗️ Xcode Archive Process
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Generic iOS Device** as target
3. Go to **Product → Archive**
4. Follow archive process for App Store distribution

---

## 📦 App Store Publishing

### 🤖 Google Play Store

#### 📋 Preparation Checklist
- [ ] Built `app-classic-release.aab` or `app-client-release.aab`
- [ ] App signed with release keystore
- [ ] Version number updated in `pubspec.yaml`
- [ ] Store listing prepared
- [ ] Screenshots captured
- [ ] Privacy policy updated

#### 🚀 Upload Process
1. **Go to Google Play Console**
2. **Select your app** or create new app
3. **Upload AAB file** to appropriate track:
   - **Production**: For public release
   - **Internal Testing**: For team testing
   - **Alpha/Beta**: For limited testing
4. **Fill out store listing**:
   - App name: "GEMS 2.0" or "GEMS 2.0 Client"
   - Description: Highlight facilities management features
   - Screenshots: Show key app functionality
   - Privacy policy: Link to your privacy policy

#### 🔐 App Signing
- **Managed by Google Play** (recommended)
- **Use upload key** for signing AAB files
- **Google manages** app signing key

### 🍎 Apple App Store

#### 📋 Preparation Checklist
- [ ] iOS app archived in Xcode
- [ ] Apple Developer account configured
- [ ] Bundle ID registered: `com.GFM.GEMS`
- [ ] Provisioning profiles configured
- [ ] App Store Connect listing prepared

#### 🚀 Upload Process
1. **Archive in Xcode**:
   - Product → Archive
   - Select archive → Distribute App
   - Choose App Store Connect
2. **Upload to App Store Connect**:
   - Wait for processing (10-30 minutes)
   - Configure app information
   - Add screenshots and metadata
3. **Submit for Review**:
   - Select build version
   - Submit for App Store review
   - Review typically takes 24-48 hours

---

## 🎨 Customization Guide

### 🖼️ Changing App Icon

#### 📁 Icon Files Location
```
assets/
└── app_icon.jpg    ← Replace this file (1024x1024 recommended)
```

#### 🔄 Update Process
```bash
# 1. Replace the icon file
cp /path/to/new/icon.jpg assets/app_icon.jpg

# 2. Regenerate launcher icons
flutter pub run flutter_launcher_icons

# 3. Clean and rebuild
flutter clean
flutter pub get
```

#### ⚙️ Icon Configuration
Edit `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/app_icon.jpg"  # Your icon path
  background_color: "#FFFFFF"       # Background for iOS
  remove_alpha_ios: true            # Remove transparency
```

### 📝 Changing App Name

#### 🤖 Android App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Your New App Name"
    ...>
```

#### 🍎 iOS App Name
Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Your New App Name</string>
<key>CFBundleName</key>
<string>Your New App Name</string>
```

#### 🔧 App Configuration
Edit `lib/config/app_config.dart`:
```dart
static String get appDisplayName {
  switch (_appVariant) {
    case client:
      return 'Your App Client';
    case classic:
    default:
      return 'Your App';
  }
}
```

### 🎨 Changing App Theme

#### 🎯 Theme Configuration
Edit `lib/config/app_config.dart`:
```dart
static Map<String, dynamic> get themeConfig {
  switch (_appVariant) {
    case client:
      return {
        'primaryColor': 0xff2367f6,    // Blue theme
        'accentColor': 0xff022c41,
        'showWatermark': true,
        'watermarkText': 'CLIENT'
      };
    case classic:
    default:
      return {
        'primaryColor': 0xff58c2c4,    // Teal theme
        'accentColor': 0xff022c41,
        'showWatermark': false,
        'watermarkText': ''
      };
  }
}
```

### 📦 Changing Bundle Identifier

⚠️ **Warning**: Changing bundle identifier creates a new app in stores!

#### 🤖 Android
Edit `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId = "com.yourcompany.yourapp"
    ...
}
```

#### 🍎 iOS
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project
3. Go to **Signing & Capabilities**
4. Change **Bundle Identifier**

---

## 🔄 App Variants

### 📊 Variant Comparison

| Feature | Classic | Client |
|---------|---------|--------|
| **Display Name** | GEMS 2.0 | GEMS 2.0 Client |
| **Theme Color** | Teal (#58c2c4) | Blue (#2367f6) |
| **Advanced Reporting** | ❌ | ✅ |
| **Custom Dashboard** | ❌ | ✅ |
| **Premium Support** | ❌ | ✅ |
| **Bulk Operations** | ❌ | ✅ |
| **Analytics Insights** | ❌ | ✅ |
| **Watermark** | None | "CLIENT" |

### 🔧 Adding New Variants

#### 1. Update Configuration
Edit `lib/config/app_config.dart`:
```dart
// Add new variant constant
static const String enterprise = 'enterprise';

// Update variant checks
static bool get isEnterprise => _appVariant == enterprise;

// Update app display name
case enterprise:
  return 'GEMS 2.0 Enterprise';

// Update theme configuration
// Update feature flags
```

#### 2. Update Build Script
Edit `build_variants.sh`:
```bash
# Add new build commands
"enterprise-aab")
    build_aab "enterprise"
    ;;
```

### 🚀 Building Specific Variants
```bash
# Test variants locally
flutter run --dart-define=APP_VARIANT=classic
flutter run --dart-define=APP_VARIANT=client

# Build variants
./build_variants.sh classic-aab
./build_variants.sh client-aab
```

---

## 🛠️ Maintenance Tasks

### 📊 Version Management

#### 📝 Updating Version Numbers
Edit `pubspec.yaml`:
```yaml
# Format: major.minor.patch+build
version: 1.0.0+1
```

#### 🔄 Version Increments
```bash
# Patch release (bug fixes)
version: 1.0.1+2

# Minor release (new features)
version: 1.1.0+3

# Major release (breaking changes)
version: 2.0.0+4
```

### 🔐 Certificate Management

#### 🤖 Android Keystore
- **Location**: `android/key.properties`
- **Backup**: Store keystore files safely
- **Renewal**: Update before expiration

#### 🍎 iOS Certificates
- **Managed in**: Apple Developer Portal
- **Types**: Development, Distribution
- **Renewal**: Annual renewal required

### 🔄 Dependencies Updates

#### 📋 Regular Maintenance
```bash
# Check outdated packages
flutter pub outdated

# Update packages
flutter pub upgrade

# Update Flutter SDK
flutter upgrade
```

#### ⚠️ Breaking Changes
1. **Read changelog** before updating major versions
2. **Test thoroughly** after updates
3. **Update minimum SDK** versions if needed

### 🧹 Cleanup Tasks

#### 🗑️ Regular Cleanup
```bash
# Clean build artifacts
flutter clean

# Clear pub cache (if needed)
flutter pub cache clean

# Clean Xcode build (macOS)
cd ios && xcodebuild clean
```

---

## 🐛 Troubleshooting

### 🏗️ Build Issues

#### ❌ "Build failed with Gradle"
```bash
# Solution 1: Clean and rebuild
flutter clean
flutter pub get
flutter build appbundle

# Solution 2: Check Android SDK
flutter doctor

# Solution 3: Update Gradle (if needed)
cd android && ./gradlew clean
```

#### ❌ "iOS build failed"
```bash
# Solution 1: Clean iOS build
cd ios && xcodebuild clean
cd .. && flutter clean
flutter build ios

# Solution 2: Update CocoaPods
cd ios && pod repo update && pod install

# Solution 3: Check Xcode version
flutter doctor
```

#### ❌ "MainActivity not found"
- **Check**: `android/app/src/main/kotlin/com/gfm/gems/v3/MainActivity.kt` exists
- **Verify**: AndroidManifest.xml points to correct activity
- **Fix**: Copy MainActivity from backup if missing

### 🔐 Signing Issues

#### ❌ "App not signed properly"
```bash
# Check keystore configuration
cat android/key.properties

# Verify keystore file exists
ls -la android/app/keystore/

# Build with verbose output
flutter build appbundle --verbose
```

#### ❌ "iOS signing failed"
1. **Check**: Bundle identifier matches Apple Developer Portal
2. **Verify**: Provisioning profiles are valid
3. **Update**: Certificates in Xcode

### 🔧 Configuration Issues

#### ❌ "App variant not working"
```bash
# Verify dart-define parameter
flutter run --dart-define=APP_VARIANT=classic -v

# Check configuration file
cat lib/config/app_config.dart

# Test locally first
flutter run --dart-define=APP_VARIANT=classic
```

### 📱 Runtime Issues

#### ❌ "App crashes on startup"
1. **Check**: Firebase configuration
2. **Verify**: Permissions in Info.plist
3. **Test**: Debug mode first
4. **Review**: Console logs

#### ❌ "Features not working"
1. **Check**: Feature flags in app_config.dart
2. **Verify**: Variant is correct
3. **Test**: API connectivity

---

## 📚 Reference

### 📁 Important File Locations

```
├── lib/config/app_config.dart          # App variant configuration
├── android/app/build.gradle            # Android build settings
├── android/app/src/main/AndroidManifest.xml  # Android app info
├── ios/Runner/Info.plist               # iOS app info
├── ios/Runner.xcworkspace               # Xcode workspace
├── pubspec.yaml                        # Dependencies & version
├── assets/app_icon.jpg                 # App icon source
├── build_variants.sh                   # Build automation script
└── VARIANTS_GUIDE.md                   # Variant documentation
```

### 🔗 Useful Commands

```bash
# Development
flutter run --dart-define=APP_VARIANT=classic
flutter run --dart-define=APP_VARIANT=client

# Building
./build_variants.sh classic-aab
./build_variants.sh client-aab
./build_variants.sh all-android

# Maintenance
flutter clean
flutter pub get
flutter doctor
flutter pub outdated

# iOS specific
open ios/Runner.xcworkspace
cd ios && pod install

# Android specific
cd android && ./gradlew clean
```

### 🎯 Build Outputs

| File | Purpose | Use Case |
|------|---------|----------|
| `app-classic-release.aab` | Classic AAB | Play Store production |
| `app-client-release.aab` | Client AAB | Play Store premium |
| `app-classic-release.apk` | Classic APK | Testing/sideloading |
| `Runner.app` | iOS build | App Store via Xcode |

### 🔐 Security Checklist

#### Before Publishing
- [ ] Remove debug flags
- [ ] Update API endpoints to production
- [ ] Verify permissions are minimal
- [ ] Test on physical devices
- [ ] Check privacy policy compliance
- [ ] Validate certificate expiration dates
- [ ] Test both app variants
- [ ] Verify Firebase configuration

#### Regular Maintenance
- [ ] Update dependencies monthly
- [ ] Renew certificates before expiration
- [ ] Backup keystore files
- [ ] Monitor crash reports
- [ ] Update privacy policies as needed

---

## 🎉 Success Checklist

### ✅ Ready for App Store
- [ ] App builds without errors
- [ ] All variants tested
- [ ] Icons and metadata updated
- [ ] Privacy descriptions added
- [ ] Certificates configured
- [ ] Version numbers incremented
- [ ] Store listings prepared
- [ ] Screenshots captured
- [ ] Privacy policy linked

### ✅ Ready for Play Store
- [ ] AAB file generated
- [ ] App signed with keystore
- [ ] Version codes incremented
- [ ] Store listing complete
- [ ] Age rating configured
- [ ] Privacy policy linked
- [ ] Testing completed

---

📝 **Last Updated**: August 2025  
🔄 **Version**: 1.0  
👨‍💻 **Maintainer**: GEMS Development Team

> For questions or issues, refer to the troubleshooting section or contact the development team.
