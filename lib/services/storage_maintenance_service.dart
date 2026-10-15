import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class StorageMaintenanceService {
  final DatabaseService _dbService;

  StorageMaintenanceService({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<void> performStorageMaintenance() async {
    final progressDb = await _dbService.progressDb;

    // Do not alter global connection state, just attempt VACUUM
    try {
      await progressDb.execute('VACUUM');
    } catch (e) {
      if (e is DatabaseException) {
         if (e.toString().contains('database is locked') || e.toString().contains('SQLITE_BUSY')) {
            // Safe handling: abort maintenance instead of waiting on lease
         } else if (e.toString().contains('database or disk is full')) {
            // Safe handling for low disk space
         } else if (e.toString().contains('readonly database')) {
            // FFI might map readOnly sometimes during VACUUM, ignore safely
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
          if (e.toString().contains('readonly database') || e.toString().contains('database is locked') || e.toString().contains('SQLITE_BUSY')) {
             // Ignore
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
       await progressDb.execute('CREATE TEMP TABLE IF NOT EXISTS _low_storage_check (id INTEGER PRIMARY KEY)');
       await progressDb.execute('INSERT INTO _low_storage_check DEFAULT VALUES');
       await progressDb.execute('DROP TABLE _low_storage_check');
     } catch (e) {
       if (e is DatabaseException) {
          if (e.toString().contains('database or disk is full')) {
             return;
          }
          rethrow;
       } else {
          rethrow;
       }
     }
  }
}
