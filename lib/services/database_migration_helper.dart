import 'dart:io';

import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart' as p;

import 'sqlite_policy.dart';

class DatabaseMigrationHelper {
  /// Opens the database, handling backups and migrations automatically.
  ///
  /// [path] The database file path.
  /// [version] The target database version.
  /// [onCreate] The callback invoked if the database is created for the first time.
  /// [migrationScripts] A map where the key is the target version and the value is a list of SQL queries to execute to reach that version from the previous version.
  /// [factory] Optional DatabaseFactory for testing or specialized environments.
  static Future<Database> open({
    required String path,
    required int version,
    required OnDatabaseCreateFn onCreate,
    required Map<int, List<String>> migrationScripts,
    DatabaseFactory? factory,
  }) async {
    final options = OpenDatabaseOptions(
      version: version,
      onCreate: onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Perform backup before any migrations run
        await _backupDatabase(path, oldVersion);

        // Execute migrations sequentially
        for (int v = oldVersion + 1; v <= newVersion; v++) {
          final scripts = migrationScripts[v];
          if (scripts != null) {
            for (final script in scripts) {
              await db.execute(script);
            }
          }
        }
      },
    );

    return AppSqlitePolicy(factory: factory).openWritable(
      path: path,
      version: options.version ?? version,
      onCreate: options.onCreate,
      onUpgrade: options.onUpgrade,
    );
  }

  /// Creates a backup of the main `.db` file as well as `-wal` and `-shm` files if they exist.
  static Future<void> _backupDatabase(String dbPath, int currentVersion) async {
    try {
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) return; // Nothing to backup

      final directory = p.dirname(dbPath);
      final basename = p.basenameWithoutExtension(dbPath);
      final extension = p.extension(dbPath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final backupPrefix = p.join(directory, 'backups');
      final backupDir = Directory(backupPrefix);
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final backupBaseName = '${basename}_v${currentVersion}_$timestamp';
      final backupPath = p.join(backupPrefix, '$backupBaseName$extension');

      // Copy main database file
      await dbFile.copy(backupPath);

      // Copy WAL and SHM files if they exist
      final walFile = File('$dbPath-wal');
      if (await walFile.exists()) {
        await walFile.copy('$backupPath-wal');
      }

      final shmFile = File('$dbPath-shm');
      if (await shmFile.exists()) {
        await shmFile.copy('$backupPath-shm');
      }
    } on Object {
      // Backup is best-effort. Do not emit exception details into production
      // logs; migration continuity is intentionally preserved.
    }
  }

  static Future<T> executeAtomic<T>(
    Database db,
    Future<T> Function(Transaction txn) action,
  ) async {
    return await db.transaction((txn) async => await action(txn));
  }
}
