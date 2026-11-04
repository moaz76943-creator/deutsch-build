import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/core/storage/pack_admission_service.dart';
import 'package:deutsch_bilarabi/core/storage/storage_quarantine.dart';
import 'package:path/path.dart' as path;

void main() {
  late PackAdmissionService service;
  late StorageQuarantine quarantine;
  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    quarantine = StorageQuarantine();
    service = PackAdmissionService(
      quarantine: quarantine,
      dbFactory: databaseFactoryFfi,
    );
    tempDir = await Directory.systemTemp.createTemp('j003_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<File> createValidDatabase(String dbPath) async {
    final db = await databaseFactoryFfi.openDatabase(dbPath);
    await db.execute('PRAGMA user_version = 1;');
    await db.execute('CREATE TABLE words (id INTEGER PRIMARY KEY, word TEXT);');
    await db.insert('words', {'word': 'hallo'});
    await db.close();
    return File(dbPath);
  }

  String getFileHash(File file) {
    final bytes = file.readAsBytesSync();
    return sha256.convert(bytes).toString();
  }

  test('Valid pack admission succeeds and installs atomically', () async {
    final sourceFile = File(path.join(tempDir.path, 'source.db'));
    await createValidDatabase(sourceFile.path);
    final targetFile = File(path.join(tempDir.path, 'target.db'));

    final hash = getFileHash(sourceFile);

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: hash,
      targetPath: targetFile.path,
      languageIdentity: 'de',
      expectedRowCount: 1,
    );

    expect(result, isTrue);
    expect(await targetFile.exists(), isTrue);
    expect(quarantine.isolatedItems, isEmpty);
  });

  test('Rejects missing file', () async {
    final missingFile = File(path.join(tempDir.path, 'missing.db'));
    final result = await service.verifyAndAdmitPack(
      stagedFile: missingFile,
      expectedHash: 'dummy',
      targetPath: path.join(tempDir.path, 'target.db'),
      languageIdentity: 'de',
      expectedRowCount: 0,
    );
    expect(result, isFalse);
  });

  test('Rejects file pointing to progress database', () async {
    final sourceFile = File(path.join(tempDir.path, 'source.db'));
    await createValidDatabase(sourceFile.path);
    final targetPath = path.join(tempDir.path, 'user_progress.db');

    final hash = getFileHash(sourceFile);

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: hash,
      targetPath: targetPath,
      languageIdentity: 'de',
      expectedRowCount: 1,
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems, isNotEmpty);
    expect(
        quarantine.isolatedItems.first.diagnosticReason, contains('progress'));
  });

  test('Rejects empty file', () async {
    final sourceFile = File(path.join(tempDir.path, 'empty.db'));
    await sourceFile.writeAsBytes([]);

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: 'dummy',
      targetPath: path.join(tempDir.path, 'target.db'),
      languageIdentity: 'de',
      expectedRowCount: 0,
    );

    expect(result, isFalse);
  });

  test('Rejects file with wrong hash', () async {
    final sourceFile = File(path.join(tempDir.path, 'source.db'));
    await createValidDatabase(sourceFile.path);

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: 'wronghash',
      targetPath: path.join(tempDir.path, 'target.db'),
      languageIdentity: 'de',
      expectedRowCount: 0,
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems, isNotEmpty);
    expect(quarantine.isolatedItems.first.diagnosticReason,
        contains('hash mismatch'));
  });

  test('Rejects file with invalid SQLite header', () async {
    final sourceFile = File(path.join(tempDir.path, 'corrupt.db'));
    await sourceFile.writeAsBytes(List.generate(100, (i) => i));
    final hash = getFileHash(sourceFile);

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: hash,
      targetPath: path.join(tempDir.path, 'target.db'),
      languageIdentity: 'de',
      expectedRowCount: 0,
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems, isNotEmpty);
    expect(quarantine.isolatedItems.first.diagnosticReason, contains('header'));
  });

  test('Rejects file without tables', () async {
    final sourceFile = File(path.join(tempDir.path, 'notables.db'));
    final db = await databaseFactoryFfi.openDatabase(sourceFile.path);
    await db.execute('PRAGMA user_version = 1;');
    await db.close();

    final hash = getFileHash(sourceFile);

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: hash,
      targetPath: path.join(tempDir.path, 'target.db'),
      languageIdentity: 'de',
      expectedRowCount: 0,
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems, isNotEmpty);
    expect(quarantine.isolatedItems.first.diagnosticReason,
        contains('No data tables found'));
  });

  test('Rejects file with user_version <= 0', () async {
    final sourceFile = File(path.join(tempDir.path, 'noversion.db'));
    final db = await databaseFactoryFfi.openDatabase(sourceFile.path);
    await db.execute('CREATE TABLE words (id INTEGER PRIMARY KEY);');
    await db.close();

    final hash = getFileHash(sourceFile);

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: hash,
      targetPath: path.join(tempDir.path, 'target.db'),
      languageIdentity: 'de',
      expectedRowCount: 0,
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems, isNotEmpty);
    expect(quarantine.isolatedItems.first.diagnosticReason,
        contains('schema version'));
  });

  test('Atomic replacement leaves existing pack intact if not replaced',
      () async {
    final targetFile =
        await createValidDatabase(path.join(tempDir.path, 'target.db'));
    final originalHash = getFileHash(targetFile);

    final sourceFile = File(path.join(tempDir.path, 'source.db'));
    await createValidDatabase(sourceFile.path);
    final hash = getFileHash(sourceFile);

    // We don't set allowReplacement = true
    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: hash,
      targetPath: targetFile.path,
      languageIdentity: 'de',
      expectedRowCount: 1,
    );

    expect(result, isFalse);
    // Ensure target still exists and has original content
    expect(getFileHash(targetFile), originalHash);
  });

  test('Interrupted renames handled safely', () async {
    final sourceFile = File(path.join(tempDir.path, 'source.db'));
    await createValidDatabase(sourceFile.path);
    final targetPath = path.join(tempDir.path, 'target.db');

    // Create a dangling .tmp file
    final tempPath = '$targetPath.tmp';
    await File(tempPath).writeAsBytes([1, 2, 3]);

    final hash = getFileHash(sourceFile);

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: hash,
      targetPath: targetPath,
      languageIdentity: 'de',
      expectedRowCount: 1,
    );

    expect(result, isTrue);
    expect(await File(targetPath).exists(), isTrue);
    expect(await File(tempPath).exists(),
        isFalse); // tmp file should be cleaned up
  });

  test('Rejects missing expected rows', () async {
    final sourceFile = File(path.join(tempDir.path, 'source.db'));
    await createValidDatabase(sourceFile.path);

    final hash = getFileHash(sourceFile);

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: hash,
      targetPath: path.join(tempDir.path, 'target.db'),
      languageIdentity: 'de',
      expectedRowCount: 50, // Expects 50 rows, but we only have 1
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems, isNotEmpty);
    expect(
        quarantine.isolatedItems.last.diagnosticReason, contains('Row count'));
  });
}
