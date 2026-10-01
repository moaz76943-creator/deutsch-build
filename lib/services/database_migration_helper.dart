import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseMigrationHelper {
  static Future<Database> openSafeDatabase({
    required String path,
    int? version,
    OnDatabaseCreateFn? onCreate,
    OnDatabaseVersionChangeFn? onUpgrade,
    OnDatabaseVersionChangeFn? onDowngrade,
    OnDatabaseOpenFn? onOpen,
    DatabaseFactory? factory,
  }) async {
    final dbFactory = factory ?? databaseFactory;

    try {
      return await dbFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: version,
          onCreate: onCreate,
          onUpgrade: onUpgrade,
          onDowngrade: onDowngrade,
          onOpen: onOpen,
        ),
      );
    } catch (e) {
      // If there is an error, try to restore from backup
      final file = File(path);
      final backup = File('$path.bak');
      final walBackup = File('$path.bak-wal');
      final shmBackup = File('$path.bak-shm');

      final dbWal = File('$path-wal');
      final dbShm = File('$path-shm');

      if (await backup.exists()) {
        try {
          if (await file.exists()) await file.delete();
          if (await dbWal.exists()) await dbWal.delete();
          if (await dbShm.exists()) await dbShm.delete();

          await backup.copy(path);
          if (await walBackup.exists()) await walBackup.copy('$path-wal');
          if (await shmBackup.exists()) await shmBackup.copy('$path-shm');

          return await dbFactory.openDatabase(
            path,
            options: OpenDatabaseOptions(
              version: version,
              onCreate: onCreate,
              onUpgrade: onUpgrade,
              onDowngrade: onDowngrade,
              onOpen: onOpen,
            ),
          );
        } catch (e2) {
          // If restore fails, we'll just throw the original error or let it fail
        }
      }

      // If we couldn't restore, delete the corrupted file and try creating fresh
      try {
        if (await file.exists()) await file.delete();
        if (await dbWal.exists()) await dbWal.delete();
        if (await dbShm.exists()) await dbShm.delete();
      } catch (_) {}

      return await dbFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: version,
          onCreate: onCreate,
          onUpgrade: onUpgrade,
          onDowngrade: onDowngrade,
          onOpen: onOpen,
        ),
      );
    }
  }

  static Future<T> executeAtomic<T>(
    Database db,
    Future<T> Function(Transaction txn) action,
  ) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        final result = await db.transaction((txn) async {
          return await action(txn);
        });

        // Background backup
        _triggerBackup(db.path).catchError((_) {});

        return result;
      } catch (e) {
        if (attempts >= 3) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 100 * attempts));
      }
    }
  }

  static Future<void> _triggerBackup(String path) async {
    try {
      final file = File(path);
      final wal = File('$path-wal');
      final shm = File('$path-shm');

      final backup = File('$path.bak');
      final walBackup = File('$path.bak-wal');
      final shmBackup = File('$path.bak-shm');

      if (await file.exists()) await file.copy(backup.path);
      if (await wal.exists()) await wal.copy(walBackup.path);
      if (await shm.exists()) await shm.copy(shmBackup.path);
    } catch (_) {
      // Best effort background backup, ignore failures
    }
  }
}
