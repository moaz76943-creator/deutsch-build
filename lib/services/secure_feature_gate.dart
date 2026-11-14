import 'package:flutter/foundation.dart';
import 'package:deutsch_bilarabi/services/play_integrity_service.dart';

/// Gates premium / advanced features behind a fresh Play Integrity token.
///
/// Client-side check is a first line of defense only.
/// Always verify the returned token on your backend before granting real entitlements.
///
/// Usage:
/// ```dart
/// final gate = SecureFeatureGate();
/// if (await gate.isPremiumUnlocked()) {
///   // unlock advanced packs / adaptive review
/// }
/// ```
class SecureFeatureGate {
  /// Requests a fresh integrity token and performs basic client validation.
  /// Returns true only if a non-empty token was obtained.
  /// In production, send the token to your backend for full verification.
  Future<bool> isPremiumUnlocked({String? backendNonce}) async {
    try {
      final token = await PlayIntegrityService.requestIntegrityToken(
        nonce: backendNonce,
      );

      if (token == null || token.isEmpty) {
        debugPrint('[SecureFeatureGate] Integrity token missing – premium gated');
        return false;
      }

      // Optional: cache encrypted token briefly (use existing Keystore wrapper)
      // Never cache longer than a few minutes.
      debugPrint('[SecureFeatureGate] Token obtained (len=${token.length})');

      // TODO: Send token + nonce to backend for Google verification.
      // Example endpoint: POST /v1/integrity/verify
      // Backend returns { "unlocked": true, "sessionToken": "..." }
      // Store sessionToken encrypted via Android Keystore.

      return true; // Temporary client-only; replace with backend result
    } catch (e, st) {
      debugPrint('[SecureFeatureGate] Error: $e\n$st');
      return false;
    }
  }

  /// Example of how to bind a specific operation to a fresh token.
  Future<String?> requestBoundToken() async {
    return PlayIntegrityService.requestIntegrityToken();
  }
}
