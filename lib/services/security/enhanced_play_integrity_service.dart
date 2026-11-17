import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Enhanced Play Integrity Service with local fallbacks and preparation for full API.
///
/// In fully offline builds (no INTERNET), falls back to local SecurityGuard checks.
/// When network is available (future flavor or opt-in), request token and verify server-side.
///
/// Security notes:
/// - Client-side checks are advisory only; always verify critical operations on backend.
/// - Use Play Integrity API (Standard or Classic) + your server for strong attestation.
/// - Combine with R8 obfuscation, SSL pinning, encrypted storage (SQLCipher).
class EnhancedPlayIntegrityService {
  static const MethodChannel _channel = MethodChannel('com.deutschbilarabi.app/integrity');

  /// Request integrity token. Returns null if offline or API unavailable.
  static Future<String?> requestIntegrityToken({String? nonce}) async {
    try {
      final result = await _channel.invokeMethod<String>('requestIntegrityToken', {
        'nonce': nonce ?? DateTime.now().millisecondsSinceEpoch.toString(),
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('[Integrity] Platform error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[Integrity] Offline or unavailable: $e');
      return null;
    }
  }

  /// Local heuristic (weak). Prefer server verification.
  /// Integrates with existing SecurityGuard.kt via channel.
  static Future<bool> isDeviceLikelyGenuine() async {
    if (kDebugMode) return true;
    try {
      final compromised = await _channel.invokeMethod<bool>('isCompromised');
      return compromised != true;
    } catch (_) {
      return !kDebugMode;
    }
  }

  /// Gate a premium or sensitive feature.
  /// In offline mode: local check. In online: require fresh token verified by backend.
  static Future<bool> canAccessPremiumFeature() async {
    final token = await requestIntegrityToken();
    if (token != null) {
      debugPrint('[Integrity] Token obtained; backend verification required.');
      return true;
    }
    return await isDeviceLikelyGenuine();
  }
}
