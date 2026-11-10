import 'package:flutter/foundation.dart';

/// Offline-safe Play Integrity Service.
///
/// The app enforces no INTERNET permission in release builds for privacy and Data Safety compliance.
/// Play Integrity API requires network connectivity and a backend verifier.
/// This service degrades gracefully: always returns null on offline devices,
/// allowing the app to continue with basic features while advanced modes remain gated.
///
/// For future online features (optional), re-enable INTERNET in a debug/flavor build
/// and implement full token request + backend verification.
/// Client-side checks alone are insufficient against reverse engineering.
class PlayIntegrityService {
  PlayIntegrityService._();

  /// Request a Play Integrity token.
  /// Returns null in fully offline builds (expected).
  /// Do not cache tokens; request fresh ones.
  static Future<String?> requestIntegrityToken() async {
    // Offline-first design: no network available.
    // In a networked flavor this would call the Play Integrity API via plugin.
    debugPrint('[PlayIntegrity] Offline mode: integrity token unavailable (by design).');
    return null;
  }

  /// Local heuristic check (weak, for non-critical gating only).
  /// Prefer server verification when network is available.
  static bool isLikelyGenuineDevice() {
    // Placeholder: check for debugger, emulator, root indicators if desired.
    // Strong protection requires Play Integrity + backend.
    return !kDebugMode; // Basic: release builds are "trusted" for local use.
  }
}
