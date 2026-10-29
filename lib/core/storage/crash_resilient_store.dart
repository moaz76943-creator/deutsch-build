import 'dart:convert';
import 'dart:io';

/// Provides atomic write-then-rename persistence and automatic recovery
/// from Last-Known-Good (.lkg) backups if an interrupted write occurs.
class CrashResilientStore {
  final File primaryFile;
  final File backupFile;
  final File tempFile;

  CrashResilientStore(String filePath)
      : primaryFile = File(filePath),
        backupFile = File('$filePath.lkg'),
        tempFile = File('$filePath.tmp');

  /// Writes data atomically: writes to temp, creates backup, then renames to primary
  Future<void> saveAtomically(Map<String, dynamic> data) async {
    final payload = jsonEncode(data);

    // 1. Write payload completely to temporary file and flush
    await tempFile.writeAsString(payload, flush: true);

    // 2. Snapshot current valid primary as last-known-good backup if it exists and is non-empty
    if (await primaryFile.exists() && (await primaryFile.length()) > 0) {
      await primaryFile.copy(backupFile.path);
    }

    // 3. Atomic rename temp file to primary file
    await tempFile.rename(primaryFile.path);
  }

  /// Reads primary data with fail-safe automatic rollback if corrupted or zero-length
  Future<Map<String, dynamic>> readWithRecovery() async {
    // Case 1: Primary exists and is non-empty
    if (await primaryFile.exists()) {
      final length = await primaryFile.length();
      if (length > 0) {
        try {
          final content = await primaryFile.readAsString();
          final decoded = jsonDecode(content) as Map<String, dynamic>;
          return decoded;
        } catch (_) {
          // Fall through to recovery if JSON decoding fails (truncated write)
        }
      }
    }

    // Case 2: Interrupted write detected (0 bytes or malformed). Recover from .lkg backup
    if (await backupFile.exists() && (await backupFile.length()) > 0) {
      try {
        final backupContent = await backupFile.readAsString();
        final recovered = jsonDecode(backupContent) as Map<String, dynamic>;
        // Restore primary from valid backup
        await backupFile.copy(primaryFile.path);
        return recovered;
      } catch (_) {
        // Backup also unreadable
      }
    }

    // Default safe fallback if neither exists
    return {};
  }
}
