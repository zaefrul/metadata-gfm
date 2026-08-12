import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PendingNotificationStore {
  static const String prefsKey = 'PENDING_NOTIFICATION_PAYLOAD';

  static Future<void> save(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, jsonEncode(data));
  }

  /// Returns and clears any pending payload.
  static Future<Map<String, String>?> consume() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(prefsKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    await prefs.remove(prefsKey);
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsKey);
  }

  static Future<bool> hasPending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(prefsKey);
    return raw != null && raw.isNotEmpty;
  }
}
