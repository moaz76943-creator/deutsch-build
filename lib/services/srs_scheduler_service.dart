import 'package:sqflite/sqflite.dart';
import '../core/srs/production_srs_engine.dart';
import 'dart:math' as math;

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
    this.repetitionCount = 0,
    this.intervalDays = 1,
    this.easeFactor = 2.5,
    this.nextDueAt,
    this.status = 'learning',
  });

  factory SrsReviewState.fromMap(Map<String, dynamic> map) {
    return SrsReviewState(
      lexemeId: map['lexeme_id'] as String,
      targetLanguageCode: map['target_language_code'] as String,
      repetitionCount: (map['repetition_count'] as num?)?.toInt() ?? 0,
      intervalDays: (map['interval_days'] as num?)?.toInt() ?? 1,
      easeFactor: (map['ease_factor'] as num?)?.toDouble() ?? 2.5,
      nextDueAt: (map['next_due_at'] as num?)?.toInt(),
      status: map['status'] as String? ?? 'learning',
    );
  }
}

class SrsReviewSchedule {
  final String lexemeId;
  final DateTime nextReviewDate;

  const SrsReviewSchedule({
    required this.lexemeId,
    required this.nextReviewDate,
  });
}

class SrsSchedulerService {
  final Database db;

  SrsSchedulerService({required this.db});

  static const int _debounceSeconds = 60; // 60 seconds debounce

  Future<SrsReviewSchedule?> processReview({
    required String lexemeId,
    required String targetLanguageCode,
    required SrsRating rating,
    int? currentTimeSeconds,
  }) async {
    final int nowSeconds = currentTimeSeconds ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

    return await db.transaction((txn) async {
      final List<Map<String, Object?>> results = await txn.query(
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
        );
      }

      int? inferredLastReviewedAt;
      if (currentState.nextDueAt != null) {
        inferredLastReviewedAt = currentState.nextDueAt! - (currentState.intervalDays * 86400);
      }

      if (inferredLastReviewedAt != null) {
        final diff = nowSeconds - inferredLastReviewedAt;
        if (diff >= 0 && diff < _debounceSeconds) {
          return SrsReviewSchedule(
            lexemeId: lexemeId,
            nextReviewDate: DateTime.fromMillisecondsSinceEpoch(currentState.nextDueAt! * 1000, isUtc: true),
          );
        }
      }

      final reviewResult = ProductionSrsEngine.processReview(
        currentIntervalDays: currentState.intervalDays,
        currentEaseFactor: currentState.easeFactor,
        currentRepetitions: currentState.repetitionCount,
        rating: rating,
      );

      final int nextIntervalDays = math.max(0, reviewResult.nextIntervalDays);
      final double easeFactor = math.max(1.3, reviewResult.easeFactor);

      final baseTime = DateTime.fromMillisecondsSinceEpoch(nowSeconds * 1000, isUtc: true);
      final DateTime nextDueUtc = baseTime.add(Duration(days: nextIntervalDays));
      final int nextDueEpochSeconds = nextDueUtc.millisecondsSinceEpoch ~/ 1000;

      await txn.insert(
        'srs_progress',
        {
          'lexeme_id': lexemeId,
          'target_language_code': targetLanguageCode,
          'repetition_count': reviewResult.repetitionCount,
          'interval_days': nextIntervalDays,
          'ease_factor': easeFactor,
          'next_due_at': nextDueEpochSeconds,
          'status': reviewResult.repetitionCount > 0 ? 'reviewing' : 'learning',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return SrsReviewSchedule(
        lexemeId: lexemeId,
        nextReviewDate: nextDueUtc,
      );
    });
  }
}
