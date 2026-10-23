import 'dart:convert';

class DataIntegritySigner {
  static int computeChecksum(String payload) {
    final bytes = utf8.encode(payload);
    var hash = 0xcbf29ce484222325;
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x100000001b3) & 0x7FFFFFFFFFFFFFFF;
    }
    return hash;
  }

  static bool verifyIntegrity(String payload, int expectedChecksum) {
    return computeChecksum(payload) == expectedChecksum;
  }

  static bool verifyManifest(Map<String, dynamic>? manifest, String? payload) {
    if (manifest == null || payload == null || payload.isEmpty) return false;

    // Check for required algorithm metadata
    final algorithm = manifest['algorithm'];
    if (algorithm != 'fnv1a') return false;

    // Check for required hash
    final expectedHash = manifest['hash'];
    if (expectedHash == null || expectedHash is! int) return false;

    // Check expiration if present
    final expiresAt = manifest['expiresAt'];
    if (expiresAt != null) {
      if (expiresAt is! int) return false;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiresAt) {
        return false;
      }
    }

    return verifyIntegrity(payload, expectedHash);
  }
}
