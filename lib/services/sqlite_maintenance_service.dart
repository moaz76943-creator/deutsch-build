import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class SqliteMaintenanceService {
  final DatabaseService _dbService;

  SqliteMaintenanceService({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<void> performMaintenance() async {
    final progressDb = await _dbService.progressDb;
    await _checkpointWal(progressDb);
    await _cleanupTempFiles();
  }

  Future<void> _checkpointWal(Database db) async {
    try {
      // TRUNCATE checkpoint mode for WAL
      // The result of PRAGMA wal_checkpoint is a single row with 3 columns.
      // [busy, log, checkpointed]
      // If busy is 1, it means a checkpoint could not complete because of active connections.
      // In that case, we gracefully abort the checkpoint instead of retrying to avoid deadlocks.
      final results = await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE);');
      if (results.isNotEmpty) {
         final row = results.first;
         final busy = row['busy'] as int?;
         if (busy == 1) {
             // Safe handling: active leased transaction or open connection prevented full checkpoint
         }
      }
    } catch (e) {
      if (e is DatabaseException) {
         if (e.toString().contains('database is locked') || e.toString().contains('SQLITE_BUSY')) {
            // Safe handling
         } else {
            rethrow;
         }
      } else {
         rethrow;
      }
    }
  }

  Future<void> _cleanupTempFiles() async {
    try {
      final dbPath = await getDatabasesPath();
      final dir = Directory(dbPath);
      if (await dir.exists()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.tmp')) {
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
  }
}
