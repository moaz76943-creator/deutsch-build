import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class VerbMatrixDatabase {
  static const String _dbName = 'verb_matrix.db';
  static const String _attemptsTable = 'verb_attempts';

  Database? _db;
  final DatabaseFactory? _dbFactory;
  final String? _inMemoryPath;

  VerbMatrixDatabase({DatabaseFactory? factory, String? path})
      : _dbFactory = factory, _inMemoryPath = path;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path;
    if (_inMemoryPath != null) {
      path = _inMemoryPath!;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, _dbName);
    }

    if (_dbFactory != null) {
      return await _dbFactory!.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    }

    return await openDatabase(
      path,
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
