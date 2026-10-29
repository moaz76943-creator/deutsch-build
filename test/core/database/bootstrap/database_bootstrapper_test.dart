import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/database/bootstrap/database_bootstrapper.dart';

/// Structural SQLite page fixture for bootstrap preflight tests.
/// It does not replace the independent PRAGMA integrity_check at admission.
List<int> _sqlitePage({
  int pageSize = 512,
  int? declaredPageSize,
  int writeVersion = 1,
  int readVersion = 1,
}) {
  final bytes = List<int>.filled(pageSize, 0);
  final magic = 'SQLite format 3\x00'.codeUnits;
  bytes.setRange(0, magic.length, magic);
  final encodedSize = (declaredPageSize ?? pageSize) == 65536
      ? 1
      : (declaredPageSize ?? pageSize);
  bytes[16] = (encodedSize >> 8) & 0xff;
  bytes[17] = encodedSize & 0xff;
  bytes[18] = writeVersion;
  bytes[19] = readVersion;
  bytes[21] = 64;
  bytes[22] = 32;
  bytes[23] = 32;
  // Page one must begin with a table leaf B-tree (sqlite_schema).
  bytes[100] = 0x0d;
  // Empty leaf table: no cell pointers and content begins at page end.
  // SQLite encodes 65536 as zero in this two-byte B-tree header field.
  final contentStart = pageSize == 65536 ? 0 : pageSize;
  bytes[105] = (contentStart >> 8) & 0xff;
  bytes[106] = contentStart & 0xff;
  return bytes;
}

/// A structurally plausible table-leaf page with one two-byte cell.
List<int> _oneCellPage({int reservedBytes = 0, int cellOffset = 480}) {
  final bytes = _sqlitePage();
  bytes[20] = reservedBytes;
  bytes[104] = 1; // one cell pointer
  bytes[105] = 1;
  bytes[106] = 224; // cell content begins at offset 480
  bytes[108] = (cellOffset >> 8) & 0xff;
  bytes[109] = cellOffset & 0xff;
  return bytes;
}

