import 'dart:convert';
import 'data_integrity_signer.dart';

enum StorageAccessType {
  read,
  write,
}

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

  static bool checkAccess(StorageAccessType type, String payload, {String? manifestJson}) {
    // Fail-closed storage decision: If we can't parse or integrity fails, deny access.
    if (!validateJsonIntegrity(payload)) {
      return false;
    }

    if (manifestJson != null) {
      if (!DataIntegritySigner.verifyContentIntegrity(payload, manifestJson)) {
        return false;
      }
    }

    // Explicit permissions for local read/write are permitted as long as integrity holds.
    return true;
  }
}
