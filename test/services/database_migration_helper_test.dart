import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/database_migration_helper.dart';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseMigrationHelper', () {
    late String dbPath;
    late String backupsDir;

    setUp(() async {
      final dbDir = Directory.systemTemp.createTempSync('db_mig_test');
      dbPath = p.join(dbDir.path, 'test_db.db');
      backupsDir = p.join(dbDir.path, 'backups');
    });

    tearDown(() async {
      final dbFile = File(dbPath);
      if (dbFile.existsSync()) {
        final dir = dbFile.parent;
        dir.deleteSync(recursive: true);
      }
    });

    test('Creates database successfully', () async {
      final db = await DatabaseMigrationHelper.open(
        path: dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)',
          );
        },
        migrationScripts: {},
      );

      await db.insert('Test', {'name': 'Initial'});
      final res = await db.query('Test');
      expect(res.length, 1);
      expect(res.first['name'], 'Initial');

      await db.close();
    });

    test('Upgrades database and creates backup correctly', () async {
      // 1. Create v1
      var db = await DatabaseMigrationHelper.open(
        path: dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)',
          );
        },
        migrationScripts: {},
      );

      await db.insert('Test', {'name': 'V1Data'});
      await db.close();

      // 2. Upgrade to v2
      db = await DatabaseMigrationHelper.open(
        path: dbPath,
        version: 2,
        onCreate: (db, version) async {},
        migrationScripts: {
          2: ['ALTER TABLE Test ADD COLUMN age INTEGER'],
        },
      );

      await db.update('Test', {'age': 30});
      final res = await db.query('Test');
      expect(res.first['age'], 30);
      expect(res.first['name'], 'V1Data');

      await db.close();

      // 3. Verify backup file exists
      final backupDirectory = Directory(backupsDir);
      expect(backupDirectory.existsSync(), isTrue);

      final backupFiles = backupDirectory.listSync();
      expect(backupFiles.isNotEmpty, isTrue);

      bool foundV1Backup = false;
      for (final entity in backupFiles) {
        if (entity is File && entity.path.contains('_v1_')) {
          foundV1Backup = true;
          break;
        }
      }
      expect(foundV1Backup, isTrue);
    });

    test('Executes multiple migration scripts sequentially', () async {
      // 1. Create v1
      var db = await DatabaseMigrationHelper.open(
        path: dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE MigrationTest (id INTEGER PRIMARY KEY)',
          );
        },
        migrationScripts: {},
      );
      await db.close();

      // 2. Upgrade from v1 to v3 directly
      db = await DatabaseMigrationHelper.open(
        path: dbPath,
        version: 3,
        onCreate: (db, version) async {},
        migrationScripts: {
          2: ['ALTER TABLE MigrationTest ADD COLUMN col2 TEXT'],
          3: ['ALTER TABLE MigrationTest ADD COLUMN col3 TEXT'],
        },
      );

      await db.insert('MigrationTest', {'col2': 'A', 'col3': 'B'});
      final res = await db.query('MigrationTest');
      expect(res.first['col2'], 'A');
      expect(res.first['col3'], 'B');

      await db.close();
    });
  });
}
