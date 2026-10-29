import 'package:sqflite_common/sqlite_api.dart';

import '../../../services/database_migration_helper.dart';
import '../../../services/sqlite_policy.dart';

class ReverseQuizDatabase {
  static const String _dbName = 'reverse_quiz.db';
  static const String _flashcardsTable = 'flashcards';
  static const String _attemptsTable = 'quiz_attempts';

  Database? _db;
  final DatabaseFactory? _dbFactory;
  final AppSqlitePolicy _sqlitePolicy;
  final String? _inMemoryPath;

  ReverseQuizDatabase({DatabaseFactory? factory, String? path})
      : _dbFactory = factory,
        _sqlitePolicy = AppSqlitePolicy(factory: factory),
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
    return DatabaseMigrationHelper.open(
      path: path,
      version: 1,
      onCreate: _createDB,
      migrationScripts: const <int, List<String>>{},
      factory: _dbFactory,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_flashcardsTable (
        id TEXT PRIMARY KEY,
        conceptId TEXT NOT NULL,
        german TEXT NOT NULL,
        arabic TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_attemptsTable (
        id TEXT PRIMARY KEY,
        cardId TEXT NOT NULL,
        isCorrect INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (cardId) REFERENCES $_flashcardsTable (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> insertFlashcards(List<Map<String, dynamic>> cards) async {
    final db = await database;
    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      for (final card in cards) {
        await txn.insert(
          _flashcardsTable,
          card,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getRandomFlashcards(int count) async {
    final db = await database;
    return await db.query(_flashcardsTable, orderBy: 'RANDOM()', limit: count);
  }

  Future<void> recordAttempt(Map<String, dynamic> attempt) async {
    final db = await database;
    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.insert(
        _attemptsTable,
        attempt,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _db = null;
  }
}
