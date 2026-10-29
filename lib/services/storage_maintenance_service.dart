import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'sqlite_maintenance_service.dart';

class StorageMaintenanceService {
  final DatabaseService _dbService;
  final SqliteMaintenanceService _sqliteMaintenanceService;

  StorageMaintenanceService({
    DatabaseService? dbService,
    SqliteMaintenanceService? sqliteMaintenanceService,
  })  : _dbService = dbService ?? DatabaseService.instance,
        _sqliteMaintenanceService = sqliteMaintenanceService ?? SqliteMaintenanceService();

  Future<void> runMaintenance(Database db) async {
    await _sqliteMaintenanceService.performMaintenance(db);
  }

  Future<void> cleanupTemporaryFiles() async {
    try {
      final dbPath = await getDatabasesPath();
      final directory = Directory(dbPath);
      if (!await directory.exists()) {
        return;
      }

      final files = directory.listSync();
      for (final file in files) {
        if (file is File) {
          final filename = file.uri.pathSegments.last;
          if (filename.endsWith('.tmp') || filename.endsWith('-journal.tmp')) {
            try {
              await file.delete();
            } on FileSystemException {
              // ignore
            }
          }
        }
      }
    } on FileSystemException {
      // ignore directory access errors
    }
  }

  Future<void> performStorageMaintenance() async {
    final progressDb = await _dbService.progressDb;
    try {
      await progressDb.execute('VACUUM');
    } catch (e) {
      if (e is DatabaseException) {
        final err = e.toString().toLowerCase();
        if (err.contains('database is locked') ||
            err.contains('sqlite_busy') ||
            err.contains('database or disk is full') ||
            err.contains('readonly') ||
            err.contains('read-only')) {
          return;
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  Future<void> rebuildDisposableIndexes() async {
    final progressDb = await _dbService.progressDb;
    try {
      await progressDb.execute('DROP INDEX IF EXISTS idx_srs_progress_status;');
      await progressDb.execute('CREATE INDEX idx_srs_progress_status ON srs_progress (status);');
    } catch (e) {
      if (e is DatabaseException) {
        final err = e.toString().toLowerCase();
        if (err.contains('readonly') ||
            err.contains('read-only') ||
            err.contains('database is locked') ||
            err.contains('sqlite_busy')) {
          return;
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  Future<void> checkLowStorage() async {
    final progressDb = await _dbService.progressDb;
    try {
      await progressDb.execute('CREATE TEMP TABLE IF NOT EXISTS _low_storage_check (id INTEGER PRIMARY KEY);');
      await progressDb.execute('INSERT INTO _low_storage_check DEFAULT VALUES;');
      await progressDb.execute('DROP TABLE _low_storage_check;');
    } catch (e) {
      if (e is DatabaseException) {
        final err = e.toString().toLowerCase();
        if (err.contains('database or disk is full') || err.contains('sqlite_full')) {
          return;
        }
        rethrow;
      } else {
        rethrow;
      }
    }
  }
}
