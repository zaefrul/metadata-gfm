import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSecureStorage {
  AuthSecureStorage._();

  static const _credentialsKey = 'biometric_credentials';
  static const _enabledKey = 'biometric_enabled';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> enable(String username, String password) async {
    await _storage.write(
      key: _credentialsKey,
      value: jsonEncode({
        'username': username,
        'password': password,
      }),
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    await _storage.write(
      key: _enabledKey,
      value: 'true',
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  static Future<void> updateCredentials(String username, String password) async {
    final enabled = await isEnabled();
    if (!enabled) return;
    await enable(username, password);
  }

  static Future<bool> isEnabled() async {
    final value = await _storage.read(
      key: _enabledKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    return value == 'true';
  }

  static Future<BiometricCredentials?> readCredentials() async {
    final raw = await _storage.read(
      key: _credentialsKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final username = decoded['username'] as String?;
      final password = decoded['password'] as String?;
      if (username == null || password == null) return null;
      return BiometricCredentials(username: username, password: password);
    } catch (_) {
      return null;
    }
  }

  static Future<void> disable() async {
    await _storage.delete(
      key: _credentialsKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    await _storage.delete(
      key: _enabledKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  static AndroidOptions get _androidOptions => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  static IOSOptions get _iosOptions => const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      );
}

class BiometricCredentials {
  final String username;
  final String password;

  const BiometricCredentials({required this.username, required this.password});
}