/// SQLite header integers are unsigned, big-endian 32-bit values.
void _writeHeaderU32(List<int> bytes, int offset, int value) {
  bytes[offset] = (value >> 24) & 0xff;
  bytes[offset + 1] = (value >> 16) & 0xff;
  bytes[offset + 2] = (value >> 8) & 0xff;
  bytes[offset + 3] = value & 0xff;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('db_bootstrap_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('rejects a non-SQLite file without modifying it', () async {
    final file = File(tempDir.path + '/corrupt.db');
    final original = List<int>.filled(512, 0);
    await file.writeAsBytes(original);

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('Invalid SQLite header signature'));
    expect(await file.readAsBytes(), original);
  });

  test('rejects a magic-only 16-byte file previously reported READY', () async {
    final file = File(tempDir.path + '/magic_only.db');
    await file.writeAsBytes('SQLite format 3\x00'.codeUnits);

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('corrupted or truncated'));
  });

  test('rejects a 100-byte header without its SQLite page', () async {
    final file = File(tempDir.path + '/header_only.db');
    await file.writeAsBytes(_sqlitePage().sublist(0, 100));

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('corrupted or truncated'));
  });

  test('accepts structurally complete SQLite pages for preflight', () async {
    final file = File(tempDir.path + '/structural.db');
    await file.writeAsBytes(_sqlitePage());

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isTrue);
    expect(result.error, isNull);
  });

  test('rejects a padded SQLite signature without a page-one B-tree', () async {
    final file = File(tempDir.path + '/padded_magic.db');
    final bytes = List<int>.from(_sqlitePage());
    // Page one must contain a table B-tree at byte offset 100.
    // A padded magic string is not a usable SQLite database.
    bytes[100] = 0;
    await file.writeAsBytes(bytes);

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('B-tree'));
    expect(await file.readAsBytes(), bytes);
  });

  test('rejects a forged B-tree marker with an uninitialized cell area',
      () async {
    final file = File(tempDir.path + '/forged_btree.db');
    final bytes = List<int>.from(_sqlitePage());
    bytes[105] = 0;
    bytes[106] = 0;
    await file.writeAsBytes(bytes);

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('B-tree layout'));
    expect(await file.readAsBytes(), bytes);
  });

  test('rejects overlapping B-tree pointers, bad freeblocks and fragments',
      () async {
    final invalidPages = <List<int>>[
      // 203 pointers need 406 bytes after the 108-byte leaf header.
      List<int>.from(_sqlitePage())..[104] = 203,
      // Freeblocks must reside within the cell-content area.
      List<int>.from(_sqlitePage())..[102] = 108,
      // SQLite permits at most 60 fragmented free bytes per B-tree page.
      List<int>.from(_sqlitePage())..[107] = 61,
    ];
    for (var i = 0; i < invalidPages.length; i++) {
      final file = File(tempDir.path + '/bad_btree_layout_$i.db');
      await file.writeAsBytes(invalidPages[i]);
      final result = await DatabaseBootstrapper.verifyAndPrepare(
        dbPath: file.path,
      );
      expect(result.isReady, isFalse, reason: 'malformed layout $i');
      expect(result.error, contains('B-tree layout'));
      expect(await file.readAsBytes(), invalidPages[i]);
    }
  });

  test('accepts a bounded table cell pointer inside the usable page',
      () async {
    final file = File(tempDir.path + '/one_cell.db');
    await file.writeAsBytes(_oneCellPage());

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isTrue);
  });

  test('rejects cell pointers into header or outside the page', () async {
    for (final offset in <int>[0, 511]) {
      final file = File(tempDir.path + '/bad_cell_$offset.db');
      final bytes = _oneCellPage(cellOffset: offset);
      await file.writeAsBytes(bytes);

      final result = await DatabaseBootstrapper.verifyAndPrepare(
        dbPath: file.path,
      );

      expect(result.isReady, isFalse, reason: 'cell pointer $offset');
      expect(result.error, contains('cell pointers'));
      expect(await file.readAsBytes(), bytes);
    }
  });

  test('rejects cell pointers into reserved page bytes', () async {
    final file = File(tempDir.path + '/reserved_cell.db');
    final bytes = _oneCellPage(reservedBytes: 16, cellOffset: 505);
    await file.writeAsBytes(bytes);

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('cell pointers'));
    expect(await file.readAsBytes(), bytes);
  });

  test('rejects unusable page sizes and reserved-tail overlap', () async {
    final cases = <List<int>>[
      _oneCellPage(reservedBytes: 33), // fewer than 480 usable bytes
      List<int>.from(_sqlitePage())
        ..[20] = 16
        ..[105] = 1
        ..[106] = 250, // cell content starts inside reserved bytes
    ];
    for (var i = 0; i < cases.length; i++) {
      final file = File(tempDir.path + '/bad_reserved_$i.db');
      await file.writeAsBytes(cases[i]);
      final result = await DatabaseBootstrapper.verifyAndPrepare(
        dbPath: file.path,
      );
      expect(result.isReady, isFalse, reason: 'reserved layout $i');
      expect(await file.readAsBytes(), cases[i]);
    }
  });

  test('rejects a non-table B-tree root on page one', () async {
    final file = File(tempDir.path + '/invalid_root.db');
    final bytes = List<int>.from(_sqlitePage());
    bytes[100] = 0x02;
    await file.writeAsBytes(bytes);

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('B-tree'));
  });

  test('supports the SQLite 65536-byte page-size encoding', () async {
    final file = File(tempDir.path + '/large_page.db');
    await file.writeAsBytes(_sqlitePage(pageSize: 65536));

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isTrue);
  });

  test('rejects invalid page sizes and partial final pages', () async {
    final badSize = File(tempDir.path + '/bad_size.db');
    await badSize.writeAsBytes(_sqlitePage(declaredPageSize: 768));
    final sizeResult = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: badSize.path,
    );
    expect(sizeResult.isReady, isFalse);
    expect(sizeResult.error, contains('Invalid SQLite page size'));

    final partial = File(tempDir.path + '/partial.db');
    await partial.writeAsBytes(List<int>.from(_sqlitePage())..add(0));
    final partialResult = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: partial.path,
    );
    expect(partialResult.isReady, isFalse);
    expect(partialResult.error, contains('truncated or misaligned'));
  });

  test('rejects whole-page truncation with authoritative SQLite page count',
      () async {
    final file = File(tempDir.path + '/missing_last_page.db');
    final bytes = _sqlitePage();
    _writeHeaderU32(bytes, 24, 7); // file change counter
    _writeHeaderU32(bytes, 28, 2); // two committed database pages
    _writeHeaderU32(bytes, 92, 7); // page count is authoritative
    // The second 512-byte page is missing, but the file is page-aligned.
    await file.writeAsBytes(bytes);

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('page count'));
    expect(await file.readAsBytes(), bytes); // Never overwrite learner data.
  });

  test('accepts complete committed page count during structural preflight',
      () async {
    final file = File(tempDir.path + '/complete_two_pages.db');
    final firstPage = _sqlitePage();
    _writeHeaderU32(firstPage, 24, 7);
    _writeHeaderU32(firstPage, 28, 2);
    _writeHeaderU32(firstPage, 92, 7);
    await file.writeAsBytes(<int>[
      ...firstPage,
      ...List<int>.filled(512, 0),
    ]);

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isTrue);
  });

  test('does not trust stale SQLite page count with mismatched counters',
      () async {
    final file = File(tempDir.path + '/stale_page_count.db');
    final bytes = _sqlitePage();
    _writeHeaderU32(bytes, 24, 7);
    _writeHeaderU32(bytes, 28, 2);
    _writeHeaderU32(bytes, 92, 6); // Header page count is not authoritative.
    await file.writeAsBytes(bytes);

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isTrue);
    expect(await file.readAsBytes(), bytes);
  });

  test('rejects unsupported SQLite format versions', () async {
    final file = File(tempDir.path + '/bad_version.db');
    await file.writeAsBytes(_sqlitePage(writeVersion: 3));

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('Invalid SQLite header fields'));
  });

  test('accepts SQLite WAL header versions during preflight', () async {
    final file = File(tempDir.path + '/wal.db');
    await file.writeAsBytes(_sqlitePage(writeVersion: 2, readVersion: 2));

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );

    expect(result.isReady, isTrue);
  });

  test('seeder must create a file before bootstrap reports ready', () async {
    final missingPath = tempDir.path + '/seed_did_nothing.sqlite';
    var seedCalls = 0;
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: missingPath,
      onSeedRequired: () async {
        seedCalls++;
      },
    );

    expect(seedCalls, 1);
    expect(result.isReady, isFalse);
    expect(result.error, contains('still missing after seeding'));
    expect(await File(missingPath).exists(), isFalse);
  });

  test('seeder must create a complete page, not only the magic', () async {
    final path = tempDir.path + '/seed_truncated.sqlite';
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: path,
      onSeedRequired: () async {
        await File(path).writeAsBytes('SQLite format 3\x00'.codeUnits);
      },
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('corrupted or truncated'));
  });

  test('newly seeded structural SQLite page passes preflight', () async {
    final path = tempDir.path + '/seeded.sqlite';
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: path,
      onSeedRequired: () async {
        await File(path).writeAsBytes(_sqlitePage());
      },
    );

    expect(result.isReady, isTrue);
    expect(result.error, isNull);
  });

  test('does not run seeder or overwrite an existing database', () async {
    final path = tempDir.path + '/existing.sqlite';
    final original = _sqlitePage();
    await File(path).writeAsBytes(original);
    var seedCalls = 0;

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: path,
      onSeedRequired: () async {
        seedCalls++;
        await File(path).writeAsBytes([1, 2, 3]);
      },
    );

    expect(result.isReady, isTrue);
    expect(seedCalls, 0);
    expect(await File(path).readAsBytes(), original);
  });
}
