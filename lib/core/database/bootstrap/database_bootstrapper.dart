import 'dart:io';
import 'package:flutter/foundation.dart';

class DatabaseBootstrapResult {
  final bool isReady;
  final String? error;

  const DatabaseBootstrapResult({required this.isReady, this.error});
}

class DatabaseBootstrapper {
  static const int _sqliteHeaderLength = 100;
  static const int _firstPageBtreeOffset = _sqliteHeaderLength;
  static const int _maxFirstPageBtreeHeaderLength = 12;

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

      // Read the complete page-one B-tree header as well as the standard
      // 100-byte database header. No write handle is opened.
      final raf = await file.open(mode: FileMode.read);
      late final List<int> header;
      try {
        header = await raf.read(
          _firstPageBtreeOffset + _maxFirstPageBtreeHeaderLength);
      } finally {
        await raf.close();
      }

      if (header.length !=
          _firstPageBtreeOffset + _maxFirstPageBtreeHeaderLength) {
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

      // SQLite page one stores sqlite_schema as a table B-tree. The root
      // page type must be an interior (0x05) or leaf (0x0d) table page;
      // padded magic/header bytes with no actual B-tree must fail closed.
      // This remains a preflight, not a substitute for integrity_check.
      if (header[_firstPageBtreeOffset] != 0x05 &&
          header[_firstPageBtreeOffset] != 0x0d) {
        return const DatabaseBootstrapResult(
          isReady: false,
          error: 'Invalid SQLite page-one B-tree',
        );
      }

      // The B-tree type byte alone can be forged in an otherwise zero-filled
      // page. Check the cell pointer array, cell-content boundary, freeblock
      // bounds and SQLite's maximum fragmented-free-byte count. Page one
      // begins at offset 100; interior table pages have a 12-byte header,
      // leaf table pages an 8-byte header.
      final isInterior = header[_firstPageBtreeOffset] == 0x05;
      final btreeHeaderEnd =
          _firstPageBtreeOffset + (isInterior ? 12 : 8);
      final firstFreeblock = (header[101] << 8) | header[102];
      final cellCount = (header[103] << 8) | header[104];
      final rawCellContentStart = (header[105] << 8) | header[106];
      // A zero cell-content offset is legal only for 65536-byte pages.
      final cellContentStart = rawCellContentStart == 0 && pageSize == 65536
          ? 65536
          : rawCellContentStart;
      final cellPointerArrayEnd = btreeHeaderEnd + cellCount * 2;
      if (cellContentStart < cellPointerArrayEnd ||
          cellContentStart > pageSize ||
          (firstFreeblock != 0 &&
              (firstFreeblock < cellContentStart ||
                  firstFreeblock > pageSize - 4)) ||
          header[107] > 60) {
        return const DatabaseBootstrapResult(
          isReady: false,
          error: 'Invalid SQLite page-one B-tree layout',
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
