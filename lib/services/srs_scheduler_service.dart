import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'srs_sm2_engine.dart';

class SrsReviewState {
  final String lexemeId;
  final String targetLanguageCode;
  final int repetitionCount;
  final int intervalDays;
  final double easeFactor;
  final int? nextDueAtEpoch;
  final String status;

  const SrsReviewState({
    required this.lexemeId,
    required this.targetLanguageCode,
    required this.repetitionCount,
    required this.intervalDays,
    required this.easeFactor,
    this.nextDueAtEpoch,
    required this.status,
  });

  factory SrsReviewState.fromMap(Map<String, dynamic> map) {
    return SrsReviewState(
      lexemeId: map['lexeme_id'] as String,
      targetLanguageCode: map['target_language_code'] as String,
      repetitionCount: map['repetition_count'] as int,
      intervalDays: map['interval_days'] as int,
      easeFactor: (map['ease_factor'] as num).toDouble(),
      nextDueAtEpoch: map['next_due_at'] as int?,
      status: map['status'] as String,
    );
  }
}

class SrsReviewSchedule {
  final String lexemeId;
  final DateTime nextDueAt;

  const SrsReviewSchedule({
    required this.lexemeId,
    required this.nextDueAt,
  });
}

class SrsSchedulerService {
  final Future<Database> Function() _getDb;

  SrsSchedulerService({Future<Database> Function()? getDb})
      : _getDb = getDb ?? (() => DatabaseService.instance.progressDb);

  Future<void> submitReview({
    required String lexemeId,
    required String languageCode,
    required int quality,
    required DateTime now,
  }) async {
    // 1. Validate constraints
    if (quality < 1 || quality > 5) {
      throw ArgumentError('Quality must be between 1 and 5');
    }

    final db = await _getDb();

    await db.transaction((txn) async {
      // 2. Fetch current state
      final List<Map<String, Object?>> results = await txn.query(
        'srs_progress',
        where: 'lexeme_id = ? AND target_language_code = ?',
        whereArgs: [lexemeId, languageCode],
      );

      double currentEaseFactor = 2.5;
      int repetitions = 0;
      int intervalDays = 1;

      if (results.isNotEmpty) {
        final state = SrsReviewState.fromMap(results.first);

        // Idempotency check: if nextDueAtEpoch is > now, and we just reviewed it,
        // this might be a duplicate submission for the same day.
        // SM-2 normally shouldn't be updated multiple times a day unless it's a new review.
        // For J035, duplicate review submissions should be safely handled.
        // If the review is already scheduled for the future, we can ignore the duplicate submission.
        final nowEpoch = now.millisecondsSinceEpoch ~/ 1000;
        if (state.nextDueAtEpoch != null && state.nextDueAtEpoch! > nowEpoch) {
          // Already scheduled for the future, skip updating to prevent duplication.
          return;
        }

        currentEaseFactor = state.easeFactor;
        repetitions = state.repetitionCount;
        intervalDays = state.intervalDays;
      }

      // 3. Calculate next schedule
      final result = SrsSm2Engine.calculateNextReview(
        quality: quality,
        currentEaseFactor: currentEaseFactor,
        repetitions: repetitions,
        intervalDays: intervalDays,
      );

      // Calculate next due date strictly from 'now'
      final nextDueAtEpoch = now.add(Duration(days: result.intervalDays)).millisecondsSinceEpoch ~/ 1000;

      // Enforce bounds
      final easeFactor = result.easeFactor.clamp(SrsSm2Engine.minEaseFactor, 5.0);
      final safeIntervalDays = result.intervalDays < 0 ? 0 : result.intervalDays;

      // 4. Update the state transactionally without destroying existing row schema fields
      await txn.rawInsert('''
        INSERT INTO srs_progress (
          lexeme_id,
          target_language_code,
          repetition_count,
          interval_days,
          ease_factor,
          next_due_at,
          status
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(lexeme_id) DO UPDATE SET
          target_language_code = excluded.target_language_code,
          repetition_count = excluded.repetition_count,
          interval_days = excluded.interval_days,
          ease_factor = excluded.ease_factor,
          next_due_at = excluded.next_due_at,
          status = excluded.status
      ''', [
        lexemeId,
        languageCode,
        result.repetitions,
        safeIntervalDays,
        easeFactor,
        nextDueAtEpoch,
        result.repetitions > 0 ? 'reviewing' : 'learning',
      ]);
    });
  }

  Future<List<SrsReviewSchedule>> getDueReviews(String languageCode, DateTime now) async {
    final db = await _getDb();
    final nowEpoch = now.millisecondsSinceEpoch ~/ 1000;

    final results = await db.query(
      'srs_progress',
      columns: ['lexeme_id', 'next_due_at'],
      where: 'target_language_code = ? AND (next_due_at IS NULL OR next_due_at <= ?)',
      whereArgs: [languageCode, nowEpoch],
    );

    return results.map((row) {
      final nextDueAtEpoch = row['next_due_at'] as int?;
      return SrsReviewSchedule(
        lexemeId: row['lexeme_id'] as String,
        nextDueAt: nextDueAtEpoch != null
            ? DateTime.fromMillisecondsSinceEpoch(nextDueAtEpoch * 1000, isUtc: true)
            : now,
      );
    }).toList();
  }
}
