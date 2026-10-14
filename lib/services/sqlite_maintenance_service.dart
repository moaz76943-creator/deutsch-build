import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class SqliteMaintenanceService {
  final DatabaseService _databaseService;

  SqliteMaintenanceService({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  Future<void> performMaintenance() async {
    final db = await _databaseService.progressDb;

    // 1. WAL Checkpoint
    try {
      // Bounded WAL cleanup: use TRUNCATE first, fallback to PASSIVE if busy
      // wal_checkpoint returns [busy, log, checkpointed].
      // If busy == 1, it means the TRUNCATE could not complete fully due to concurrent readers/writers.
      final result = await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
      if (result.isNotEmpty && result.first.values.first == 1) {
         // Truncate failed due to locks, fallback to PASSIVE
         await db.rawQuery('PRAGMA wal_checkpoint(PASSIVE)');
      }
    } on DatabaseException catch (e) {
      if (e.isDatabaseClosedError()) {
        rethrow;
      }
      final msg = e.toString().toLowerCase();
      // Explicit busy or locked handling if an actual exception is thrown
      if (msg.contains('locked') || msg.contains('busy')) {
        try {
          await db.rawQuery('PRAGMA wal_checkpoint(PASSIVE)');
        } catch (_) {
          // If PASSIVE also fails, we gracefully skip.
        }
      } else if (msg.contains('full')) {
        // Low storage handled gracefully without deleting data
        throw StorageFullException('Disk is full. Cannot perform checkpoint.');
      } else {
        rethrow;
      }
    }

    // 2. Rebuild disposable indexes
    try {
      // Using REINDEX to actually rebuild disposable indexes from valid source data
      await db.execute('REINDEX');
      // Also ANALYZE for query planner
      await db.execute('ANALYZE');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('full')) {
        throw StorageFullException('Disk is full. Cannot perform REINDEX.');
      }
      // Index rebuild errors are recoverable, we just ignore them during maintenance
    }

    // Note: We deliberately do NOT manually delete -wal or -shm files.
    // SQLite strictly manages its own journal files. Deleting them causes
    // irrecoverable data loss and corruption.
  }
}

class StorageFullException implements Exception {
  final String message;
  StorageFullException(this.message);
  @override
  String toString() => 'StorageFullException: $message';
}
