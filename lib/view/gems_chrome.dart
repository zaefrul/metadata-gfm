import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual tokens for the GEMS Tabler shell (login, menu, home).
/// Inner screens keep [AppColors] until they are migrated.
class GemsChrome {
  static const Color primary = Color(0xFF0055B8);
  static const Color primaryDark = Color(0xFF003F8A);
  static const Color teal = Color(0xFF00ADA8);
  static const Color accent = Color(0xFFCEEFF0);
  static const Color page = Color(0xFFF1F5F9);
  static const Color text = Color(0xFF243746);
  static const Color textSoft = Color(0xFF5B676F);
  static const Color muted = Color(0xFF7E8F9A);
  static const Color border = Color(0xFFE7EAEC);
  static const Color primarySoft = Color(0xFFE6EEF8);
  static const Color neutralSoft = Color(0xFFEEF1F4);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerFg = Color(0xFFB21F1F);
  static const Color dangerSoft = Color(0xFFFDEAEA);
  static const Color success = Color(0xFF1A7F4B);
  static const Color successSoft = Color(0xFFE7F7EE);
  static const Color warning = Color(0xFF9A6206);
  static const Color warningSoft = Color(0xFFFDF3E2);
  static const Color info = Color(0xFF0B6B68);
  static const Color infoSoft = Color(0xFFCEEFF0);

  static const double radius = 8;

  static TextStyle heading({
    double size = 22,
    FontWeight weight = FontWeight.w700,
    Color color = text,
  }) {
    return GoogleFonts.lato(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = text,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}

/// White card whose status stripe is clipped to the rounded corners.
class GemsAccentCard extends StatelessWidget {
  const GemsAccentCard({
    super.key,
    required this.accent,
    required this.onTap,
    required this.child,
    this.margin = EdgeInsets.zero,
  });

  final Color accent;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry margin;

  static const double accentWidth = 5;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(GemsChrome.radius);
    return Padding(
      padding: margin,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: GemsChrome.border),
        ),
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ColoredBox(
                  color: accent,
                  child: const SizedBox(width: accentWidth),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

AppBar gemsAppBar({
  required Widget title,
  List<Widget>? actions,
  bool centerTitle = false,
  PreferredSizeWidget? bottom,
  Widget? leading,
}) {
  return AppBar(
    leading: leading,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: centerTitle,
    iconTheme: const IconThemeData(color: GemsChrome.text),
    actionsIconTheme: const IconThemeData(color: GemsChrome.text),
    titleTextStyle: GemsChrome.heading(size: 18),
    shape: const Border(bottom: BorderSide(color: GemsChrome.border)),
    title: title,
    actions: actions,
    bottom: bottom,
  );
}

InputDecoration gemsFieldDecoration({
  String? label,
  bool enabled = true,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(GemsChrome.radius),
    borderSide: const BorderSide(color: GemsChrome.border),
  );
  return InputDecoration(
    labelText: label,
    labelStyle: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
    floatingLabelBehavior: FloatingLabelBehavior.never,
    filled: true,
    fillColor: enabled ? Colors.white : GemsChrome.neutralSoft,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: GemsChrome.primary, width: 1.4),
    ),
    disabledBorder: border,
  );
}

class GemsFormSection extends StatelessWidget {
  const GemsFormSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(GemsChrome.radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GemsChrome.radius),
          border: Border.all(color: GemsChrome.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ColoredBox(
              color: GemsChrome.teal,
              child: SizedBox(height: 3),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: GemsChrome.primary),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: GemsChrome.heading(size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ButtonStyle gemsPrimaryButton({double height = 44}) {
  return FilledButton.styleFrom(
    backgroundColor: GemsChrome.primary,
    foregroundColor: Colors.white,
    disabledBackgroundColor: GemsChrome.primary.withValues(alpha: 0.45),
    disabledForegroundColor: Colors.white,
    elevation: 0,
    minimumSize: Size(double.infinity, height),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GemsChrome.radius),
    ),
  );
}

/// Soft status chip colors from the GEMS status vocabulary.
class GemsStatusStyle {
  final Color foreground;
  final Color background;

  const GemsStatusStyle(this.foreground, this.background);

  static const GemsStatusStyle primary =
      GemsStatusStyle(GemsChrome.primary, GemsChrome.primarySoft);
  static const GemsStatusStyle success =
      GemsStatusStyle(GemsChrome.success, GemsChrome.successSoft);
  static const GemsStatusStyle warning =
      GemsStatusStyle(GemsChrome.warning, GemsChrome.warningSoft);
  static const GemsStatusStyle danger =
      GemsStatusStyle(GemsChrome.dangerFg, GemsChrome.dangerSoft);
  static const GemsStatusStyle info =
      GemsStatusStyle(GemsChrome.info, GemsChrome.infoSoft);
  static const GemsStatusStyle neutral =
      GemsStatusStyle(GemsChrome.textSoft, GemsChrome.neutralSoft);

  static GemsStatusStyle forPpm(String? status) {
    switch (status) {
      case 'In Progress':
        return primary;
      case 'Closed':
      case 'Completed':
        return success;
      case 'Check':
        return info;
      case 'Verify':
      case 'Re-Open':
        return warning;
      default:
        return neutral;
    }
  }

  static GemsStatusStyle forInventory(String? status) {
    switch (status) {
      case 'Stock Request':
        return primary;
      case 'Parts Collected':
        return success;
      case 'Request Parts':
      case 'Request Approval':
      case 'Waiting for Purchase':
        return warning;
      case 'Need to Order':
        return danger;
      case 'Ready For Collection':
        return info;
      default:
        return neutral;
    }
  }

  static GemsStatusStyle forWorkOrder(String? status) {
    switch (status) {
      case 'In Progress':
        return primary;
      case 'Completed':
      case 'WR Verified':
        return success;
      case 'Assign':
      case 'Re-Open':
      case 'Verify':
        return warning;
      case 'Rejected':
        return danger;
      case 'WR Check':
      case 'Check':
        return info;
      default:
        return neutral;
    }
  }
}
