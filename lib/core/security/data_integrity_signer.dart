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

  static bool verifyManifestIntegrity(Map<String, dynamic>? manifest, String contentPayload) {
    if (manifest == null) return false;

    if (manifest['trustedKey'] != true) {
      return false;
    }

    final expectedHash = manifest['hash'];
    if (expectedHash == null || expectedHash is! int) {
      return false;
    }

    return verifyIntegrity(contentPayload, expectedHash);
  }
}
