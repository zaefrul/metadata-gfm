// ignore_for_file: deprecated_member_use

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

// helper to determine the color of button
Color getButtonBgColorByStatus(String? status) {
  switch (status) {
    case "Assign":
      return AppColors.warning;
    case "WR Check":
      return AppColors.info;
    case "WR Verified":
      return AppColors.success;
    case "In Progress":
      return AppColors.primary;
    case "Verify":
      return AppColors.info;
    case "Re-Open":
      return AppColors.warning;
    case "Completed":
      return AppColors.success;
    case "Rejected":
      return AppColors.danger;
    default:
      return AppColors.secondary;
  }
}

class AppColors {
  // — Primary palette
  static const Color primary       = Color(0xFF276EF1);
  static const Color primaryLight  = Color(0xFFCCE5FF);
  static const Color primaryDark   = Color(0xFF004ECF);
  static const Color primary50     = Color(0xFFE3F2FD);
  static const Color primary100    = Color(0xFFBBDEFB);
  static const Color primary200    = Color(0xFF90CAF9);
  static const Color onPrimary     = Color(0xFFFFFFFF);

  // — Secondary / muted
  static const Color secondary        = Color(0xFF6C757D);
  static const Color secondaryLight   = Color(0xFFE2E3E5);
  static const Color secondaryDark    = Color(0xFF494F54);
  static const Color secondary50      = Color(0xFFF8F9FA);
  static const Color onSecondary      = Color(0xFFFFFFFF);

  // — Success
  static const Color success        = Color(0xFF28A745);
  static const Color successLight   = Color(0xFFD1E7DD);
  static const Color successDark    = Color(0xFF1E7E34);
  static const Color onSuccess      = Color(0xFFFFFFFF);

  // — Info
  static const Color info        = Color(0xFF17A2B8);
  static const Color infoLight   = Color(0xFFCFF4FC);
  static const Color infoDark    = Color(0xFF117A8B);
  static const Color onInfo      = Color(0xFFFFFFFF);

  // — Warning
  static const Color warning        = Color(0xFFFFC107);
  static const Color warningLight   = Color(0xFFFFF3CD);
  static const Color warningDark    = Color(0xFFCC9A06);
  static const Color onWarning      = Color(0xFF212529);

  // — Danger
  static const Color danger        = Color(0xFFDC3545);
  static const Color dangerLight   = Color(0xFFF8D7DA);
  static const Color dangerDark    = Color(0xFFA71D2A);
  static const Color onDanger      = Color(0xFFFFFFFF);

  // — Tertiary / Accent
  static const Color accent        = Color(0xFF6610F2);
  static const Color accentLight   = Color(0xFFF3E5FF);
  static const Color accentDark    = Color(0xFF4A00D1);
  static const Color onAccent      = Color(0xFFFFFFFF);

  // — Neutrals / Grays
  static const Color gray50   = Color(0xFFF8F9FA);
  static const Color gray100  = Color(0xFFF1F3F5);
  static const Color gray200  = Color(0xFFE9ECEF);
  static const Color gray300  = Color(0xFFDEE2E6);
  static const Color gray400  = Color(0xFFCED4DA);
  static const Color gray500  = Color(0xFFADB5BD);
  static const Color gray600  = Color(0xFF6C757D);
  static const Color gray700  = Color(0xFF495057);
  static const Color gray800  = Color(0xFF343A40);
  static const Color gray900  = Color(0xFF212529);

  // — Semantic surfaces
  static const Color light       = Color(0xFFF8F9FA); // same as gray50
  static const Color dark        = Color(0xFF343A40); // same as gray800
  static const Color white       = Color(0xFFFFFFFF);
  static const Color black       = Color(0xFF000000);

  // — Interactive states
  static const Color disabled          = Color(0x616C757D); // 38% opacity
  static const Color highlight         = Color(0x1F276EF1); // 12% opacity
  static const Color focusRing         = Color(0x3D276EF1); // 24% opacity
  static const Color divider           = Color(0xFFCED4DA);

  // — Text
  static const Color textPrimary       = Color(0xFF212529);
  static const Color textSecondary     = Color(0xFF495057);
  static const Color textDisabled      = Color(0xFF6C757D);
  static const Color textHint          = Color(0xFFADB5BD);

  // — Backgrounds
  static const Color bgPaper     = Color(0xFFFFFFFF);
  static const Color bgDefault   = Color(0xFFF8F9FA);
  static const Color bgAppBar    = Color(0xFFFFFFFF);
}