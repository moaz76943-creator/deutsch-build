import 'dart:convert';

class StorageGuard {
  static bool validateJsonIntegrity(String rawJson) {
    if (rawJson.trim().isEmpty) return false;
    try {
      final decoded = jsonDecode(rawJson);
      return decoded is List || decoded is Map;
    } catch (_) {
      return false;
    }
  }

  static bool validateManifestStructure(String rawJson) {
    if (!validateJsonIntegrity(rawJson)) return false;

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) return false;

      if (!decoded.containsKey('payload')) return false;
      if (!decoded.containsKey('signature')) return false;

      final signature = decoded['signature'];
      if (signature is! Map) return false;

      if (!signature.containsKey('keyId')) return false;
      if (!signature.containsKey('algorithm')) return false;
      if (!signature.containsKey('hash')) return false;

      return true;
    } catch (_) {
      return false;
    }
  }

  static List<Map<String, dynamic>> sanitizeWordEntries(dynamic rawList) {
    if (rawList is! List) return [];
    final List<Map<String, dynamic>> safe = [];
    for (final item in rawList) {
      if (item is Map) {
        safe.add(Map<String, dynamic>.from(item));
      }
    }
    return safe;
  }
}
