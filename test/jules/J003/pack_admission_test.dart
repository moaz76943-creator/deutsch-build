import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/core/storage/pack_admission_service.dart';
import 'package:deutsch_bilarabi/core/storage/storage_quarantine.dart';
import 'package:deutsch_bilarabi/core/storage/atomic_database_installer.dart';
import 'package:crypto/crypto.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Pack Admission Tests', () {
    late PackAdmissionService service;
    late StorageQuarantine quarantine;
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('pack_admission_test_');
      quarantine = StorageQuarantine();
      service = PackAdmissionService(
        quarantine: quarantine,
        dbFactory: databaseFactory,
      );
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Valid pack admission with atomic installation', () async {
      final stagingPath = '${tempDir.path}/test_staging.db';
      final targetPath = '${tempDir.path}/test_target.db';

      final stagingFile = File(stagingPath);
      final targetFile = File(targetPath);

      final db = await databaseFactory.openDatabase(stagingPath, options: OpenDatabaseOptions(version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE Test (id INTEGER PRIMARY KEY)');
      }));
      await db.close();

      final bytes = stagingFile.readAsBytesSync();
      final digest = sha256.convert(bytes).toString();

      final result = await service.verifyAndAdmitPack(
        stagedFile: stagingFile,
        expectedHash: digest,
        targetPath: targetPath,
        allowReplacement: true,
      );

      expect(result, isTrue);
      expect(targetFile.existsSync(), isTrue);
    });

    test('Rejects empty or non-existent files', () async {
      final result = await service.verifyAndAdmitPack(
        stagedFile: File('${tempDir.path}/non_existent.db'),
        expectedHash: 'hash',
        targetPath: '${tempDir.path}/target.db',
      );
      expect(result, isFalse);
    });

    test('Rejects progress database path', () async {
      final stagingPath = '${tempDir.path}/test_staging2.db';
      final stagingFile = File(stagingPath);
      stagingFile.writeAsBytesSync([1, 2, 3]);

      final result = await service.verifyAndAdmitPack(
        stagedFile: stagingFile,
        expectedHash: 'hash',
        targetPath: '${tempDir.path}/user_progress.db',
      );
      expect(result, isFalse);

      final qItems = quarantine.isolatedItems;
      expect(qItems.isNotEmpty, isTrue);
      expect(qItems.first.diagnosticReason, contains('progress'));
    });

    test('Rejects corrupted bytes (invalid header/integrity)', () async {
      final stagingPath = '${tempDir.path}/test_corrupt.db';
      final stagingFile = File(stagingPath);
      stagingFile.writeAsStringSync('not an sqlite database');

      final digest = sha256.convert(stagingFile.readAsBytesSync()).toString();

      final result = await service.verifyAndAdmitPack(
        stagedFile: stagingFile,
        expectedHash: digest,
        targetPath: '${tempDir.path}/target_corrupt.db',
      );
      expect(result, isFalse);

      final qItems = quarantine.isolatedItems;
      expect(qItems.isNotEmpty, isTrue);
    });

    test('Rejects mismatched hash', () async {
      final stagingPath = '${tempDir.path}/test_staging3.db';
      final stagingFile = File(stagingPath);
      stagingFile.writeAsBytesSync([1, 2, 3]);

      final result = await service.verifyAndAdmitPack(
        stagedFile: stagingFile,
        expectedHash: 'wrong_hash',
        targetPath: '${tempDir.path}/target.db',
      );
      expect(result, isFalse);

      final qItems = quarantine.isolatedItems;
      expect(qItems.isNotEmpty, isTrue);
      expect(qItems.first.diagnosticReason, contains('SHA-256 hash mismatch'));
    });

    test('Rejects invalid schema version', () async {
      final stagingPath = '${tempDir.path}/invalid_schema.db';
      final stagingFile = File(stagingPath);

      final db = await databaseFactory.openDatabase(stagingPath, options: OpenDatabaseOptions(version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE Test (id INTEGER PRIMARY KEY)');
      }));
      // Reset version to 0 to make it invalid
      await db.rawQuery('PRAGMA user_version = 0');
      await db.close();

      final digest = sha256.convert(stagingFile.readAsBytesSync()).toString();
      final result = await service.verifyAndAdmitPack(
        stagedFile: stagingFile,
        expectedHash: digest,
        targetPath: '${tempDir.path}/target.db',
      );
      expect(result, isFalse);
    });

    test('Handles insufficient disk during copy', () async {
      // It's hard to simulate insufficient disk space perfectly in a unit test,
      // but we can simulate a failed copy by trying to replace a file that we don't have permission to,
      // or a directory path.
      final stagingPath = '${tempDir.path}/staging_space.db';
      final stagingFile = File(stagingPath);

      final db = await databaseFactory.openDatabase(stagingPath, options: OpenDatabaseOptions(version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE Test (id INTEGER PRIMARY KEY)');
      }));
      await db.close();

      // We create a directory at the target path instead of a file
      final targetDir = Directory('${tempDir.path}/target_space.db');
      targetDir.createSync();

      final digest = sha256.convert(stagingFile.readAsBytesSync()).toString();
      final result = await service.verifyAndAdmitPack(
        stagedFile: stagingFile,
        expectedHash: digest,
        targetPath: targetDir.path,
      );

      expect(result, isFalse);
    });

  });
}
