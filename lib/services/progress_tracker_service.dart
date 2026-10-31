import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/srs_facets.dart';
import '../models/learner.dart';
import 'database_migration_helper.dart';
import 'spaced_repetition_service.dart';

class ProgressTrackerService {
  static const String _tableNameCompletedLessons = 'completed_lessons';
  static const String _tableNameStreaks = 'daily_streaks';
  static const String _tableNameReviewScores = 'review_scores';
  static const String _tableNameSpacedRepetition = 'spaced_repetition';

  static final ProgressTrackerService instance = ProgressTrackerService._init();
  Database? _database;
  DatabaseFactory? _factory;

  ProgressTrackerService._init();

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
    final path = _factory != null
        ? filePath
        : p.join(await getDatabasesPath(), filePath);

    return DatabaseMigrationHelper.open(
      path: path,
      version: 3,
      onCreate: _createDB,
      migrationScripts: <int, List<String>>{
        2: <String>[
          '''
          CREATE TABLE $_tableNameSpacedRepetition (
            id TEXT PRIMARY KEY,
            ef REAL NOT NULL,
            repetitions INTEGER NOT NULL,
            intervalDays INTEGER NOT NULL,
            nextReviewAt TEXT NOT NULL
          )
          ''',
        ],
        3: <String>[
          "ALTER TABLE $_tableNameSpacedRepetition "
              "ADD COLUMN conceptId TEXT NOT NULL DEFAULT ''",
          "ALTER TABLE $_tableNameSpacedRepetition "
              "ADD COLUMN facetType TEXT NOT NULL DEFAULT 'meaning_recall'",
          "ALTER TABLE $_tableNameSpacedRepetition "
              "ADD COLUMN variantKey TEXT NOT NULL DEFAULT ''",
          "ALTER TABLE $_tableNameSpacedRepetition "
              "ADD COLUMN lapses INTEGER NOT NULL DEFAULT 0",
          "ALTER TABLE $_tableNameSpacedRepetition "
              "ADD COLUMN successes INTEGER NOT NULL DEFAULT 0",
          "ALTER TABLE $_tableNameSpacedRepetition "
              "ADD COLUMN failures INTEGER NOT NULL DEFAULT 0",
          "ALTER TABLE $_tableNameSpacedRepetition "
              "ADD COLUMN difficulty REAL NOT NULL DEFAULT 1.3",
          "ALTER TABLE $_tableNameSpacedRepetition "
              "ADD COLUMN stabilityDays REAL NOT NULL DEFAULT 0",
          "ALTER TABLE $_tableNameSpacedRepetition "
              "ADD COLUMN lastReviewedAt TEXT",
          "UPDATE $_tableNameSpacedRepetition SET conceptId = id "
              "WHERE conceptId = ''",
          "UPDATE $_tableNameSpacedRepetition SET successes = repetitions "
              "WHERE successes = 0 AND repetitions > 0",
          "UPDATE $_tableNameSpacedRepetition SET stabilityDays = intervalDays "
              "WHERE stabilityDays = 0 AND intervalDays > 0",
          "CREATE UNIQUE INDEX IF NOT EXISTS idx_spaced_repetition_facet "
              "ON $_tableNameSpacedRepetition(conceptId, facetType, variantKey)",
        ],
      },
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
    await db.execute('''
      CREATE TABLE $_tableNameSpacedRepetition (
        id TEXT PRIMARY KEY,
        conceptId TEXT NOT NULL,
        facetType TEXT NOT NULL,
        variantKey TEXT NOT NULL DEFAULT '',
        ef REAL NOT NULL DEFAULT 2.5,
        repetitions INTEGER NOT NULL,
        intervalDays INTEGER NOT NULL,
        lapses INTEGER NOT NULL DEFAULT 0,
        successes INTEGER NOT NULL DEFAULT 0,
        failures INTEGER NOT NULL DEFAULT 0,
        difficulty REAL NOT NULL DEFAULT 1.3,
        stabilityDays REAL NOT NULL DEFAULT 0,
        nextReviewAt TEXT NOT NULL,
        lastReviewedAt TEXT
      )
    ''');
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_spaced_repetition_facet '
      'ON $_tableNameSpacedRepetition(conceptId, facetType, variantKey)',
    );
  }

  Future<void> markLessonCompleted(String lessonId) async {
    final db = await database;
    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.insert(
          _tableNameCompletedLessons,
          <String, Object>{
            'id': lessonId,
            'completedAt': DateTime.now().toUtc().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> updateStreak(String date, int count) async {
    final db = await database;
    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.insert(
          _tableNameStreaks,
          <String, Object>{
            'date': date,
            'count': count,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> updateReviewScore(String lessonId, double score) async {
    final db = await database;
    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.insert(
          _tableNameReviewScores,
          <String, Object>{
            'lessonId': lessonId,
            'score': score,
            'reviewedAt': DateTime.now().toUtc().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<ReviewCard?> getFacetReviewCard({
    required String conceptId,
    ReviewFacetType facetType = ReviewFacetType.meaningRecall,
    String? variantKey,
  }) async {
    final key = ReviewFacetKey(
      conceptId: conceptId,
      facetType: facetType,
      variantKey: variantKey,
    );
    if (!key.isValid) return null;
    final db = await database;
    final rows = await db.query(
      _tableNameSpacedRepetition,
      where: 'conceptId = ? AND facetType = ? AND variantKey = ?',
      whereArgs: <Object?>[
        key.conceptId.trim(),
        key.facetType.wireName,
        key.normalizedVariantKey ?? '',
      ],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _reviewCardFromRow(rows.first);
  }

  Future<SpacedRepetitionItem?> getSpacedRepetitionItem(String id) async {
    final key = ReviewFacetKey(conceptId: id);
    if (!key.isValid) return null;
    final db = await database;
    final rows = await db.query(
      _tableNameSpacedRepetition,
      where: 'conceptId = ? AND facetType = ? AND variantKey = ?',
      whereArgs: <Object?>[
        key.conceptId.trim(),
        ReviewFacetType.meaningRecall.wireName,
        '',
      ],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return SpacedRepetitionItem(
      id: key.conceptId.trim(),
      ef: (row['ef'] as num?)?.toDouble() ?? 2.5,
      repetitions: (row['repetitions'] as num?)?.toInt() ?? 0,
      intervalDays: (row['intervalDays'] as num?)?.toInt() ?? 0,
      nextReviewAt:
          DateTime.tryParse(row['nextReviewAt']?.toString() ?? '')?.toUtc() ??
              DateTime.now().toUtc(),
    );
  }

  Future<void> processFacetReview({
    required String conceptId,
    required ReviewFacetType facetType,
    String? variantKey,
    required bool correct,
    required bool hinted,
    DateTime? at,
  }) async {
    final key = ReviewFacetKey(
      conceptId: conceptId,
      facetType: facetType,
      variantKey: variantKey,
    );
    if (!key.isValid) {
      throw ArgumentError('Invalid facet review key.');
    }
    throw StateError(
      'legacy_srs_store_retired_use_pair_progress',
    );
  }

  Future<void> processSpacedRepetitionReview({
    required String itemId,
    required int quality,
  }) async {
    if (quality < 0 || quality > 5) {
      throw ArgumentError('Quality must be between 0 and 5.');
    }
    throw StateError(
      'legacy_srs_store_retired_use_pair_progress',
    );
  }

  Future<String> exportProgressState() async {
    final db = await database;
    final state = <String, Object?>{
      'completed_lessons': await db.query(_tableNameCompletedLessons),
      'daily_streaks': await db.query(_tableNameStreaks),
      'review_scores': await db.query(_tableNameReviewScores),
      'spaced_repetition': await db.query(_tableNameSpacedRepetition),
    };
    return jsonEncode(state);
  }

  Future<void> importProgressState(String jsonState) async {
    final decoded = jsonDecode(jsonState);
    if (decoded is! Map) {
      throw const FormatException('progress_state_invalid');
    }
    final state = Map<String, dynamic>.from(decoded);
    final db = await database;

    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.delete(_tableNameCompletedLessons);
      await txn.delete(_tableNameStreaks);
      await txn.delete(_tableNameReviewScores);
      await txn.delete(_tableNameSpacedRepetition);

      await _restoreRows(
        txn,
        _tableNameCompletedLessons,
        state['completed_lessons'],
      );
      await _restoreRows(txn, _tableNameStreaks, state['daily_streaks']);
      await _restoreRows(txn, _tableNameReviewScores, state['review_scores']);

      final spaced = state['spaced_repetition'];
      if (spaced is List) {
        for (final raw in spaced.take(20000)) {
          if (raw is! Map) continue;
          final normalized = _normalizeImportedSrsRow(
            Map<String, dynamic>.from(raw),
          );
          if (normalized == null) continue;
          await txn.insert(
            _tableNameSpacedRepetition,
            normalized,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  Future<void> _restoreRows(
    Transaction txn,
    String table,
    Object? rawRows,
  ) async {
    if (rawRows is! List) return;
    for (final raw in rawRows.take(20000)) {
      if (raw is! Map) continue;
      await txn.insert(table, Map<String, dynamic>.from(raw));
    }
  }

  Map<String, Object?>? _normalizeImportedSrsRow(Map<String, dynamic> row) {
    final conceptId = (row['conceptId'] ?? row['id'])?.toString().trim() ?? '';
    final facetType = ReviewFacetType.fromWire(row['facetType']?.toString());
    final variantKey = ReviewFacetKey.normalizeVariant(
      row['variantKey']?.toString(),
    );
    final key = ReviewFacetKey(
      conceptId: conceptId,
      facetType: facetType,
      variantKey: variantKey,
    );
    if (!key.isValid) return null;

    final card = ReviewCard.fromJson(<String, dynamic>{
      'itemId': conceptId,
      'facetType': facetType.wireName,
      if (variantKey != null) 'variantKey': variantKey,
      'repetitions': row['repetitions'],
      'intervalDays': row['intervalDays'],
      'lapses': row['lapses'],
      'successes': row['successes'] ?? row['repetitions'],
      'failures': row['failures'],
      'difficulty': row['difficulty'],
      'stabilityDays': row['stabilityDays'] ?? row['intervalDays'],
      'dueAt': row['nextReviewAt'],
      'lastReviewedAt': row['lastReviewedAt'],
    });
    return _rowForCard(
      card,
      legacyEase: (row['ef'] as num?)?.toDouble() ?? 2.5,
    );
  }

  Map<String, Object?> _rowForCard(
    ReviewCard card, {
    double legacyEase = 2.5,
  }) =>
      <String, Object?>{
        'id': card.storageKey,
        'conceptId': card.itemId,
        'facetType': card.facetType.wireName,
        'variantKey': card.facetKey.normalizedVariantKey ?? '',
        'ef': legacyEase.clamp(1.3, 5.0),
        'repetitions': card.repetitions,
        'intervalDays': card.intervalDays,
        'lapses': card.lapses,
        'successes': card.successes,
        'failures': card.failures,
        'difficulty': card.difficulty,
        'stabilityDays': card.stabilityDays,
        'nextReviewAt': card.dueAt.toUtc().toIso8601String(),
        'lastReviewedAt': card.lastReviewedAt?.toUtc().toIso8601String(),
      };

  ReviewCard _reviewCardFromRow(Map<String, Object?> row) =>
      ReviewCard.fromJson(<String, dynamic>{
        'itemId': row['conceptId'] ?? row['id'],
        'facetType': row['facetType'],
        'variantKey': row['variantKey'],
        'repetitions': row['repetitions'],
        'intervalDays': row['intervalDays'],
        'lapses': row['lapses'],
        'successes': row['successes'],
        'failures': row['failures'],
        'difficulty': row['difficulty'],
        'stabilityDays': row['stabilityDays'],
        'dueAt': row['nextReviewAt'],
        'lastReviewedAt': row['lastReviewedAt'],
      });

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
