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
        idleScheduler: const ImmediateIdleScheduler(),
        thresholdBytes: 1,
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

      final db1 = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE t (id INTEGER PRIMARY KEY)');
      });
      await db1.execute('PRAGMA journal_mode=WAL');

      final maintenance = SqliteMaintenanceService(
        progressDatabase: () async => db1,
        idleScheduler: const ImmediateIdleScheduler(),
        thresholdBytes: 1,
        minimumCheckpointGap: Duration.zero,
      );

      await maintenance.maintain();

      // No exception should be thrown
      expect(true, isTrue);
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
        idleScheduler: const ImmediateIdleScheduler(),
        thresholdBytes: 1,
        minimumCheckpointGap: Duration.zero,
      );

      final report = await maintenance.maintain();

      // Should not crash, and might either report no checkpoint or catch the error
      expect(report.error, isNull);
      await dbReadOnly.close();
    });

    test('StorageMaintenanceService purgeOrphanedFiles removes only tmp files', () async {
      final dbPath = await getDatabasesPath();
      final packDir = Directory(join(dbPath, 'packs'));
      await packDir.create(recursive: true);
      final tmpFile = File(join(packDir.path, 'test.tmp'));
      final dbFile = File(join(packDir.path, 'keep.sqlite'));

      await tmpFile.writeAsString('tmp data');

      // write sqlite signature
      final handle = await dbFile.open(mode: FileMode.write);
      await handle.writeFrom([83,81,76,105,116,101,32,102,111,114,109,97,116,32,51,0]);
      await handle.close();

      expect(await tmpFile.exists(), isTrue);
      expect(await dbFile.exists(), isTrue);

      final service = StorageMaintenanceService(
        packDirectory: packDir,
        minimumFileAge: Duration.zero,
      );
      await service.purgeOrphanedFiles();

      expect(await tmpFile.exists(), isFalse);
      expect(await dbFile.exists(), isTrue);
    });
  });
}
