import 'dart:convert';
import 'data_integrity_signer.dart';

enum StorageAccessType {
  read,
  write,
}

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
