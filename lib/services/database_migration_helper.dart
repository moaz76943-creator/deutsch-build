import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseMigrationHelper {
  static Future<Database> openAndMigrate({
    required String dbName,
    required int version,
    required Future<void> Function(Database db, int version) onCreate,
    Future<void> Function(Database db, int oldVersion, int newVersion)? onUpgrade,
    Future<void> Function(Database db, int oldVersion, int newVersion)? onDowngrade,
    DatabaseFactory? factory,
    String? inMemoryPath,
  }) async {
    String path;
    if (inMemoryPath != null) {
      path = inMemoryPath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, dbName);
    }

    if (factory != null) {
      return await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: version,
          onCreate: onCreate,
          onUpgrade: onUpgrade,
          onDowngrade: onDowngrade,
        ),
      );
    }

    return await openDatabase(
      path,
      version: version,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
      onDowngrade: onDowngrade,
    );
  }
}
