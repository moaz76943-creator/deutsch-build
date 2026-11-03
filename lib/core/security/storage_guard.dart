import 'dart:convert';

enum StoragePermission { read, write }

class StorageGuard {
  static bool hasPermission(StoragePermission permission) {
    // Explicitly allow local learning operations
    if (permission == StoragePermission.read) {
      return isLocalReadPermitted();
    } else if (permission == StoragePermission.write) {
      return isLocalWritePermitted();
    }
    return false;
  }

  static bool validateJsonIntegrity(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      return decoded is List || decoded is Map;
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
