import 'package:sqflite_common/sqlite_api.dart';

import 'sqlite_policy.dart';

class SmartMistakesLedger {
  static const String _tableName = 'smart_mistakes';
  static const String _columnWordId = 'word_id';
  static const String _columnRating = 'rating';
  static const String _columnTimestamp = 'timestamp';
  static const String _columnCount = 'mistake_count';

  static final SmartMistakesLedger instance = SmartMistakesLedger._init();
  static Database? _database;
  static const AppSqlitePolicy _sqlitePolicy = AppSqlitePolicy();

  SmartMistakesLedger._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_mistakes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = await _sqlitePolicy.resolvePath(fileName: filePath);
    return _sqlitePolicy.openWritable(
      path: path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnWordId TEXT PRIMARY KEY,
        $_columnRating TEXT NOT NULL,
        $_columnTimestamp TEXT NOT NULL,
        $_columnCount INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> logMistake(
    String wordId,
    String rating,
    DateTime timestamp,
  ) async {
    final db = await instance.database;
    final timestampString = timestamp.toIso8601String();

    await db.transaction((txn) async {
      final maps = await txn.query(
        _tableName,
        where: '$_columnWordId = ?',
        whereArgs: [wordId],
      );

      if (maps.isEmpty) {
        await txn.insert(_tableName, {
          _columnWordId: wordId,
          _columnRating: rating,
          _columnTimestamp: timestampString,
          _columnCount: 1,
        });
      } else {
        final currentCount = maps.first[_columnCount] as int;
        await txn.update(
          _tableName,
          {
            _columnCount: currentCount + 1,
            _columnRating: rating,
            _columnTimestamp: timestampString,
          },
          where: '$_columnWordId = ?',
          whereArgs: [wordId],
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getDifficultWords({int limit = 50}) async {
    final db = await instance.database;

    final maps = await db.query(
      _tableName,
      orderBy: '$_columnCount DESC, $_columnTimestamp DESC',
      limit: limit,
    );

    return maps;
  }

  Future<void> clear() async {
    final db = await instance.database;
    await db.delete(_tableName);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
