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
  return bytes;
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
    expect(result.error, contains('truncated or misaligned'));
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

  test('rejects a non-table B-tree root on page one', () async {
    final file = File(tempDir.path + '/invalid_root.db');
    final bytes = List<int>.from(_sqlitePage())..[100] = 0x02;
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
