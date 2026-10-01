import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/offline_backup_system.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('OfflineBackupSystem', () {
    late OfflineBackupSystem backupSystem;
    late Directory backupDir;
    late String dbPath;

    setUp(() async {
      backupSystem = OfflineBackupSystem();
      backupDir = await Directory.systemTemp.createTemp('backup_test_');
      dbPath = await getDatabasesPath();

      // Ensure test dbs are clean
      final testDbs = [
        'heatmap.db',
        'user_vocabulary.db',
        'milestones.db',
        'reverse_quiz.db',
      ];

      for (final dbName in testDbs) {
        final path = p.join(dbPath, dbName);
        if (await File(path).exists()) {
          await File(path).delete();
        }
      }
    });

    tearDown(() async {
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
    });

    test(
      'exportDatabases correctly copies databases to backup directory',
      () async {
        // Create a dummy database
        final dummyDbPath = p.join(dbPath, 'heatmap.db');
        final db = await openDatabase(
          dummyDbPath,
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)',
            );
            await db.insert('Test', {'name': 'exported'});
          },
        );
        await db.close();

        // Export
        await backupSystem.exportDatabases(backupDir.path);

        // Verify
        final exportedFile = File(p.join(backupDir.path, 'heatmap.db'));
        expect(await exportedFile.exists(), isTrue);

        // Read back from the exported file
        final exportedDb = await openDatabase(exportedFile.path);
        final maps = await exportedDb.query('Test');
        expect(maps.first['name'], equals('exported'));
        await exportedDb.close();
      },
    );

    test(
      'restoreDatabases correctly copies databases from backup directory',
      () async {
        // Setup backup directory with a dummy database
        final dummyBackupDbPath = p.join(backupDir.path, 'milestones.db');
        final db = await openDatabase(
          dummyBackupDbPath,
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)',
            );
            await db.insert('Test', {'name': 'restored'});
          },
        );
        await db.close();

        // Restore
        await backupSystem.restoreDatabases(backupDir.path);

        // Verify
        final restoredFile = File(p.join(dbPath, 'milestones.db'));
        expect(await restoredFile.exists(), isTrue);

        // Read back from restored file
        final restoredDb = await openDatabase(restoredFile.path);
        final maps = await restoredDb.query('Test');
        expect(maps.first['name'], equals('restored'));
        await restoredDb.close();
      },
    );

    test('restoreDatabases throws FileSystemException if backup directory does not exist', () async {
      final invalidDir = p.join(
        Directory.systemTemp.path,
        'non_existent_dir_12345',
      );

      expect(
        () => backupSystem.restoreDatabases(invalidDir),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
