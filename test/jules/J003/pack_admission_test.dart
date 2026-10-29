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
  late String tempDir;
  late DatabaseFactory dbFactory;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    dbFactory = databaseFactoryFfi;
    quarantine = StorageQuarantine();
    service = PackAdmissionService(
      quarantine: quarantine,
      dbFactory: dbFactory,
    );
    final dir = Directory.systemTemp.createTempSync('j003_test_');
    tempDir = dir.path;
  });

  tearDown(() {
    final dir = Directory(tempDir);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  Future<File> createValidSqliteFile(String filename) async {
    final path = '$tempDir/$filename';
    final db = await dbFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE data (id INTEGER PRIMARY KEY, value TEXT)');
        await db.execute('CREATE TABLE pack_metadata (languageCode TEXT)');
        await db.execute("INSERT INTO pack_metadata (languageCode) VALUES ('en')");
        await db.execute("INSERT INTO data (value) VALUES ('test')");
      }),
    );
    await db.execute('PRAGMA user_version = 1;');
    await db.close();
    return File(path);
  }

  String calculateHash(File file) {
    final bytes = file.readAsBytesSync();
    return sha256.convert(bytes).toString();
  }

  test('Valid pack admission succeeds and installs correctly', () async {
    final staged = await createValidSqliteFile('staged.db');
    final hash = calculateHash(staged);
    final target = '$tempDir/target.db';

    final result = await service.verifyAndAdmitPack(
      stagedFile: staged,
      expectedHash: hash,
      targetPath: target,
    );

    expect(result, isTrue);
    expect(File(target).existsSync(), isTrue);
    expect(quarantine.isolatedItems.isEmpty, isTrue);
  });

  test('Hash mismatch causes rejection and quarantine', () async {
    final staged = await createValidSqliteFile('staged.db');
    final target = '$tempDir/target.db';

    final result = await service.verifyAndAdmitPack(
      stagedFile: staged,
      expectedHash: 'wronghash',
      targetPath: target,
    );

    expect(result, isFalse);
    expect(File(target).existsSync(), isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, contains('hash mismatch'));
  });

  test('Progress path causes rejection', () async {
    final staged = await createValidSqliteFile('staged.db');
    final hash = calculateHash(staged);
    final target = '$tempDir/user_progress.db';

    final result = await service.verifyAndAdmitPack(
      stagedFile: staged,
      expectedHash: hash,
      targetPath: target,
    );

    expect(result, isFalse);
    expect(File(target).existsSync(), isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, contains('progress'));
  });

  test('Corrupted SQLite (invalid schema version) causes rejection', () async {
    final path = '$tempDir/corrupt.db';
    final db = await dbFactory.openDatabase(path, options: OpenDatabaseOptions(version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE data (id INTEGER PRIMARY KEY)');
        await db.execute('CREATE TABLE pack_metadata (languageCode TEXT)');
        await db.execute("INSERT INTO pack_metadata (languageCode) VALUES ('en')");
        await db.execute("INSERT INTO data (id) VALUES (1)");
    }));
    await db.execute('PRAGMA user_version = 0;');
    await db.close();
    final staged = File(path);
    final hash = calculateHash(staged);
    final target = '$tempDir/target.db';

    final result = await service.verifyAndAdmitPack(
      stagedFile: staged,
      expectedHash: hash,
      targetPath: target,
    );

    expect(result, isFalse);
    expect(File(target).existsSync(), isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
  });

  test('Corrupted SQLite (no tables) causes rejection', () async {
    final path = '$tempDir/notables.db';
    final db = await dbFactory.openDatabase(path, options: OpenDatabaseOptions(version: 1));
    await db.execute('PRAGMA user_version = 1;');
    await db.close();
    final staged = File(path);
    final hash = calculateHash(staged);
    final target = '$tempDir/target.db';

    final result = await service.verifyAndAdmitPack(
      stagedFile: staged,
      expectedHash: hash,
      targetPath: target,
    );

    expect(result, isFalse);
    expect(File(target).existsSync(), isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, contains('No data tables found'));
  });

  test('Corrupted SQLite (empty data table) causes rejection', () async {
    final path = '$tempDir/empty_data.db';
    final db = await dbFactory.openDatabase(path, options: OpenDatabaseOptions(version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE data (id INTEGER PRIMARY KEY)');
        await db.execute('CREATE TABLE pack_metadata (languageCode TEXT)');
        await db.execute("INSERT INTO pack_metadata (languageCode) VALUES ('en')");
    }));
    await db.execute('PRAGMA user_version = 1;');
    await db.close();
    final staged = File(path);
    final hash = calculateHash(staged);
    final target = '$tempDir/target.db';

    final result = await service.verifyAndAdmitPack(
      stagedFile: staged,
      expectedHash: hash,
      targetPath: target,
    );

    expect(result, isFalse);
    expect(File(target).existsSync(), isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, contains('empty'));
  });

  test('Atomic install fails safely if target exists and replacement is not allowed', () async {
    final staged = await createValidSqliteFile('staged.db');
    final hash = calculateHash(staged);
    final target = await createValidSqliteFile('target.db');

    final result = await service.verifyAndAdmitPack(
      stagedFile: staged,
      expectedHash: hash,
      targetPath: target.path,
      allowReplacement: false,
    );

    expect(result, isFalse);

    final result2 = await AtomicDatabaseInstaller.installDatabaseAtomically(
        sourcePath: staged.path, targetPath: target.path, allowReplacement: false);
    expect(result2.status, DatabaseInstallStatus.alreadyExists);
  });

  test('Atomic install replaces safely if target exists and replacement is allowed', () async {
    final staged = await createValidSqliteFile('staged.db');
    final hash = calculateHash(staged);
    final target = await createValidSqliteFile('target.db');

    final result = await service.verifyAndAdmitPack(
      stagedFile: staged,
      expectedHash: hash,
      targetPath: target.path,
      allowReplacement: true,
    );

    expect(result, isTrue);

    final result2 = await AtomicDatabaseInstaller.installDatabaseAtomically(
        sourcePath: staged.path, targetPath: target.path, allowReplacement: true);
    expect(result2.status, DatabaseInstallStatus.replaced);
  });


  test('Corrupted SQLite (missing language identity) causes rejection', () async {
    final path = '$tempDir/missing_lang.db';
    final db = await dbFactory.openDatabase(path, options: OpenDatabaseOptions(version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE data (id INTEGER PRIMARY KEY)');
        await db.execute("INSERT INTO data (id) VALUES (1)");
        // Deliberately omit pack_metadata
    }));
    await db.execute('PRAGMA user_version = 1;');
    await db.close();
    final staged = File(path);
    final hash = calculateHash(staged);
    final target = '$tempDir/target.db';

    final result = await service.verifyAndAdmitPack(
      stagedFile: staged,
      expectedHash: hash,
      targetPath: target,
    );

    expect(result, isFalse);
    expect(File(target).existsSync(), isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, contains('Missing metadata table'));
  });

  test('Fault-injection: corrupted bytes causes rejection', () async {

    final staged = await createValidSqliteFile('staged.db');
    final hash = calculateHash(staged);

    final randomFile = File(staged.path);
    final bytes = await randomFile.readAsBytes();
    if (bytes.isNotEmpty) {
      bytes[0] = bytes[0] ^ 0xFF;
      await randomFile.writeAsBytes(bytes);
    }

    final target = '$tempDir/target.db';

    final result = await service.verifyAndAdmitPack(
      stagedFile: staged,
      expectedHash: hash,
      targetPath: target,
    );

    expect(result, isFalse);
    expect(File(target).existsSync(), isFalse);
  });

  test('Fault-injection: missing source file during install fails gracefully', () async {
    final result = await AtomicDatabaseInstaller.installDatabaseAtomically(
        sourcePath: '$tempDir/nonexistent.db', targetPath: '$tempDir/target.db');

    expect(result.status, DatabaseInstallStatus.failed);
    expect(result.errorMessage, contains('الملف المصدر غير موجود'));
  });

  test('Fault-injection: Empty source file during install fails gracefully', () async {
    final staged = File('$tempDir/empty.db');
    await staged.create();

    final result = await AtomicDatabaseInstaller.installDatabaseAtomically(
        sourcePath: staged.path, targetPath: '$tempDir/target.db');

    expect(result.status, DatabaseInstallStatus.corrupted);
    expect(result.errorMessage, contains('حجم الملف المنسوخ فارغ'));
  });
}
