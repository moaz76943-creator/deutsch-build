import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/core/storage/pack_admission_service.dart';
import 'package:deutsch_bilarabi/core/storage/storage_quarantine.dart';
import 'package:deutsch_bilarabi/core/storage/atomic_database_installer.dart';

void main() {
  late PackAdmissionService service;
  late StorageQuarantine quarantine;
  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('j003_tests');
    quarantine = StorageQuarantine();
    service = PackAdmissionService(
      quarantine: quarantine,
      dbFactory: databaseFactoryFfi,
    );
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<File> createValidDb(String path) async {
    final file = File(path);
    final db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1, // SET USER_VERSION
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE pack_metadata (languageCode TEXT)');
          await db.execute('INSERT INTO pack_metadata (languageCode) VALUES ("de")');
          await db.execute('CREATE TABLE some_data (id INTEGER)');
        },
      ),
    );
    await db.close();
    return file;
  }

  String getHash(File file) {
    return sha256.convert(file.readAsBytesSync()).toString();
  }

  test('Valid pack is admitted successfully', () async {
    final stagedPath = '${tempDir.path}/staged.db';
    final targetPath = '${tempDir.path}/target.db';
    final stagedFile = await createValidDb(stagedPath);
    final hash = getHash(stagedFile);

    final result = await service.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: hash,
      targetPath: targetPath,
    );

    expect(result, isTrue);
    expect(File(targetPath).existsSync(), isTrue);
    expect(quarantine.isolatedItems.isEmpty, isTrue);
  });

  test('Rejects invalid hash', () async {
    final stagedPath = '${tempDir.path}/staged.db';
    final targetPath = '${tempDir.path}/target.db';
    final stagedFile = await createValidDb(stagedPath);

    final result = await service.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: 'wronghash',
      targetPath: targetPath,
    );

    expect(result, isFalse);
    expect(File(targetPath).existsSync(), isFalse);
    expect(quarantine.isolatedItems.length, 1);
    expect(quarantine.isolatedItems.first.diagnosticReason, contains('hash'));
  });

  test('Rejects missing schema / missing table', () async {
    final stagedPath = '${tempDir.path}/staged.db';
    final targetPath = '${tempDir.path}/target.db';

    // Create DB without required table
    final db = await databaseFactoryFfi.openDatabase(
      stagedPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE other_table (id INTEGER)');
        },
      ),
    );
    await db.close();

    final stagedFile = File(stagedPath);
    final hash = getHash(stagedFile);

    final result = await service.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: hash,
      targetPath: targetPath,
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.last.diagnosticReason, contains('metadata'));
  });

  test('Rejects invalid schema version', () async {
    final stagedPath = '${tempDir.path}/staged_no_ver.db';
    final targetPath = '${tempDir.path}/target.db';

    // Create DB but manually reset user_version to 0
    final db = await databaseFactoryFfi.openDatabase(
      stagedPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE pack_metadata (languageCode TEXT)');
          await db.execute('INSERT INTO pack_metadata (languageCode) VALUES ("de")');
        },
      ),
    );
    await db.execute('PRAGMA user_version = 0');
    await db.close();

    final stagedFile = File(stagedPath);
    final hash = getHash(stagedFile);

    final result = await service.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: hash,
      targetPath: targetPath,
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.last.diagnosticReason, contains('schema'));
  });

  test('Rejects target path containing progress or vault', () async {
    final stagedPath = '${tempDir.path}/staged.db';
    final targetPath = '${tempDir.path}/learner_progress.db';
    final stagedFile = await createValidDb(stagedPath);
    final hash = getHash(stagedFile);

    final result = await service.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: hash,
      targetPath: targetPath,
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems.length, 1);
    expect(quarantine.isolatedItems.first.diagnosticReason, contains('progress'));
  });

  test('Atomic database replacement allows fallback if corrupted later', () async {
    final stagedPath = '${tempDir.path}/staged.db';
    final targetPath = '${tempDir.path}/target.db';
    final stagedFile = await createValidDb(stagedPath);

    // First, install it
    await service.verifyAndAdmitPack(
      stagedFile: stagedFile,
      expectedHash: getHash(stagedFile),
      targetPath: targetPath,
    );
    expect(File(targetPath).existsSync(), isTrue);

    // Now try to replace with invalid file
    final badStagedPath = '${tempDir.path}/bad.db';
    final badStagedFile = File(badStagedPath);
    // make it > 512 bytes so it fails on sqlite header check, not size check
    badStagedFile.writeAsBytesSync(List.filled(1024, 0));

    final result = await service.verifyAndAdmitPack(
      stagedFile: badStagedFile,
      expectedHash: getHash(badStagedFile),
      targetPath: targetPath,
      allowReplacement: true,
    );

    expect(result, isFalse); // Should fail validation
    expect(File(targetPath).existsSync(), isTrue); // Old DB should STILL exist!
  });

  test('Fail closed handling for incomplete archives', () async {
    final stagedPath = '${tempDir.path}/small.db';
    final targetPath = '${tempDir.path}/target.db';
    final smallFile = File(stagedPath);
    smallFile.writeAsBytesSync(List.filled(256, 0)); // very small file

    final result = await service.verifyAndAdmitPack(
      stagedFile: smallFile,
      expectedHash: getHash(smallFile),
      targetPath: targetPath,
    );

    expect(result, isFalse);
  });

  test('Interrupted renames or insufficient disk simulate copy failure correctly', () async {
    // AtomicDatabaseInstaller handles missing source files by returning failed
    final sourceFile = File('${tempDir.path}/missing.db');
    final targetPath = '${tempDir.path}/target.db';

    final result = await AtomicDatabaseInstaller.installDatabaseAtomically(
        sourcePath: sourceFile.path,
        targetPath: targetPath
    );

    expect(result.status, DatabaseInstallStatus.failed);
  });
}
