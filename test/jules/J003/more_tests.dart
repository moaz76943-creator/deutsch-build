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

  group('Atomic Replacement Failures', () {
    late PackAdmissionService service;
    late StorageQuarantine quarantine;
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('pack_admission_more_tests_');
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

    test('Preserves existing valid pack if new pack fails integrity', () async {
      final stagingPath = '${tempDir.path}/test_staging4.db';
      final targetPath = '${tempDir.path}/test_target2.db';

      final stagingFile = File(stagingPath);
      final targetFile = File(targetPath);

      // Create a valid existing target db
      final db = await databaseFactory.openDatabase(targetPath, options: OpenDatabaseOptions(version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE TargetData (id INTEGER PRIMARY KEY)');
      }));
      await db.close();

      // Create a corrupted staging file
      stagingFile.writeAsStringSync('corrupted db');
      final digest = sha256.convert(stagingFile.readAsBytesSync()).toString();

      final result = await service.verifyAndAdmitPack(
        stagedFile: stagingFile,
        expectedHash: digest,
        targetPath: targetPath,
        allowReplacement: true,
      );

      expect(result, isFalse);

      // Target file should still exist and be valid
      expect(targetFile.existsSync(), isTrue);
    });

    test('Handles interrupted rename', () async {
        // AtomicDatabaseInstaller handles rename failures gracefully
        final sourcePath = '${tempDir.path}/interrupted_source.db';
        final targetPath = '${tempDir.path}/interrupted_target.db';

        final sourceFile = File(sourcePath);
        sourceFile.writeAsStringSync('fake db content');

        // Lock the target file by opening it so rename fails
        final targetFile = File(targetPath);
        targetFile.writeAsStringSync('existing target');

        final res = await AtomicDatabaseInstaller.installDatabaseAtomically(
            sourcePath: sourcePath,
            targetPath: targetPath,
            allowReplacement: false
        );

        expect(res.status, DatabaseInstallStatus.alreadyExists);

        // if allowReplacement = true, rename target to directory to fail
        targetFile.deleteSync();
        final targetDir = Directory(targetPath);
        targetDir.createSync();

        final res2 = await AtomicDatabaseInstaller.installDatabaseAtomically(
            sourcePath: sourcePath,
            targetPath: targetPath,
            allowReplacement: true
        );
        expect(res2.status, DatabaseInstallStatus.failed);

        // Verify .tmp cleanup
        expect(File('$targetPath.tmp').existsSync(), isFalse);
    });

    test('Recovery after restart', () async {
        final targetPath = '${tempDir.path}/target.db';
        final tmpPath = '$targetPath.tmp';

        // Simulating that a previous attempt left an orphaned .tmp file
        final tmpFile = File(tmpPath);
        tmpFile.writeAsStringSync('orphaned data');

        final sourcePath = '${tempDir.path}/source.db';
        final sourceFile = File(sourcePath);
        sourceFile.writeAsStringSync('new valid data');

        final res = await AtomicDatabaseInstaller.installDatabaseAtomically(
            sourcePath: sourcePath,
            targetPath: targetPath,
            allowReplacement: true
        );

        expect(res.status, DatabaseInstallStatus.installed);
    });
  });
}
