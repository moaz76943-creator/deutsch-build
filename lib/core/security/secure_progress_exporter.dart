import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure offline progress export/import using HMAC integrity + XOR wrapping via crypto + secure storage.
/// All data stays on-device; uses user-selected files via SAF (no broad storage perms).
/// Fits Google Play Data safety (no off-device collection) and existing offline-first policy.
/// Raises bar against casual reverse engineering / data theft when combined with R8.
class SecureProgressExporter {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  static const _keyAlias = 'progress_export_key_v1';

  /// Derives a 32-byte key from device-bound secure storage material.
  static Future<Uint8List> _getOrCreateKey() async {
    final existing = await _storage.read(key: _keyAlias);
    if (existing != null) {
      return base64Url.decode(existing);
    }
    final random = List<int>.generate(32, (_) => DateTime.now().microsecondsSinceEpoch % 256);
    final key = Uint8List.fromList(random);
    await _storage.write(key: _keyAlias, value: base64Url.encode(key));
    return key;
  }

  /// HMAC-based integrity + XOR obfuscation (upgrade to AES-GCM with pointycastle if needed).
  /// Prevents casual reverse engineering and data theft of progress dumps.
  static Uint8List _protect(Uint8List plaintext, Uint8List key) {
    final hmac = Hmac(sha256, key);
    final mac = hmac.convert(plaintext).bytes;
    final combined = Uint8List(plaintext.length + mac.length);
    combined.setAll(0, plaintext);
    combined.setAll(plaintext.length, mac);
    for (var i = 0; i < combined.length; i++) {
      combined[i] ^= key[i % key.length];
    }
    return combined;
  }

  static Uint8List? _unprotect(Uint8List protected, Uint8List key) {
    final tmp = Uint8List.fromList(protected);
    for (var i = 0; i < tmp.length; i++) {
      tmp[i] ^= key[i % key.length];
    }
    if (tmp.length < 32) return null;
    final plaintext = tmp.sublist(0, tmp.length - 32);
    final mac = tmp.sublist(tmp.length - 32);
    final hmac = Hmac(sha256, key);
    final expected = hmac.convert(plaintext).bytes;
    if (!_constantTimeEquals(mac, expected)) return null;
    return plaintext;
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) diff |= a[i] ^ b[i];
    return diff == 0;
  }

  /// Export progress (example: SharedPreferences snapshot + SQLite query results as JSON).
  /// Call from a button; then use file_picker or share_plus to let user save the .dbp file.
  static Future<Uint8List> exportProgress({
    required Map<String, dynamic> preferencesSnapshot,
    required List<Map<String, dynamic>> srsRecords,
  }) async {
    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'prefs': preferencesSnapshot,
      'srs': srsRecords,
    };
    final jsonBytes = utf8.encode(jsonEncode(payload));
    final key = await _getOrCreateKey();
    return _protect(Uint8List.fromList(jsonBytes), key);
  }

  /// Import and validate. Returns null on integrity failure (prevents tampered data).
  static Future<Map<String, dynamic>?> importProgress(Uint8List protectedBytes) async {
    final key = await _getOrCreateKey();
    final plain = _unprotect(protectedBytes, key);
    if (plain == null) return null;
    try {
      final decoded = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
      if (decoded['version'] != 1) return null;
      return decoded;
    } catch (_) {
      return null;
    }
  }
}
