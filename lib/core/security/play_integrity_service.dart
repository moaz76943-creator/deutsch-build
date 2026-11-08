import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Play Integrity Service for verifying app integrity against tampering,
/// modding, reverse engineering, and unauthorized environments.
///
/// Uses Google Play Integrity API with backend verification for high fortification.
/// Complements R8 obfuscation, SSL pinning (for any network), and encrypted storage.
///
/// Architecture: Clean separation; called from bootstrap or sensitive feature gates.
/// Offline-first: Caches last successful integrity result with expiration.
///
/// Security: Fail closed. Never trust client-side only. Backend must verify token.
class PlayIntegrityService {
  // Fixed channel to match native AndroidPlayIntegrityManager.CHANNEL_NAME
  static const MethodChannel _channel = MethodChannel('com.deutschbilarabi.app/play_integrity');
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'deutsch_secure_prefs',
      preferencesKeyPrefix: 'deutsch_',
    ),
  );

  static const String _integrityCacheKey = 'play_integrity_cache_v1';
  static const Duration _cacheValidity = Duration(hours: 12); // Shorter for higher security

  /// Requests a Play Integrity token and verifies it with backend.
  /// Returns true if the app is in a trusted, unmodified state.
  Future<bool> verifyIntegrity({
    String? nonce,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cached = await _getCachedResult();
        if (cached == true) return true; // Only trust positive cache
      }

      final effectiveNonce = nonce ?? DateTime.now().millisecondsSinceEpoch.toString();

      final token = await _channel.invokeMethod<String>('requestIntegrityToken', {
        'nonce': effectiveNonce,
      }).timeout(const Duration(seconds: 15));

      if (token == null || token.isEmpty) {
        return false;
      }

      final isValid = await _verifyWithBackend(token, effectiveNonce);

      if (isValid) {
        await _cacheResult(true);
      } else {
        await _secureStorage.delete(key: _integrityCacheKey);
      }

      return isValid;
    } on PlatformException catch (e) {
      // Log securely without exposing details
      return false;
    } catch (e) {
      return false; // Fail closed
    }
  }

  Future<bool> _verifyWithBackend(String token, String nonce) async {
    try {
      // Production: replace with real endpoint. Use certificate pinning.
      // Example pinning via http package or dio with pins.
      final response = await http.post(
        Uri.parse('https://your-secure-backend.example.com/api/v1/verify-integrity'),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Version': '1.0',
        },
        body: jsonEncode({
          'token': token,
          'nonce': nonce,
          'packageName': 'com.deutschbilarabi.app',
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // Strict checks
        return data['isValid'] == true &&
               data['appIntegrity'] == 'MEETS_DEVICE_INTEGRITY' &&
               data['deviceIntegrity'] != null;
      }
      return false;
    } catch (_) {
      return false; // No offline positive trust for critical gates
    }
  }

  Future<bool?> _getCachedResult() async {
    try {
      final cached = await _secureStorage.read(key: _integrityCacheKey);
      if (cached == null) return null;

      final data = jsonDecode(cached) as Map<String, dynamic>;
      final timestamp = DateTime.parse(data['timestamp'] as String);
      if (DateTime.now().difference(timestamp) > _cacheValidity) {
        await _secureStorage.delete(key: _integrityCacheKey);
        return null;
      }
      return data['isValid'] as bool?;
    } catch (_) {
      await _secureStorage.delete(key: _integrityCacheKey);
      return null;
    }
  }

  Future<void> _cacheResult(bool isValid) async {
    final data = jsonEncode({
      'isValid': isValid,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _secureStorage.write(key: _integrityCacheKey, value: data);
  }

  /// Gate for premium or sensitive features (advanced SRS, premium packs, analytics)
  Future<bool> canAccessProtectedFeature({bool force = false}) async {
    return await verifyIntegrity(forceRefresh: force);
  }

  /// Clear cache (e.g. on logout or integrity failure)
  Future<void> clearCache() async {
    await _secureStorage.delete(key: _integrityCacheKey);
  }
}

final playIntegrityServiceProvider = Provider<PlayIntegrityService>((ref) {
  return PlayIntegrityService();
});
