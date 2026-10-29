import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/database/bootstrap/database_bootstrapper.dart';

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

  test('يرفض الملفات التالفة أو التي لا تحتوي ترويسة SQLite', () async {
    final corruptFile = File('${tempDir.path}/corrupt.db');
    await corruptFile.writeAsString('Fake non-sqlite content');

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: corruptFile.path,
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('Invalid SQLite header signature'));
  });

  test('يقبل الملف السليم الذي يبدأ بترويسة SQLite format 3', () async {
    final validFile = File('${tempDir.path}/valid.db');
    final headerBytes = 'SQLite format 3\x00'.codeUnits;
    await validFile.writeAsBytes(headerBytes);

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: validFile.path,
    );

    expect(result.isReady, isTrue);
    expect(result.error, isNull);
  });

<<<<<<< HEAD
  test('seeder must create a file before SQLite bootstrap reports ready', () async {
    final missingPath = '${tempDir.path}/seed_did_nothing.sqlite';
=======
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

  test('seeder must not present a zero-length file as ready', () async {
    final path = tempDir.path + '/seed_empty.sqlite';
    var seedCalls = 0;
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: path,
      onSeedRequired: () async {
        seedCalls++;
        await File(path).writeAsBytes(const <int>[]);
      },
    );

    expect(seedCalls, 1);
    expect(result.isReady, isFalse);
    expect(result.error, contains('corrupted or truncated'));
    expect(await File(path).length(), 0);
  });

  test('seeder must create a file before bootstrap reports ready', () async {
    final missingPath = tempDir.path + '/seed_did_nothing.sqlite';
>>>>>>> origin/staging/v2-full-platform
    var seedCalls = 0;
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: missingPath,
      onSeedRequired: () async { seedCalls++; },
    );

    expect(seedCalls, 1);
    expect(result.isReady, isFalse);
    expect(result.error, contains('still missing after seeding'));
    expect(await File(missingPath).exists(), isFalse);
  });

  test('newly seeded SQLite file proceeds through header verification', () async {
    final seededPath = '${tempDir.path}/seeded.sqlite';
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: seededPath,
      onSeedRequired: () async {
        await File(seededPath).writeAsBytes('SQLite format 3\x00'.codeUnits);
      },
    );

    expect(result.isReady, isTrue);
    expect(result.error, isNull);
  });
}
