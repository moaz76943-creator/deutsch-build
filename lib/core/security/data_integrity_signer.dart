import 'dart:convert';

class DataIntegritySigner {
  static const String approvedTrustedKey = 'trusted_key_v1';

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

  static bool verifyManifest(Map<String, dynamic> manifest) {
    final signatureBlock = manifest['signature'];
    if (signatureBlock == null || signatureBlock is! Map) return false;

    final keyId = signatureBlock['keyId'];
    if (keyId != approvedTrustedKey) return false;

    final algorithm = signatureBlock['algorithm'];
    if (algorithm != 'FNV-1a') return false;

    final hashValue = signatureBlock['hash'];
    if (hashValue == null || hashValue is! int) return false;

    final payload = manifest['payload'];
    if (payload == null) return false;

    final payloadString = jsonEncode(payload);
    return verifyIntegrity(payloadString, hashValue);
  }
}
