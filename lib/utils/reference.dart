import 'package:flutter/material.dart';

// Shared Preferences
final String prefsLATITUDE = "latitude";
final String prefsLONGITUDE = "longitude";
const String kUsername = "USERNAME";

final String app_name = "GEMS";
final Color colorTheme1 = Color(0xff58c2c4);
final Color colorTheme1Light = Color.fromARGB(255, 147, 195, 196);
final Color colorTheme2 = Color(0xff2367f6);
final Color colorTheme2Light = Color.fromARGB(255, 202, 214, 247);
final Color colorTheme3 = Color(0xff022c41);
final Color colorTheme3Light = Color.fromARGB(255, 151, 191, 209);
final Color colorTheme4 = Color(0xffd24129);
final Color colorTheme4Light = Color.fromARGB(255, 255, 200, 192);
final Color colorTheme5 = Color(0xff1f7775);

abstract class Upload {
  final String action;
  final String ppmTaskId;

  Upload({required this.action, required this.ppmTaskId});

  Map<String, dynamic> get body {
    return {"action": action, "ppmTaskId": ppmTaskId};
  }
}

class AppColors {
  /// Primary brand color
  static const Color primary       = Color(0xFF276EF1);
  /// A lighter tint of primary
  static const Color primaryLight  = Color(0xFFCCE5FF);

  /// Neutral secondary / muted
  static const Color secondary     = Color(0xFF6C757D);
  /// Light tint of secondary
  static const Color secondaryLight= Color(0xFFE2E3E5);

  /// Success / positive actions
  static const Color success       = Color(0xFF28A745);
  /// Light tint of success
  static const Color successLight  = Color(0xFFD1E7DD);

  /// Information / tips
  static const Color info          = Color(0xFF17A2B8);
  /// Light tint of info
  static const Color infoLight     = Color(0xFFCFF4FC);

  /// Warning / caution
  static const Color warning       = Color(0xFFFFC107);
  /// Light tint of warning
  static const Color warningLight  = Color(0xFFFFF3CD);

  /// Danger / destructive actions
  static const Color danger        = Color(0xFFDC3545);
  /// Light tint of danger
  static const Color dangerLight   = Color(0xFFF8D7DA);

  /// Light background / surface
  static const Color light         = Color(0xFFF8F9FA);
  /// Dark text / surface
  static const Color dark          = Color(0xFF343A40);
}