import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SentenceBridgeDatabase {
  static const String _dbName = 'sentence_bridge_puzzle.db';
  static const String _puzzlesTable = 'puzzles';
  static const String _attemptsTable = 'puzzle_attempts';

  Database? _db;
  final DatabaseFactory? _dbFactory;
  final String? _inMemoryPath;

  SentenceBridgeDatabase({DatabaseFactory? factory, String? path})
    : _dbFactory = factory,
      _inMemoryPath = path;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path;
    if (_inMemoryPath != null) {
      path = _inMemoryPath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, _dbName);
    }

    if (_dbFactory != null) {
      return await _dbFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
      );
    }

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_puzzlesTable (
        id TEXT PRIMARY KEY,
        conceptId TEXT NOT NULL,
        germanSentence TEXT NOT NULL,
        arabicSentence TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_attemptsTable (
        id TEXT PRIMARY KEY,
        puzzleId TEXT NOT NULL,
        isCorrect INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        timeTakenMs INTEGER NOT NULL,
        FOREIGN KEY (puzzleId) REFERENCES $_puzzlesTable (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> insertPuzzles(List<Map<String, dynamic>> puzzles) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final puzzle in puzzles) {
        await txn.insert(
          _puzzlesTable,
          puzzle,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getRandomPuzzles(int count) async {
    final db = await database;
    return await db.query(_puzzlesTable, orderBy: 'RANDOM()', limit: count);
  }

  Future<void> recordAttempt(Map<String, dynamic> attempt) async {
    final db = await database;
    await db.insert(
      _attemptsTable,
      attempt,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
