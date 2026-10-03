import 'package:sqflite_common/sqlite_api.dart';

import '../../../services/sqlite_policy.dart';

class VerbMatrixDatabase {
  static const String _dbName = 'verb_matrix.db';
  static const String _attemptsTable = 'verb_attempts';

  Database? _db;
  final AppSqlitePolicy _sqlitePolicy;
  final String? _inMemoryPath;

  VerbMatrixDatabase({DatabaseFactory? factory, String? path})
      : _sqlitePolicy = AppSqlitePolicy(factory: factory),
        _inMemoryPath = path;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = await _sqlitePolicy.resolvePath(
      fileName: _dbName,
      overridePath: _inMemoryPath,
    );
    return _sqlitePolicy.openWritable(
      path: path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_attemptsTable (
        id TEXT PRIMARY KEY,
        infinitive TEXT NOT NULL,
        person TEXT NOT NULL,
        isCorrect INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        timeTaken INTEGER NOT NULL
      )
    ''');
  }

  Future<void> recordAttempt(Map<String, dynamic> attempt) async {
    final db = await database;
    await db.insert(
      _attemptsTable,
      attempt,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAttempts() async {
    final db = await database;
    return await db.query(_attemptsTable, orderBy: 'timestamp DESC');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _db = null;
  }
}
