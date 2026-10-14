import 'dart:convert';

class DataIntegritySigner {
  static const List<String> supportedCapabilities = ['content_v1', 'content_v2'];

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

  static bool verifyManifest(String manifestJson, {DateTime? currentTime}) {
    try {
      final decoded = jsonDecode(manifestJson) as Map<String, dynamic>;

      if (!decoded.containsKey('hash') || !decoded.containsKey('capabilities')) {
        return false;
      }

      final capabilities = List<String>.from(decoded['capabilities'] as List);
      if (capabilities.isEmpty || !capabilities.any((cap) => supportedCapabilities.contains(cap))) {
        return false;
      }

      if (decoded.containsKey('expiresAt')) {
        final expiresAt = DateTime.parse(decoded['expiresAt'] as String);
        final now = currentTime ?? DateTime.now();
        if (now.isAfter(expiresAt)) {
          return false;
        }
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  static bool verifyContentIntegrity(String payload, String manifestJson) {
    if (!verifyManifest(manifestJson)) return false;

    try {
      final decoded = jsonDecode(manifestJson) as Map<String, dynamic>;
      final expectedChecksum = decoded['hash'] as int;
      return verifyIntegrity(payload, expectedChecksum);
    } catch (_) {
      return false;
    }
  }
}
