import 'package:sqflite/sqflite.dart';
import 'package:deutsch_bilarabi/services/srs_sm2_engine.dart';

class SrsReviewState {
  final String lexemeId;
  final String targetLanguageCode;
  final int repetitionCount;
  final int intervalDays;
  final double easeFactor;
  final int? nextDueAt;
  final String status;

  const SrsReviewState({
    required this.lexemeId,
    required this.targetLanguageCode,
    required this.repetitionCount,
    required this.intervalDays,
    required this.easeFactor,
    this.nextDueAt,
    required this.status,
  });

  factory SrsReviewState.fromMap(Map<String, dynamic> map) {
    return SrsReviewState(
      lexemeId: map['lexeme_id'] as String,
      targetLanguageCode: map['target_language_code'] as String,
      repetitionCount: map['repetition_count'] as int? ?? 0,
      intervalDays: map['interval_days'] as int? ?? 1,
      easeFactor: (map['ease_factor'] as num?)?.toDouble() ?? 2.5,
      nextDueAt: map['next_due_at'] as int?,
      status: map['status'] as String? ?? 'learning',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lexeme_id': lexemeId,
      'target_language_code': targetLanguageCode,
      'repetition_count': repetitionCount,
      'interval_days': intervalDays,
      'ease_factor': easeFactor,
      'next_due_at': nextDueAt,
      'status': status,
    };
  }
}

class SrsReviewSchedule {
  final SrsReviewState state;
  final Sm2ReviewResult sm2Result;

  const SrsReviewSchedule({
    required this.state,
    required this.sm2Result,
  });
}

class SrsSchedulerService {
  final Database _db;

  SrsSchedulerService(this._db);

  Future<void> submitReview(
    String lexemeId,
    String targetLanguageCode,
    int quality, {
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now().toUtc();
    final currentEpochSeconds = currentTime.millisecondsSinceEpoch ~/ 1000;

    await _db.transaction((txn) async {
      final results = await txn.query(
        'srs_progress',
        where: 'lexeme_id = ? AND target_language_code = ?',
        whereArgs: [lexemeId, targetLanguageCode],
      );

      SrsReviewState currentState;
      if (results.isNotEmpty) {
        currentState = SrsReviewState.fromMap(results.first);
      } else {
        currentState = SrsReviewState(
          lexemeId: lexemeId,
          targetLanguageCode: targetLanguageCode,
          repetitionCount: 0,
          intervalDays: 1,
          easeFactor: 2.5,
          nextDueAt: null,
          status: 'learning',
        );
      }

      // Idempotency: Ignore rapid duplicate reviews to prevent duplicating one review.
      if (currentState.nextDueAt != null) {
        final lastReviewedAt = currentState.nextDueAt! - (currentState.intervalDays * 86400);
        // We calculate absolute diff. This prevents wall-clock backward changes from breaking progress.
        final timeDiff = (currentEpochSeconds - lastReviewedAt).abs();
        if (timeDiff < 300) {
          return;
        }
      }

      final reviewResult = SrsSm2Engine.calculateNextReview(
        quality: quality,
        currentEaseFactor: currentState.easeFactor,
        repetitions: currentState.repetitionCount,
        intervalDays: currentState.intervalDays,
      );

      // Enforce nonnegative intervals and valid ease-factor bounds
      final newEaseFactor = reviewResult.easeFactor < 1.3 ? 1.3 : reviewResult.easeFactor;
      final newIntervalDays = reviewResult.intervalDays < 0 ? 0 : reviewResult.intervalDays;

      final nextDate = currentTime.add(Duration(days: newIntervalDays));
      final nextDueAtSeconds = nextDate.millisecondsSinceEpoch ~/ 1000;

      final newState = SrsReviewState(
        lexemeId: lexemeId,
        targetLanguageCode: targetLanguageCode,
        repetitionCount: reviewResult.repetitions,
        intervalDays: newIntervalDays,
        easeFactor: newEaseFactor,
        nextDueAt: nextDueAtSeconds,
        status: currentState.status,
      );

      if (results.isEmpty) {
        // Safe Insert for new entry without relying on ConflictAlgorithm.replace which deletes conflicting PKs.
        await txn.insert('srs_progress', newState.toMap());
      } else {
        // Safe Update without mutating different target languages that might share lexeme_id
        await txn.update(
          'srs_progress',
          newState.toMap(),
          where: 'lexeme_id = ? AND target_language_code = ?',
          whereArgs: [lexemeId, targetLanguageCode],
        );
      }
    });
  }

  Future<List<SrsReviewState>> getDueReviews(
    String targetLanguageCode, {
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now().toUtc();
    final currentEpochSeconds = currentTime.millisecondsSinceEpoch ~/ 1000;

    final results = await _db.query(
      'srs_progress',
      where: 'target_language_code = ? AND (next_due_at IS NULL OR next_due_at <= ?)',
      whereArgs: [targetLanguageCode, currentEpochSeconds],
    );

    return results.map((m) => SrsReviewState.fromMap(m)).toList();
  }
}
