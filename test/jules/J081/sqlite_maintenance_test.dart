import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:deutsch_bilarabi/services/sqlite_maintenance_service.dart';
import 'package:deutsch_bilarabi/services/storage_maintenance_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Maintenance Services', () {
    test('SqliteMaintenanceService applies WAL checkpoint correctly', () async {
      final dbPath = join(await getDatabasesPath(), 'test_progress_1.db');
      if (await File(dbPath).exists()) await File(dbPath).delete();

      final db = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE t (id INTEGER PRIMARY KEY)');
      });
      await db.execute('PRAGMA journal_mode=WAL');
      await db.execute('INSERT INTO t (id) VALUES (1)');

      final maintenance = SqliteMaintenanceService(
        progressDatabase: () async => db,
        thresholdBytes: 0,
        minimumCheckpointGap: Duration.zero,
      );
      final report = await maintenance.maintain();

      expect(report.checkpointAttempted, isTrue);
      expect(report.checkpointSucceeded, isTrue);
      await db.close();
    });

    test('SqliteMaintenanceService handles busy databases gracefully without crashing', () async {
      final dbPath = join(await getDatabasesPath(), 'test_progress_busy.db');
      if (await File(dbPath).exists()) await File(dbPath).delete();

      final db1 = await openDatabase(dbPath, version: 1, singleInstance: false, onCreate: (db, version) async {
        await db.execute('CREATE TABLE t (id INTEGER PRIMARY KEY)');
      });
      await db1.execute('PRAGMA journal_mode=WAL');
      await db1.execute('INSERT INTO t (id) VALUES (1)');

      final db2 = await openDatabase(dbPath, singleInstance: false);
      await db2.execute('BEGIN EXCLUSIVE');

      final maintenance = SqliteMaintenanceService(
        progressDatabase: () async => db1,
        thresholdBytes: 0,
        minimumCheckpointGap: Duration.zero,
      );
      final report = await maintenance.maintain();

      expect(report.checkpointAttempted, isTrue);
      expect(report.checkpointSucceeded, isFalse);

      await db2.execute('ROLLBACK');
      await db2.close();
      await db1.close();
    });

    test('SqliteMaintenanceService ignores read-only databases', () async {
      final dbPath = join(await getDatabasesPath(), 'test_progress_ro.db');
      if (await File(dbPath).exists()) await File(dbPath).delete();

      final db1 = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE t (id INTEGER PRIMARY KEY)');
      });
      await db1.execute('PRAGMA journal_mode=WAL');
      await db1.execute('INSERT INTO t (id) VALUES (1)');
      await db1.close();

      final dbReadOnly = await openReadOnlyDatabase(dbPath);
      final maintenance = SqliteMaintenanceService(
        progressDatabase: () async => dbReadOnly,
        thresholdBytes: 0,
        minimumCheckpointGap: Duration.zero,
      );
      final report = await maintenance.maintain();

      expect(report.checkpointAttempted, isFalse);
      expect(report.checkpointSucceeded, isFalse);

      await dbReadOnly.close();
    });

    test('StorageMaintenanceService cleanupTemporaryFiles removes only tmp files', () async {
      final dbPath = Directory(await getDatabasesPath());
      final tmpFile = File(join(dbPath.path, 'test.tmp'));
      final dbFile = File(join(dbPath.path, 'keep.sqlite'));

      final sqliteHeader = <int>[83, 81, 76, 105, 116, 101, 32, 102, 111, 114, 109, 97, 116, 32, 51, 0];
      final fp = await dbFile.open(mode: FileMode.write);
      await fp.writeFrom(sqliteHeader);
      await fp.close();

      await tmpFile.writeAsString('tmp data');

      expect(await tmpFile.exists(), isTrue);
      expect(await dbFile.exists(), isTrue);

      final service = StorageMaintenanceService(
        packDirectory: dbPath,
        minimumFileAge: Duration.zero,
      );
      final report = await service.purgeOrphanedFiles();

      expect(report.deletedPartialFiles, 1);
      expect(await tmpFile.exists(), isFalse);
      expect(await dbFile.exists(), isTrue);
    });

    test('StorageMaintenanceService deletes corrupted pack and not recent ones', () async {
      final dbPath = Directory(await getDatabasesPath());
      final corruptedFile = File(join(dbPath.path, 'corrupted.sqlite'));

      final fp = await corruptedFile.open(mode: FileMode.write);
      await fp.writeFrom(<int>[1, 2, 3, 4]);
      await fp.close();

      var service = StorageMaintenanceService(
        packDirectory: dbPath,
        minimumFileAge: const Duration(hours: 24),
      );
      var report = await service.purgeOrphanedFiles();

      expect(report.deletedCorruptedPacks, 0);
      expect(await corruptedFile.exists(), isTrue);

      service = StorageMaintenanceService(
        packDirectory: dbPath,
        minimumFileAge: Duration.zero,
      );
      report = await service.purgeOrphanedFiles();

      expect(report.deletedCorruptedPacks, 1);
      expect(await corruptedFile.exists(), isFalse);
    });
  });
}
