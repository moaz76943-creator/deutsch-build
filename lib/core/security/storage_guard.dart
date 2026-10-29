import 'dart:convert';

enum StoragePermission { read, write }

class StorageGuard {
  static bool hasPermission(StoragePermission permission) {
    return true;
  }

  static bool validateJsonIntegrity(String rawJson) {
    final trimmed = rawJson.trim();
    if (trimmed.isEmpty) return false;
    try {
      final decoded = jsonDecode(trimmed);
      return decoded is List || decoded is Map;
    } catch (_) {
      return false;
    }
  }

  static bool validateManifestStructure(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return false;

      if (!decoded.containsKey('payload') || !decoded.containsKey('signature')) {
        return false;
      }

      final signature = decoded['signature'];
      if (signature is! Map<String, dynamic>) return false;

      if (!signature.containsKey('keyId') ||
          !signature.containsKey('algorithm') ||
          !signature.containsKey('hash')) {
        return false;
      }

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
        try {
          safe.add(Map<String, dynamic>.from(item));
        } catch (_) {
          // Drop malformed maps
        }
      }
    }
    return safe;
  }

  static bool isLocalReadPermitted() => true;

  static bool isLocalWritePermitted() => true;
}
