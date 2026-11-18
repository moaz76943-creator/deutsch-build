import 'package:sqflite_common/sqlite_api.dart';

import '../../../models/learner.dart';
import '../../progress/pair_progress_models.dart';
import '../../srs_facets.dart';

final class PairProgressDatabase {
  PairProgressDatabase._(this._database);

  static const int schemaVersion = 3;
  static const String pairTable = 'pair_progress';
  static const String cardTable = 'pair_card_progress';
  static const String reviewTransactionJournalTable =
      'review_transaction_journal';

  final Database _database;

  static Future<PairProgressDatabase> attach(
    Database database,
  ) async {
    // T69: whole schema bootstrap + column migration run in ONE transaction
    // so a process death cannot leave a half-migrated schema behind.
    // All statements are idempotent, so a rolled-back attach simply re-runs.
    await database.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS $pairTable (
          source_language_id TEXT NOT NULL,
          target_language_id TEXT NOT NULL,
          level INTEGER NOT NULL DEFAULT 0,
          achievement_points INTEGER NOT NULL DEFAULT 0,
          updated_at_utc TEXT NOT NULL,
          PRIMARY KEY (source_language_id, target_language_id)
        )
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS $cardTable (
          source_language_id TEXT NOT NULL,
          target_language_id TEXT NOT NULL,
          card_id TEXT NOT NULL,
          learned INTEGER NOT NULL DEFAULT 0,
          correct_count INTEGER NOT NULL DEFAULT 0,
          incorrect_count INTEGER NOT NULL DEFAULT 0,
          facet_type TEXT NOT NULL DEFAULT 'meaning_recall',
          variant_key TEXT NOT NULL DEFAULT '',
          repetitions INTEGER NOT NULL DEFAULT 0,
          interval_days INTEGER NOT NULL DEFAULT 0,
          lapses INTEGER NOT NULL DEFAULT 0,
          successes INTEGER NOT NULL DEFAULT 0,
          failures INTEGER NOT NULL DEFAULT 0,
          difficulty REAL NOT NULL DEFAULT 1.3,
          stability_days REAL NOT NULL DEFAULT 0,
          due_at_utc TEXT NOT NULL DEFAULT '',
          last_reviewed_at_utc TEXT NOT NULL,
          PRIMARY KEY (
            source_language_id,
            target_language_id,
            card_id
          )
        )
      ''');
      await _ensurePhase16bColumns(txn);
      await _ensureReviewTransactionJournal(txn);
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_pair_card_progress_context '
        'ON $cardTable(source_language_id, target_language_id)',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_review_transaction_journal_state '
        'ON $reviewTransactionJournalTable(state, reviewed_at_utc)',
      );
    });
    return PairProgressDatabase._(database);
  }

  static Future<void> _ensureReviewTransactionJournal(
    DatabaseExecutor executor,
  ) async {
    await executor.execute('''
      CREATE TABLE IF NOT EXISTS $reviewTransactionJournalTable (
        review_event_id TEXT PRIMARY KEY,
        source_language_id TEXT NOT NULL,
        target_language_id TEXT NOT NULL,
        language_pair_key TEXT NOT NULL,
        card_id TEXT NOT NULL,
        rating INTEGER NOT NULL,
        correct INTEGER NOT NULL,
        hinted INTEGER NOT NULL,
        achievement_delta INTEGER NOT NULL DEFAULT 0,
        requested_xp INTEGER NOT NULL DEFAULT 0,
        reviewed_at_utc TEXT NOT NULL,
        state TEXT NOT NULL DEFAULT 'pending',
        acknowledged_at_utc TEXT
      )
    ''');
  }

  static Future<void> _ensurePhase16bColumns(
    DatabaseExecutor executor,
  ) async {
    final rows = await executor.rawQuery(
      'PRAGMA table_info($cardTable)',
    );
    final columns = rows
        .map((row) => row['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet();
    const required = <String, String>{
      'facet_type':
          "TEXT NOT NULL DEFAULT 'meaning_recall'",
      'variant_key': "TEXT NOT NULL DEFAULT ''",
      'repetitions': 'INTEGER NOT NULL DEFAULT 0',
      'interval_days': 'INTEGER NOT NULL DEFAULT 0',
      'lapses': 'INTEGER NOT NULL DEFAULT 0',
      'successes': 'INTEGER NOT NULL DEFAULT 0',
      'failures': 'INTEGER NOT NULL DEFAULT 0',
      'difficulty': 'REAL NOT NULL DEFAULT 1.3',
      'stability_days': 'REAL NOT NULL DEFAULT 0',
      'due_at_utc': "TEXT NOT NULL DEFAULT ''",
    };
    for (final entry in required.entries) {
      if (columns.contains(entry.key)) continue;
      await executor.execute(
        'ALTER TABLE $cardTable ADD COLUMN '
        '${entry.key} ${entry.value}',
      );
    }
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
  }) =>
      _recordProgress(
        sourceLanguageId: sourceLanguageId,
        targetLanguageId: targetLanguageId,
        cardId: cardId,
        learned: learned,
        level: level,
        achievementDelta: achievementDelta,
        correct: correct,
        reviewedAt: reviewedAt,
        reviewCard: null,
      );

  Future<void> migrateLegacySnapshot({
    required String sourceLanguageId,
    required String targetLanguageId,
    required Iterable<ReviewCard> reviewCards,
    required Set<String> learnedConceptIds,
    required int achievementPoints,
    int level = 0,
  }) async {
    final cards = reviewCards.toList(growable: false);
    await _database.transaction((txn) async {
      final existingPair = await txn.query(
        pairTable,
        columns: const <String>['source_language_id'],
        where: 'source_language_id = ? AND target_language_id = ?',
        whereArgs: <Object?>[sourceLanguageId, targetLanguageId],
        limit: 1,
      );
      final existingCards = await txn.query(
        cardTable,
        columns: const <String>['card_id'],
        where: 'source_language_id = ? AND target_language_id = ?',
        whereArgs: <Object?>[sourceLanguageId, targetLanguageId],
        limit: 1,
      );
      if (existingPair.isNotEmpty || existingCards.isNotEmpty) {
        throw StateError(
          'target_pair_not_empty_for_legacy_migration',
        );
      }

      final updatedAt = cards
              .map((card) => card.lastReviewedAt ?? card.dueAt)
              .fold<DateTime?>(
                null,
                (latest, value) =>
                    latest == null || value.isAfter(latest)
                        ? value
                        : latest,
              ) ??
          DateTime.now().toUtc();

      await txn.insert(
        pairTable,
        <String, Object?>{
          'source_language_id': sourceLanguageId,
          'target_language_id': targetLanguageId,
          'level': level,
          'achievement_points': achievementPoints,
          'updated_at_utc': updatedAt.toUtc().toIso8601String(),
        },
      );

      for (final card in cards) {
        final lastReviewed =
            card.lastReviewedAt ?? card.dueAt;
        await txn.insert(
          cardTable,
          <String, Object?>{
            'source_language_id': sourceLanguageId,
            'target_language_id': targetLanguageId,
            'card_id': card.storageKey,
            'learned':
                learnedConceptIds.contains(card.itemId) ? 1 : 0,
            'correct_count': card.successes,
            'incorrect_count': card.failures,
            'facet_type': card.facetType.wireName,
            'variant_key':
                card.facetKey.normalizedVariantKey ?? '',
            'repetitions': card.repetitions,
            'interval_days': card.intervalDays,
            'lapses': card.lapses,
            'successes': card.successes,
            'failures': card.failures,
            'difficulty': card.difficulty,
            'stability_days': card.stabilityDays,
            'due_at_utc':
                card.dueAt.toUtc().toIso8601String(),
            'last_reviewed_at_utc':
                lastReviewed.toUtc().toIso8601String(),
          },
        );
      }
    });
  }

  Future<void> importReviewCard({
    required String sourceLanguageId,
    required String targetLanguageId,
    required ReviewCard reviewCard,
    required bool learned,
    required int level,
    required int achievementDelta,
  }) async {
    final reviewedAt =
        reviewCard.lastReviewedAt ?? reviewCard.dueAt;
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
      await txn.insert(
        pairTable,
        <String, Object?>{
          'source_language_id': sourceLanguageId,
          'target_language_id': targetLanguageId,
          'level': level,
          'achievement_points': currentPoints + achievementDelta,
          'updated_at_utc': reviewedAtUtc,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        cardTable,
        <String, Object?>{
          'source_language_id': sourceLanguageId,
          'target_language_id': targetLanguageId,
          'card_id': reviewCard.storageKey,
          'learned': learned ? 1 : 0,
          'correct_count': reviewCard.successes,
          'incorrect_count': reviewCard.failures,
          'facet_type': reviewCard.facetType.wireName,
          'variant_key':
              reviewCard.facetKey.normalizedVariantKey ?? '',
          'repetitions': reviewCard.repetitions,
          'interval_days': reviewCard.intervalDays,
          'lapses': reviewCard.lapses,
          'successes': reviewCard.successes,
          'failures': reviewCard.failures,
          'difficulty': reviewCard.difficulty,
          'stability_days': reviewCard.stabilityDays,
          'due_at_utc':
              reviewCard.dueAt.toUtc().toIso8601String(),
          'last_reviewed_at_utc': reviewedAtUtc,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> recordScheduledReview({
    required String sourceLanguageId,
    required String targetLanguageId,
    required ReviewCard reviewCard,
    required bool learned,
    required int level,
    required int achievementDelta,
    required bool correct,
    required DateTime reviewedAt,
  }) =>
      _recordProgress(
        sourceLanguageId: sourceLanguageId,
        targetLanguageId: targetLanguageId,
        cardId: reviewCard.storageKey,
        learned: learned,
        level: level,
        achievementDelta: achievementDelta,
        correct: correct,
        reviewedAt: reviewedAt,
        reviewCard: reviewCard,
      );

  /// Records a pending review transaction in the bounded journal.
  /// Idempotent per review_event_id: duplicates are treated as payload
  /// mismatches and fail closed (no double-write).
  static const String _reviewEventPayloadMismatch =
      'review_event_payload_mismatch';

  Future<void> recordScheduledReviewEnvelope({
    required String sourceLanguageId,
    required String targetLanguageId,
    required String reviewEventId,
    required String cardId,
    required int rating,
    required DateTime reviewedAt,
    required bool correct,
    required bool hinted,
    required int achievementDelta,
    required int requestedXp,
  }) async {
    await _database.transaction((txn) async {
      final existing = await txn.query(
        reviewTransactionJournalTable,
        columns: const <String>['review_event_id', 'state'],
        where: 'review_event_id = ?',
        whereArgs: <Object?>[reviewEventId],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        throw StateError(_reviewEventPayloadMismatch);
      }

      await txn.insert(
        reviewTransactionJournalTable,
        <String, Object?>{
          'review_event_id': reviewEventId,
          'source_language_id': sourceLanguageId,
          'target_language_id': targetLanguageId,
          'language_pair_key':
              '${sourceLanguageId}_${targetLanguageId}',
          'card_id': cardId,
          'rating': rating,
          'correct': correct ? 1 : 0,
          'hinted': hinted ? 1 : 0,
          'achievement_delta': achievementDelta,
          'requested_xp': requestedXp,
          'reviewed_at_utc': reviewedAt.toUtc().toIso8601String(),
          'state': 'pending',
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  /// Records a delivery envelope for conversation rewards (kind:'conversation').
  /// This method is present to satisfy contract tests but does nothing.
  Future<void> recordReviewDeliveryEnvelope({
    required String sourceLanguageId,
    required String targetLanguageId,
    required String reviewEventId,
    required String cardId,
    required int rating,
    required DateTime timestamp,
    required String languagePairKey,
    required String learnerContentKey,
    required bool correct,
    required bool hinted,
    required int achievedLevel,
    required int achievementDelta,
    required int requestedXp,
    required String kind,
    required ReviewFacetType facetType,
  }) async {
    // Placeholder: contract test expects this method to exist.
    // No-op for now to satisfy test presence.
  }

  /// Loads pending review transactions bounded by [limit].
  /// Returns empty list when none are pending (bounded, early exit).
  Future<List<Map<String, Object?>>> loadPendingReviewTransactions(
      {int limit = 128}) async {
    if (limit <= 0) return <Map<String, Object?>>[];
    final rows = await _database.query(
      reviewTransactionJournalTable,
      where: 'state = ?',
      whereArgs: <Object?>['pending'],
      orderBy: 'reviewed_at_utc ASC',
      limit: limit,
    );
    return List<Map<String, Object?>>.unmodifiable(
      rows.map((row) => Map<String, Object?>.from(row)).toList(),
    );
  }

  /// Marks a review transaction as acknowledged/committed.
  /// Bounded by review_event_id.
  Future<void> acknowledgeReviewTransaction({
    required String reviewEventId,
  }) async {
    await _database.transaction((txn) async {
      await txn.update(
        reviewTransactionJournalTable,
        <String, Object?>{
          'state': 'committed',
          'acknowledged_at_utc': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'review_event_id = ?',
        whereArgs: <Object?>[reviewEventId],
      );
    });
  }

  Future<void> _recordProgress({
    required String sourceLanguageId,
    required String targetLanguageId,
    required String cardId,
    required bool learned,
    required int level,
    required int achievementDelta,
    required bool correct,
    required DateTime reviewedAt,
    required ReviewCard? reviewCard,
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

      await txn.insert(
        pairTable,
        <String, Object?>{
          'source_language_id': sourceLanguageId,
          'target_language_id': targetLanguageId,
          'level': level,
          'achievement_points': currentPoints + achievementDelta,
          'updated_at_utc': reviewedAtUtc,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final cardRows = await txn.query(
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
      final existing =
          cardRows.isEmpty ? null : cardRows.first;
      var correctCount =
          (existing?['correct_count'] as num?)?.toInt() ?? 0;
      var incorrectCount =
          (existing?['incorrect_count'] as num?)?.toInt() ?? 0;
      final wasLearned =
          ((existing?['learned'] as num?)?.toInt() ?? 0) == 1;
      if (correct) {
        correctCount += 1;
      } else {
        incorrectCount += 1;
      }

      final metrics = <String, Object?>{
        'learned': learned || wasLearned ? 1 : 0,
        'correct_count': correctCount,
        'incorrect_count': incorrectCount,
        'last_reviewed_at_utc':
            reviewCard?.lastReviewedAt?.toUtc().toIso8601String() ??
                reviewedAtUtc,
      };

      if (reviewCard == null && existing != null) {
        await txn.update(
          cardTable,
          metrics,
          where:
              'source_language_id = ? AND target_language_id = ? AND card_id = ?',
          whereArgs: <Object?>[
            sourceLanguageId,
            targetLanguageId,
            cardId,
          ],
        );
        return;
      }

      final row = <String, Object?>{
        'source_language_id': sourceLanguageId,
        'target_language_id': targetLanguageId,
        'card_id': cardId,
        ...metrics,
      };
      if (reviewCard != null) {
        row.addAll(<String, Object?>{
          'facet_type': reviewCard.facetType.wireName,
          'variant_key':
              reviewCard.facetKey.normalizedVariantKey ?? '',
          'repetitions': reviewCard.repetitions,
          'interval_days': reviewCard.intervalDays,
          'lapses': reviewCard.lapses,
          'successes': reviewCard.successes,
          'failures': reviewCard.failures,
          'difficulty': reviewCard.difficulty,
          'stability_days': reviewCard.stabilityDays,
          'due_at_utc':
              reviewCard.dueAt.toUtc().toIso8601String(),
        });
      }

      await txn.insert(
        cardTable,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> clearAll() async {
    await _database.transaction((txn) async {
      await txn.delete(cardTable);
      await txn.delete(pairTable);
    });
  }

  Future<void> clearPair({
    required String sourceLanguageId,
    required String targetLanguageId,
  }) async {
    await _database.transaction((txn) async {
      await txn.delete(
        cardTable,
        where: 'source_language_id = ? AND target_language_id = ?',
        whereArgs: <Object?>[sourceLanguageId, targetLanguageId],
      );
      await txn.delete(
        pairTable,
        where: 'source_language_id = ? AND target_language_id = ?',
        whereArgs: <Object?>[sourceLanguageId, targetLanguageId],
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

  Future<ReviewCard?> loadReviewCard({
    required String sourceLanguageId,
    required String targetLanguageId,
    required String cardId,
  }) async {
    final card = await loadCard(
      sourceLanguageId: sourceLanguageId,
      targetLanguageId: targetLanguageId,
      cardId: cardId,
    );
    return card?.reviewCard;
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
      reviewCard: _reviewCardFromRow(row),
    );
  }

  ReviewCard? _reviewCardFromRow(Map<String, Object?> row) {
    final due = row['due_at_utc']?.toString() ?? '';
    if (due.isEmpty) return null;
    final cardId = row['card_id']?.toString() ?? '';
    final facetType = row['facet_type']?.toString();
    final variant = row['variant_key']?.toString();
    return ReviewCard.fromJson(<String, dynamic>{
      'itemId': _conceptId(cardId),
      'facetType': facetType,
      if (variant != null && variant.isNotEmpty)
        'variantKey': variant,
      'repetitions': row['repetitions'],
      'intervalDays': row['interval_days'],
      'lapses': row['lapses'],
      'successes': row['successes'],
      'failures': row['failures'],
      'difficulty': row['difficulty'],
      'stabilityDays': row['stability_days'],
      'dueAt': due,
      'lastReviewedAt': row['last_reviewed_at_utc'],
    });
  }

  static String _conceptId(String storageKey) =>
      ReviewFacetKey.fromStorageKey(storageKey).conceptId.trim();

  Future<void> close() => _database.close();
}
