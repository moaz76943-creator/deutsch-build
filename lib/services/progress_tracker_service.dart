import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'database_migration_helper.dart';

class ProgressTrackerService {
  static const String _tableNameCompletedLessons = 'completed_lessons';
  static const String _tableNameStreaks = 'daily_streaks';
  static const String _tableNameReviewScores = 'review_scores';

  static final ProgressTrackerService instance = ProgressTrackerService._init();
  Database? _database;
  DatabaseFactory? _factory;

  ProgressTrackerService._init();

  // For testing
  factory ProgressTrackerService.withFactory(DatabaseFactory factory) {
    final service = ProgressTrackerService._init();
    service._factory = factory;
    return service;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('progress_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    if (_factory != null) {
      path = filePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = p.join(dbPath, filePath);
    }

    return await DatabaseMigrationHelper.open(
      path: path,
      version: 1,
      onCreate: _createDB,
      migrationScripts: {},
      factory: _factory,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableNameCompletedLessons (
        id TEXT PRIMARY KEY,
        completedAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $_tableNameStreaks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        count INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $_tableNameReviewScores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lessonId TEXT NOT NULL,
        score REAL NOT NULL,
        reviewedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> markLessonCompleted(String lessonId) async {
    final db = await database;
    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.insert(_tableNameCompletedLessons, {
        'id': lessonId,
        'completedAt': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> updateStreak(String date, int count) async {
    final db = await database;
    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.insert(_tableNameStreaks, {
        'date': date,
        'count': count,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> updateReviewScore(String lessonId, double score) async {
    final db = await database;
    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.insert(_tableNameReviewScores, {
        'lessonId': lessonId,
        'score': score,
        'reviewedAt': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<String> exportProgressState() async {
    final db = await database;

    final completedLessons = await db.query(_tableNameCompletedLessons);
    final streaks = await db.query(_tableNameStreaks);
    final reviewScores = await db.query(_tableNameReviewScores);

    final state = {
      'completed_lessons': completedLessons,
      'daily_streaks': streaks,
      'review_scores': reviewScores,
    };

    return jsonEncode(state);
  }

  Future<void> importProgressState(String jsonState) async {
    final Map<String, dynamic> state = jsonDecode(jsonState);
    final db = await database;

    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.delete(_tableNameCompletedLessons);
      await txn.delete(_tableNameStreaks);
      await txn.delete(_tableNameReviewScores);

      final completedLessons = state['completed_lessons'] as List<dynamic>?;
      if (completedLessons != null) {
        for (var lesson in completedLessons) {
          await txn.insert(
            _tableNameCompletedLessons,
            Map<String, dynamic>.from(lesson as Map),
          );
        }
      }

      final streaks = state['daily_streaks'] as List<dynamic>?;
      if (streaks != null) {
        for (var streak in streaks) {
          await txn.insert(
            _tableNameStreaks,
            Map<String, dynamic>.from(streak as Map),
          );
        }
      }

      final reviewScores = state['review_scores'] as List<dynamic>?;
      if (reviewScores != null) {
        for (var score in reviewScores) {
          await txn.insert(
            _tableNameReviewScores,
            Map<String, dynamic>.from(score as Map),
          );
        }
      }
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
