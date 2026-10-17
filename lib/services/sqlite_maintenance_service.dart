<<<<<<< HEAD
import 'dart:io';
=======
>>>>>>> origin/main
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class SqliteMaintenanceService {
<<<<<<< HEAD
  final DatabaseService _dbService;

  SqliteMaintenanceService({DatabaseService? dbService, DatabaseService? databaseService})
      : _dbService = dbService ?? databaseService ?? DatabaseService.instance;

  Future<void> performMaintenance([Database? targetDb]) async {
    final db = targetDb ?? await _dbService.progressDb;
    try {
      List<Map<String, Object?>> checkpointResult;
      try {
        checkpointResult = await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE);');
=======
  SqliteMaintenanceService({DatabaseService? databaseService});

  Future<void> performMaintenance(Database db) async {
    try {
      List<Map<String, Object?>> checkpointResult;
      try {
        checkpointResult = await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
>>>>>>> origin/main
      } on DatabaseException catch (e) {
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('readonly') || errorMessage.contains('read-only')) {
          return;
        }
        rethrow;
      }

      if (checkpointResult.isNotEmpty) {
        final busyFlag = checkpointResult.first['busy'] as int?;
        if (busyFlag == 1) {
          return;
        }
      }

      await db.execute('REINDEX');
<<<<<<< HEAD
=======

>>>>>>> origin/main
    } on DatabaseException catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('busy') ||
          errorMessage.contains('locked') ||
          errorMessage.contains('disk is full') ||
          errorMessage.contains('sqlite_full') ||
          errorMessage.contains('readonly') ||
          errorMessage.contains('read-only')) {
        return;
      }
      rethrow;
    }
<<<<<<< HEAD

    if (targetDb == null) {
      await _cleanupTempFiles();
    }
  }

  Future<void> _cleanupTempFiles() async {
    try {
      final dbPath = await getDatabasesPath();
      final dir = Directory(dbPath);
      if (await dir.exists()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is File && (entity.path.endsWith('.tmp') || entity.path.endsWith('-journal.tmp'))) {
            try {
              await entity.delete();
            } catch (e) {
              // ignore
            }
          }
        }
      }
    } catch (e) {
      // ignore
    }
=======
>>>>>>> origin/main
  }
}
