import 'dart:io';
import 'package:flutter/foundation.dart';

class DatabaseBootstrapResult {
  final bool isReady;
  final String? error;

  const DatabaseBootstrapResult({required this.isReady, this.error});
}

class DatabaseBootstrapper {
  static const int _sqliteHeaderLength = 100;

  /// Read-only structural preflight for a local SQLite database.
  ///
  /// A matching 16-byte magic alone is not a usable database. Verify the
  /// mandatory header fields and complete page alignment before reporting
  /// bootstrap readiness. Pack admission still needs PRAGMA integrity_check,
  /// schema checks, and a trusted content hash before activation.
  static Future<DatabaseBootstrapResult> verifyAndPrepare({
    required String dbPath,
    Future<void> Function()? onSeedRequired,
  }) async {
    try {
      final file = File(dbPath);

      if (!await file.exists()) {
        if (onSeedRequired != null) {
          debugPrint(
              '[Bootstrap] قاعدة البيانات غير موجودة، بدء التثبيت الأولي...');
          await onSeedRequired();
        } else {
          return const DatabaseBootstrapResult(
            isReady: false,
            error: 'Database file missing and no seeder provided',
          );
        }
      }

      // A failed seeder must never turn a missing pack into READY.
      // Do not delete, replace, or recreate existing learner data.
      if (!await file.exists()) {
        return const DatabaseBootstrapResult(
          isReady: false,
          error: 'Database file still missing after seeding',
        );
      }

      final length = await file.length();
      if (length < _sqliteHeaderLength) {
        return const DatabaseBootstrapResult(
          isReady: false,
          error: 'Database file corrupted or truncated',
        );
      }

      final raf = await file.open(mode: FileMode.read);
      late final List<int> header;
      try {
        header = await raf.read(_sqliteHeaderLength);
      } finally {
        await raf.close();
      }

      if (header.length != _sqliteHeaderLength) {
        return const DatabaseBootstrapResult(
          isReady: false,
          error: 'Database file corrupted or truncated',
        );
      }

      if (String.fromCharCodes(header.sublist(0, 16)) !=
          'SQLite format 3\x00') {
        return const DatabaseBootstrapResult(
          isReady: false,
          error: 'Invalid SQLite header signature',
        );
      }

      // SQLite encodes a 65536-byte page size as the big-endian integer 1.
      final rawPageSize = (header[16] << 8) | header[17];
      final pageSize = rawPageSize == 1 ? 65536 : rawPageSize;
      if (pageSize < 512 ||
          pageSize > 65536 ||
          (pageSize & (pageSize - 1)) != 0) {
        return const DatabaseBootstrapResult(
          isReady: false,
          error: 'Invalid SQLite page size',
        );
      }

      // Both SQLite format versions 1 (rollback journal) and 2 (WAL)
      // are valid. Payload fractions are fixed by the SQLite file format.
      if ((header[18] != 1 && header[18] != 2) ||
          (header[19] != 1 && header[19] != 2) ||
          header[21] != 64 ||
          header[22] != 32 ||
          header[23] != 32) {
        return const DatabaseBootstrapResult(
          isReady: false,
          error: 'Invalid SQLite header fields',
        );
      }

      if (length < pageSize || length % pageSize != 0) {
        return const DatabaseBootstrapResult(
          isReady: false,
          error: 'SQLite file truncated or misaligned',
        );
      }

      return const DatabaseBootstrapResult(isReady: true);
    } catch (e, stack) {
      debugPrint('[Bootstrap Error] فشل تهيئة قاعدة البيانات: $e\n$stack');
      return DatabaseBootstrapResult(isReady: false, error: e.toString());
    }
  }
}
