import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

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

  /// Call this BEFORE opening a system picker to prevent biometric prompt
  /// when the picker closes and app resumes.
  static void suppressNextLock() {
    _suppressNext = true;
  }

  /// Check if next biometric lock should be suppressed.
  /// Automatically resets to false after being called.
  static bool shouldSuppressAndReset() {
    final suppress = _suppressNext;
    _suppressNext = false;
    return suppress;
  }

  /// Manually reset the suppression flag.
  static void reset() {
    _suppressNext = false;
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
    return await ImagePicker().pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
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
    return await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
      withData: withData,
      withReadStream: withReadStream,
    );
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
    return await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      initialDirectory: initialDirectory,
      type: type,
      allowedExtensions: allowedExtensions,
    );
  }
}
