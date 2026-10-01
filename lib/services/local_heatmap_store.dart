import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'database_migration_helper.dart';

class LocalHeatmapStore {
  static const String _tableName = 'study_activity';
  static const String _columnDate = 'date';
  static const String _columnCount = 'count';

  static final LocalHeatmapStore instance = LocalHeatmapStore._init();
  static Database? _database;

  LocalHeatmapStore._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('heatmap.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await DatabaseMigrationHelper.open(
      path: path,
      version: 1,
      onCreate: _createDB,
      migrationScripts: {},
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnDate TEXT PRIMARY KEY,
        $_columnCount INTEGER NOT NULL
      )
    ''');
  }

  Future<void> logActivity(DateTime date, {int count = 1}) async {
    final db = await instance.database;
    final dateString = _formatDate(date);

    // Using compatible SQLite approach (without UPSERT which needs SQLite 3.24.0+)
    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      final maps = await txn.query(
        _tableName,
        where: '$_columnDate = ?',
        whereArgs: [dateString],
      );

      if (maps.isEmpty) {
        await txn.insert(_tableName, {
          _columnDate: dateString,
          _columnCount: count,
        });
      } else {
        final currentCount = maps.first[_columnCount] as int;
        await txn.update(
          _tableName,
          {_columnCount: currentCount + count},
          where: '$_columnDate = ?',
          whereArgs: [dateString],
        );
      }
    });
  }

  Future<Map<DateTime, int>> getYearlyActivity(int year) async {
    final db = await instance.database;
    final yearString = year.toString();

    final maps = await db.query(
      _tableName,
      where: '$_columnDate LIKE ?',
      whereArgs: ['$yearString-%'],
    );

    final result = <DateTime, int>{};
    for (var map in maps) {
      final date = DateTime.parse(map[_columnDate] as String);
      final count = map[_columnCount] as int;
      result[date] = count;
    }

    return result;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
