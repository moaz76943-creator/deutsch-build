import 'dart:convert';

class StorageGuard {
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
        safe.add(Map<String, dynamic>.from(item));
      }
    }
    return safe;
  }
}
