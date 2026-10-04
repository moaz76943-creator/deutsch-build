import 'package:sqflite_common/sqlite_api.dart';

import '../../progress/pair_progress_models.dart';

final class PairProgressDatabase {
  PairProgressDatabase._(this._database);

  static const int schemaVersion = 1;
  static const String pairTable = 'pair_progress';
  static const String cardTable = 'pair_card_progress';

  final Database _database;

  static Future<PairProgressDatabase> attach(
    Database database,
  ) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $pairTable (
              source_language_id TEXT NOT NULL,
              target_language_id TEXT NOT NULL,
              level INTEGER NOT NULL DEFAULT 0,
              achievement_points INTEGER NOT NULL DEFAULT 0,
              updated_at_utc TEXT NOT NULL,
              PRIMARY KEY (source_language_id, target_language_id)
            )
          ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $cardTable (
              source_language_id TEXT NOT NULL,
              target_language_id TEXT NOT NULL,
              card_id TEXT NOT NULL,
              learned INTEGER NOT NULL DEFAULT 0,
              correct_count INTEGER NOT NULL DEFAULT 0,
              incorrect_count INTEGER NOT NULL DEFAULT 0,
              last_reviewed_at_utc TEXT NOT NULL,
              PRIMARY KEY (
                source_language_id,
                target_language_id,
                card_id
              )
            )
          ''');
    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_pair_card_progress_context '
      'ON $cardTable(source_language_id, target_language_id)',
    );
    return PairProgressDatabase._(database);
  }

  Future<void> recordCard({
    required String sourceLanguageId,
    required String targetLanguageId,
    required String cardId,
    required bool learned,
    required int level,
    required int achievementDelta,
    required bool correct,
    required DateTime reviewedAt,
  }) async {
    final reviewedAtUtc = reviewedAt.toUtc().toIso8601String();
    await _database.transaction((txn) async {
      final pairRows = await txn.query(
        pairTable,
        columns: const <String>['achievement_points'],
        where: 'source_language_id = ? AND target_language_id = ?',
        whereArgs: <Object?>[sourceLanguageId, targetLanguageId],
        limit: 1,
      );
      final currentPoints = pairRows.isEmpty
          ? 0
          : (pairRows.first['achievement_points'] as num?)?.toInt() ?? 0;
      final nextPoints = currentPoints + achievementDelta;

      await txn.insert(
        pairTable,
        <String, Object?>{
          'source_language_id': sourceLanguageId,
          'target_language_id': targetLanguageId,
          'level': level,
          'achievement_points': nextPoints,
          'updated_at_utc': reviewedAtUtc,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final cardRows = await txn.query(
        cardTable,
        columns: const <String>[
          'correct_count',
          'incorrect_count',
          'learned',
        ],
        where:
            'source_language_id = ? AND target_language_id = ? AND card_id = ?',
        whereArgs: <Object?>[
          sourceLanguageId,
          targetLanguageId,
          cardId,
        ],
        limit: 1,
      );

      var correctCount = 0;
      var incorrectCount = 0;
      var learnedFlag = learned;
      if (cardRows.isNotEmpty) {
        final row = cardRows.first;
        correctCount = (row['correct_count'] as num?)?.toInt() ?? 0;
        incorrectCount = (row['incorrect_count'] as num?)?.toInt() ?? 0;
        learnedFlag =
            learned || ((row['learned'] as num?)?.toInt() ?? 0) == 1;
      }
      if (correct) {
        correctCount += 1;
      } else {
        incorrectCount += 1;
      }

      await txn.insert(
        cardTable,
        <String, Object?>{
          'source_language_id': sourceLanguageId,
          'target_language_id': targetLanguageId,
          'card_id': cardId,
          'learned': learnedFlag ? 1 : 0,
          'correct_count': correctCount,
          'incorrect_count': incorrectCount,
          'last_reviewed_at_utc': reviewedAtUtc,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<PairProgressCard?> loadCard({
    required String sourceLanguageId,
    required String targetLanguageId,
    required String cardId,
  }) async {
    final rows = await _database.query(
      cardTable,
      where:
          'source_language_id = ? AND target_language_id = ? AND card_id = ?',
      whereArgs: <Object?>[
        sourceLanguageId,
        targetLanguageId,
        cardId,
      ],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _cardFromRow(rows.first);
  }

  Future<PairProgressSnapshot> loadPair({
    required String sourceLanguageId,
    required String targetLanguageId,
  }) async {
    final pairRows = await _database.query(
      pairTable,
      where: 'source_language_id = ? AND target_language_id = ?',
      whereArgs: <Object?>[sourceLanguageId, targetLanguageId],
      limit: 1,
    );
    final cardRows = await _database.query(
      cardTable,
      where: 'source_language_id = ? AND target_language_id = ?',
      whereArgs: <Object?>[sourceLanguageId, targetLanguageId],
      orderBy: 'card_id ASC',
    );

    final pair = pairRows.isEmpty ? null : pairRows.first;
    return PairProgressSnapshot(
      pairKey: '$sourceLanguageId->$targetLanguageId',
      sourceLanguageId: sourceLanguageId,
      targetLanguageId: targetLanguageId,
      level: (pair?['level'] as num?)?.toInt() ?? 0,
      achievementPoints:
          (pair?['achievement_points'] as num?)?.toInt() ?? 0,
      cards: List<PairProgressCard>.unmodifiable(
        cardRows.map(_cardFromRow),
      ),
    );
  }

  PairProgressCard _cardFromRow(Map<String, Object?> row) {
    final source = row['source_language_id']?.toString() ?? '';
    final target = row['target_language_id']?.toString() ?? '';
    final reviewedAt = DateTime.tryParse(
          row['last_reviewed_at_utc']?.toString() ?? '',
        )?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    return PairProgressCard(
      pairKey: '$source->$target',
      cardId: row['card_id']?.toString() ?? '',
      learned: ((row['learned'] as num?)?.toInt() ?? 0) == 1,
      correctCount: (row['correct_count'] as num?)?.toInt() ?? 0,
      incorrectCount:
          (row['incorrect_count'] as num?)?.toInt() ?? 0,
      lastReviewedAt: reviewedAt,
    );
  }

  Future<void> close() => _database.close();
}
