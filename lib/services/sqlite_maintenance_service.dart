import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class SqliteMaintenanceService {
  SqliteMaintenanceService({DatabaseService? databaseService});

  Future<void> performMaintenance(Database db) async {
    try {
      List<Map<String, Object?>> checkpointResult;
      try {
        checkpointResult = await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
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
  }
}
