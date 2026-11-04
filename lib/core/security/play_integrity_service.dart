import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Play Integrity Service for verifying app integrity against tampering,
/// modding, reverse engineering, and unauthorized environments.
///
/// Uses Google Play Integrity API with backend verification for high fortification.
/// Complements R8 obfuscation, SSL pinning (for any network), and encrypted storage.
///
/// Architecture: Clean separation; called from bootstrap or sensitive feature gates.
/// Offline-first: Caches last successful integrity result with expiration.
class PlayIntegrityService {
  static const MethodChannel _channel = MethodChannel('com.deutsch.bilarabi/play_integrity');
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _integrityCacheKey = 'play_integrity_cache_v1';
  static const Duration _cacheValidity = Duration(hours: 24);

  /// Requests a Play Integrity token and verifies it with backend.
  /// Returns true if the app is in a trusted, unmodified state.
  Future<bool> verifyIntegrity({
    String? nonce,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first for offline resilience
      if (!forceRefresh) {
        final cached = await _getCachedResult();
        if (cached != null) return cached;
      }

      // Generate nonce for replay protection
      final effectiveNonce = nonce ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Request token via platform channel (implement native Android side)
      final token = await _channel.invokeMethod<String>('requestIntegrityToken', {
        'nonce': effectiveNonce,
      });

      if (token == null || token.isEmpty) {
        return false;
      }

      // Backend verification (critical for security; client-side alone is insufficient)
      final isValid = await _verifyWithBackend(token, effectiveNonce);

      if (isValid) {
        await _cacheResult(true);
      }

      return isValid;
    } catch (e) {
      // Fail closed for security on sensitive operations
      return false;
    }
  }

  Future<bool> _verifyWithBackend(String token, String nonce) async {
    try {
      // TODO: Replace with your actual backend endpoint
      // Backend must use Google Play Integrity API server-side verification
      final response = await http.post(
        Uri.parse('https://your-backend.example.com/verify-integrity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'nonce': nonce,
          'packageName': 'com.deutsch.bilarabi', // Match your package
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isValid'] == true && data['appIntegrity'] == 'MEETS_DEVICE_INTEGRITY';
      }
      return false;
    } catch (_) {
      // Offline fallback: allow if previously verified recently, else deny for premium features
      return false;
    }
  }

  Future<bool?> _getCachedResult() async {
    final cached = await _secureStorage.read(key: _integrityCacheKey);
    if (cached == null) return null;

    final data = jsonDecode(cached);
    final timestamp = DateTime.parse(data['timestamp']);
    if (DateTime.now().difference(timestamp) > _cacheValidity) {
      await _secureStorage.delete(key: _integrityCacheKey);
      return null;
    }
    return data['isValid'] as bool;
  }

  Future<void> _cacheResult(bool isValid) async {
    final data = jsonEncode({
      'isValid': isValid,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _secureStorage.write(key: _integrityCacheKey, value: data);
  }

  /// Gate for premium or sensitive features (e.g., advanced packs, cloud sync if added)
  Future<bool> canAccessProtectedFeature() async {
    return await verifyIntegrity();
  }
}

final playIntegrityServiceProvider = Provider<PlayIntegrityService>((ref) {
  return PlayIntegrityService();
});
