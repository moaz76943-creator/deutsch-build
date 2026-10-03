import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common/sqlite_api.dart';

/// Single policy boundary for ordinary application SQLite databases.
///
/// Active content packs are intentionally excluded: Phase 7 routes those
/// encrypted databases through PackDatabaseOpener/SQLCipher.
final class AppSqlitePolicy {
  const AppSqlitePolicy({this.factory});

  static const int busyTimeoutMilliseconds = 5000;

  final DatabaseFactory? factory;

  Future<String> resolvePath({
    required String fileName,
    String? overridePath,
  }) async {
    final explicit = overridePath?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    if (p.basename(fileName) != fileName || fileName.trim().isEmpty) {
      throw const SqlitePolicyException('invalid_database_file_name');
    }
    if (factory != null) {
      return fileName;
    }
    final root = await sqflite.getDatabasesPath();
    return p.join(root, fileName);
  }

  Future<Database> openWritable({
    required String path,
    required int version,
    OnDatabaseCreateFn? onCreate,
    OnDatabaseVersionChangeFn? onUpgrade,
    OnDatabaseVersionChangeFn? onDowngrade,
    OnDatabaseOpenFn? onOpen,
    OnDatabaseConfigureFn? onConfigure,
    bool foreignKeys = true,
  }) async {
    if (path.trim().isEmpty || version <= 0) {
      throw const SqlitePolicyException('invalid_database_open_request');
    }

    final options = OpenDatabaseOptions(
      version: version,
      onConfigure: (database) async {
        await _configureConnection(database, foreignKeys: foreignKeys);
        if (onConfigure != null) {
          await onConfigure(database);
        }
      },
      onCreate: onCreate,
      onUpgrade: onUpgrade,
      onDowngrade: onDowngrade,
      onOpen: onOpen,
    );

    return (factory ?? sqflite.databaseFactory).openDatabase(
      path,
      options: options,
    );
  }

  Future<Database> openReadOnly({
    required String path,
    OnDatabaseOpenFn? onOpen,
  }) async {
    if (path.trim().isEmpty) {
      throw const SqlitePolicyException('invalid_database_open_request');
    }
    return (factory ?? sqflite.databaseFactory).openDatabase(
      path,
      options: OpenDatabaseOptions(
        readOnly: true,
        singleInstance: false,
        onOpen: onOpen,
      ),
    );
  }

  static Future<void> _configureConnection(
    Database database, {
    required bool foreignKeys,
  }) async {
    await database.execute(
      'PRAGMA foreign_keys = ' + (foreignKeys ? 'ON' : 'OFF'),
    );
    await database.execute(
      'PRAGMA busy_timeout = ' + busyTimeoutMilliseconds.toString(),
    );

    final foreignKeyRows = await database.rawQuery('PRAGMA foreign_keys');
    final foreignKeyValue =
        foreignKeyRows.isEmpty ? null : foreignKeyRows.first.values.first;
    final expected = foreignKeys ? 1 : 0;
    if (foreignKeyValue != expected) {
      throw const SqlitePolicyException('foreign_key_policy_not_applied');
    }
  }
}

final class SqlitePolicyException implements Exception {
  const SqlitePolicyException(this.code);

  final String code;

  @override
  String toString() => 'SqlitePolicyException(' + code + ')';
}
