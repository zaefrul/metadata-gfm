import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility to suppress biometric lock during system picker operations.
///
/// When opening native pickers (camera, gallery, file selector), the app
/// lifecycle goes through paused/resumed states. This triggers biometric
/// re-authentication which confuses users since they never "left" the app.
///
/// Usage:
/// ```dart
/// BiometricLockManager.suppressNextLock();
/// final picked = await ImagePicker().pickImage(source: ImageSource.camera);
/// // Biometric prompt won't appear when camera closes
/// ```
///
/// Or use the wrapper methods:
/// ```dart
/// final picked = await BiometricLockManager.pickImage(source: ImageSource.camera);
/// final file = await BiometricLockManager.pickFile();
/// ```
class BiometricLockManager {
  static bool _suppressNext = false;
  static DateTime? _suppressSetTime;
  static const _suppressTimeoutSeconds = 60; // Max time to suppress (safety)

  /// Call this BEFORE opening a system picker to prevent biometric prompt
  /// when the picker closes and app resumes.
  static void suppressNextLock() {
    _suppressNext = true;
    _suppressSetTime = DateTime.now();
  }

  /// Check if next biometric lock should be suppressed.
  /// Returns true if suppression is active and hasn't timed out.
  /// Does NOT reset the flag - use after checking in paused state.
  static bool shouldSuppress() {
    if (!_suppressNext) return false;
    
    // Safety timeout: Don't suppress forever if something goes wrong
    if (_suppressSetTime != null) {
      final elapsed = DateTime.now().difference(_suppressSetTime!).inSeconds;
      if (elapsed > _suppressTimeoutSeconds) {
        reset();
        return false;
      }
    }
    
    return true;
  }

  /// Check if suppression is active, and reset it for next cycle.
  /// Use this when app transitions from paused → resumed.
  static bool shouldSuppressAndReset() {
    final suppress = shouldSuppress();
    if (suppress) {
      reset();
    }
    return suppress;
  }

  /// Manually reset the suppression flag.
  static void reset() {
    _suppressNext = false;
    _suppressSetTime = null;
  }

  // ========== Wrapper Methods ==========

  /// Pick an image from camera or gallery without triggering biometric lock.
  static Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    suppressNextLock();
    try {
      return await ImagePicker().pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice,
      );
    } finally {
      // Reset after picker completes (success or failure)
      // Small delay to ensure lifecycle events have been processed
      Future.delayed(const Duration(milliseconds: 500), reset);
    }
  }

  /// Pick a single file without triggering biometric lock.
  static Future<FilePickerResult?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
  }) async {
    suppressNextLock();
    try {
      return await FilePicker.platform.pickFiles(
        dialogTitle: dialogTitle,
        initialDirectory: initialDirectory,
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
        withData: withData,
        withReadStream: withReadStream,
      );
    } finally {
      // Reset after picker completes (success or failure)
      // Small delay to ensure lifecycle events have been processed
      Future.delayed(const Duration(milliseconds: 500), reset);
    }
  }

  /// Save a file without triggering biometric lock.
  static Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    suppressNextLock();
    try {
      return await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: fileName,
        initialDirectory: initialDirectory,
        type: type,
        allowedExtensions: allowedExtensions,
      );
    } finally {
      // Reset after picker completes (success or failure)
      // Small delay to ensure lifecycle events have been processed
      Future.delayed(const Duration(milliseconds: 500), reset);
    }
  }

  // ========== URL Launcher Methods ==========

  /// Launch an external URL without triggering biometric lock.
  /// Use this for opening web pages, maps, phone calls, etc.
  static Future<bool> launchExternalUrl(
    Uri url, {
    LaunchMode mode = LaunchMode.externalApplication,
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
    String? webOnlyWindowName,
  }) async {
    suppressNextLock();
    try {
      return await launchUrl(
        url,
        mode: mode,
        webViewConfiguration: webViewConfiguration,
        webOnlyWindowName: webOnlyWindowName,
      );
    } finally {
      // Reset after a delay to allow lifecycle events to process
      // External URLs may take longer to return from
      Future.delayed(const Duration(seconds: 2), reset);
    }
  }

  /// Launch a URL string without triggering biometric lock.
  /// Convenience method that parses the string to Uri.
  static Future<bool> launchExternalUrlString(
    String urlString, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    final Uri url = Uri.parse(urlString);
    return launchExternalUrl(url, mode: mode);
  }
}
