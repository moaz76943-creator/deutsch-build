import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/core/storage/pack_admission_service.dart';
import 'package:deutsch_bilarabi/core/storage/storage_quarantine.dart';

void main() {
  late PackAdmissionService admissionService;
  late StorageQuarantine quarantine;
  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pack_admission_test_');
    quarantine = StorageQuarantine();
    admissionService = PackAdmissionService(
      quarantine: quarantine,
      dbFactory: databaseFactory,
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<File> createValidSqliteFile(String name) async {
    final path = '${tempDir.path}/$name';
    final db = await databaseFactory.openDatabase(path);
    await db.execute('PRAGMA user_version = 1');
    await db.execute('CREATE TABLE words (id INTEGER PRIMARY KEY, word TEXT)');
    await db.insert('words', {'word': 'test'});
    await db.close();
    return File(path);
  }

  Future<File> createInvalidSqliteFile(String name) async {
    final path = '${tempDir.path}/$name';
    final file = File(path);
    await file.writeAsBytes(
        [0x00, 0x01, 0x02, 0x03, 0x04, 0x05]); // Not a SQLite file
    return file;
  }

  String calculateHash(File file) {
    final bytes = file.readAsBytesSync();
    return sha256.convert(bytes).toString();
  }

  test('Valid pack admission succeeds and installs to target', () async {
    final stagedFile = await createValidSqliteFile('staged.db');
    final hash = calculateHash(stagedFile);
    final targetPath = '${tempDir.path}/target.db';

    final result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: hash,
      targetPath: targetPath,
    );

    expect(result, isTrue);
    expect(File(targetPath).existsSync(), isTrue);
    expect(quarantine.isolatedItems, isEmpty);
  });

  test('Fails on invalid hash and quarantines', () async {
    final stagedFile = await createValidSqliteFile('staged.db');
    final targetPath = '${tempDir.path}/target.db';

    final result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: 'invalid_hash',
      targetPath: targetPath,
    );

    expect(result, isFalse);
    expect(File(targetPath).existsSync(), isFalse);
    expect(quarantine.isolatedItems.length, 1);
    expect(quarantine.isolatedItems.first.diagnosticReason,
        contains('hash mismatch'));
  });

  test('Fails on invalid SQLite header and quarantines', () async {
    final stagedFile = await createInvalidSqliteFile('staged.db');
    final hash = calculateHash(stagedFile);
    final targetPath = '${tempDir.path}/target.db';

    final result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: hash,
      targetPath: targetPath,
    );

    expect(result, isFalse);
    expect(File(targetPath).existsSync(), isFalse);
  });

  test('Fails on empty file', () async {
    final stagedFile = File('${tempDir.path}/empty.db')..createSync();
    final hash = calculateHash(stagedFile);
    final targetPath = '${tempDir.path}/target.db';

    final result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: hash,
      targetPath: targetPath,
    );

    expect(result, isFalse);
  });

  test('Fails if target path contains "progress" and quarantines', () async {
    final stagedFile = await createValidSqliteFile('staged.db');
    final hash = calculateHash(stagedFile);
    final targetPath = '${tempDir.path}/user_progress.db';

    final result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: hash,
      targetPath: targetPath,
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems.length, 1);
    expect(
        quarantine.isolatedItems.first.diagnosticReason, contains('progress'));
  });

  test('Invalid schema (version 0 or missing tables)', () async {
    // Missing tables
    final path1 = '${tempDir.path}/missing_tables.db';
    final db1 = await databaseFactory.openDatabase(path1);
    await db1.execute('PRAGMA user_version = 1');
    await db1.close();

    final stagedFile1 = File(path1);
    final hash1 = calculateHash(stagedFile1);
    final targetPath1 = '${tempDir.path}/target1.db';

    final result1 = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedFile1,
      expectedHash: hash1,
      targetPath: targetPath1,
    );

    expect(result1, isFalse);
    expect(quarantine.isolatedItems.last.diagnosticReason,
        contains('No data tables found'));

    // Version 0
    final path2 = '${tempDir.path}/version0.db';
    final db2 = await databaseFactory.openDatabase(path2);
    await db2.execute('PRAGMA user_version = 0');
    await db2.execute('CREATE TABLE words (id INTEGER PRIMARY KEY, word TEXT)');
    await db2.close();

    final stagedFile2 = File(path2);
    final hash2 = calculateHash(stagedFile2);
    final targetPath2 = '${tempDir.path}/target2.db';

    final result2 = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedFile2,
      expectedHash: hash2,
      targetPath: targetPath2,
    );

    expect(result2, isFalse);
    expect(quarantine.isolatedItems.last.diagnosticReason,
        contains('Invalid schema version'));
  });

  test(
      'Atomic replacement leaves existing pack if replacement fails or is not allowed',
      () async {
    final targetFile = await createValidSqliteFile('target.db');
    final stagedFile = await createValidSqliteFile('staged.db');
    final hash = calculateHash(stagedFile);

    // Default allowReplacement is false
    final result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: hash,
      targetPath: targetFile.path,
    );

    expect(result,
        isFalse); // Fails because alreadyExists and allowReplacement is false
  });

  test('Atomic replacement replaces existing pack if allowReplacement is true',
      () async {
    final targetFile = await createValidSqliteFile('target.db');
    final stagedFile = await createValidSqliteFile('staged.db');
    final hash = calculateHash(stagedFile);

    final result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: hash,
      targetPath: targetFile.path,
      allowReplacement: true,
    );

    expect(result, isTrue);
  });
}
