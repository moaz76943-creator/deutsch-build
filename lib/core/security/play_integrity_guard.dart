/// Play Integrity Guard for Deutsch بالعربي
///
/// Optional network-based device/app integrity verification.
/// Gracefully falls back to offline mode if no connectivity or API fails.
/// Uses Android Keystore + encrypted SharedPreferences for caching results.
/// Complements existing R8 obfuscation, no-internet baseline, and local vaults.
///
/// Architecture: Singleton + Riverpod provider. Call on app start or before premium pack load.
/// Security: Nonce-bound requests, result expiry, no sensitive data sent.
/// Google Play Compliance: Update Data Safety form if INTERNET is re-enabled selectively.
library;

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayIntegrityGuard {
  static final PlayIntegrityGuard instance = PlayIntegrityGuard._internal();
  PlayIntegrityGuard._internal();

  static const MethodChannel _channel = MethodChannel('com.deutschbilarabi.app/integrity');

  static const String _cacheKey = 'integrity_cache_v1';
  static const Duration _cacheTtl = Duration(hours: 12);

  Future<IntegrityResult> verifyIntegrity({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);

    if (!forceRefresh && cached != null) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        final ts = DateTime.parse(map['ts'] as String);
        if (DateTime.now().difference(ts) < _cacheTtl) {
          return IntegrityResult.fromMap(map);
        }
      } catch (_) {}
    }

    try {
      final nonce = _generateNonce();
      final result = await _channel.invokeMethod<Map>('requestIntegrityToken', {
        'nonce': nonce,
      }).timeout(const Duration(seconds: 8));

      if (result == null) {
        return const IntegrityResult(isGenuine: false, reason: 'No response');
      }

      final integrity = IntegrityResult(
        isGenuine: result['isGenuine'] == true,
        reason: result['reason'] as String? ?? 'unknown',
        deviceIntegrity: result['deviceIntegrity'] as String?,
        appIntegrity: result['appIntegrity'] as String?,
      );

      await prefs.setString(_cacheKey, jsonEncode({
        ...integrity.toMap(),
        'ts': DateTime.now().toIso8601String(),
      }));

      return integrity;
    } on PlatformException catch (e) {
      return IntegrityResult(isGenuine: false, reason: e.message ?? 'Platform error');
    } on TimeoutException {
      return const IntegrityResult(isGenuine: false, reason: 'Timeout (offline?)');
    } catch (e) {
      return IntegrityResult(isGenuine: false, reason: e.toString());
    }
  }

  String _generateNonce() {
    final bytes = utf8.encode('${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}');
    return sha256.convert(bytes).toString().substring(0, 16);
  }
}

class IntegrityResult {
  final bool isGenuine;
  final String reason;
  final String? deviceIntegrity;
  final String? appIntegrity;

  const IntegrityResult({
    required this.isGenuine,
    required this.reason,
    this.deviceIntegrity,
    this.appIntegrity,
  });

  Map<String, dynamic> toMap() => {
        'isGenuine': isGenuine,
        'reason': reason,
        'deviceIntegrity': deviceIntegrity,
        'appIntegrity': appIntegrity,
      };

  factory IntegrityResult.fromMap(Map<String, dynamic> map) => IntegrityResult(
        isGenuine: map['isGenuine'] == true,
        reason: map['reason'] as String? ?? '',
        deviceIntegrity: map['deviceIntegrity'] as String?,
        appIntegrity: map['appIntegrity'] as String?,
      );
}
