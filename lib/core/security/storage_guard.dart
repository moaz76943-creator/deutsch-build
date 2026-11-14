import 'dart:convert';
import 'offline_gate.dart';

enum StoragePermission { read, write }

class StorageGuard {
  static bool hasPermission(StoragePermission permission) {
    if (permission == StoragePermission.read) {
      return OfflineGate.isOperationPermitted(OperationType.localRead);
    } else {
      return OfflineGate.isOperationPermitted(OperationType.localWrite);
    }
  }

  static bool isLocalReadPermitted() => hasPermission(StoragePermission.read);

  static bool isLocalWritePermitted() => hasPermission(StoragePermission.write);

  static bool validateJsonIntegrity(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      return decoded is List || decoded is Map;
    } catch (_) {
      return false;
    }
  }

  static bool validateManifestStructure(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) return false;
      if (decoded['algorithm'] == null ||
          decoded['hash'] == null ||
          decoded['keyId'] == null) {
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
}
