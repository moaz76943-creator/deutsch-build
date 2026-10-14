import 'dart:math' as math;

import 'package:sqflite/sqflite.dart';

/// The existing user_progress_v2.db ledger uses next_due_at (epoch seconds).
/// No content pack is ever modified by this service.
class SrsReviewState {
  final int repetitionCount;
  final int intervalDays;
  final double easeFactor;

  const SrsReviewState({
    this.repetitionCount = 0,
    this.intervalDays = 0,
    this.easeFactor = 2.5,
  });
}

class SrsReviewSchedule {
  final int repetitionCount;
  final int intervalDays;
  final double easeFactor;
  final int nextReviewEpoch;

  const SrsReviewSchedule({
    required this.repetitionCount,
    required this.intervalDays,
    required this.easeFactor,
    required this.nextReviewEpoch,
  });

  SrsReviewState asState() => SrsReviewState(
        repetitionCount: repetitionCount,
        intervalDays: intervalDays,
        easeFactor: easeFactor,
      );
}

/// A deterministic SM-2 scheduler. App grades 0..4 map to SM-2 0,2,3,4,5.
/// Grade 2 (Hard) is a successful but low-quality recall; 0/1 reset the streak.
/// This is SM-2, not FSRS (which requires trained retention parameters).
class SrsSchedulerService {
  static const double initialEaseFactor = 2.5;
  static const double minimumEaseFactor = 1.3;
  static const int secondsPerDay = 86400;

  SrsReviewSchedule calculate({
    required int grade,
    SrsReviewState previous = const SrsReviewState(),
    DateTime? reviewedAt,
  }) {
    if (grade < 0 || grade > 4) {
      throw RangeError.range(grade, 0, 4, 'grade');
    }
    if (previous.repetitionCount < 0 || previous.intervalDays < 0 ||
        !previous.easeFactor.isFinite || previous.easeFactor < minimumEaseFactor) {
      throw ArgumentError.value(previous, 'previous', 'Invalid SRS state');
    }

    const qualities = <int>[0, 2, 3, 4, 5];
    final quality = qualities[grade];
    final delta = 5 - quality;
    final ease = math.max(
      minimumEaseFactor,
      previous.easeFactor + 0.1 - delta * (0.08 + delta * 0.02),
    );

    final successful = quality >= 3;
    final repetitions = successful ? previous.repetitionCount + 1 : 0;
    final int interval;
    if (!successful || previous.repetitionCount == 0) {
      interval = 1;
    } else if (previous.repetitionCount == 1) {
      interval = 6;
    } else {
      interval = math.max(1, (previous.intervalDays * ease).round());
    }
    final reviewed = (reviewedAt ?? DateTime.now()).toUtc();
    final nextEpoch = reviewed.add(Duration(days: interval))
            .millisecondsSinceEpoch ~/
        1000;
    return SrsReviewSchedule(
      repetitionCount: repetitions,
      intervalDays: interval,
      easeFactor: ease,
      nextReviewEpoch: nextEpoch,
    );
  }

  // SQLite INTEGER affinity still allows fractional REAL values. Validate the
  // saved value before conversion so corrupt progress is never rounded and
  // overwritten by a review.
  static int _readPersistedCounter(Object? value, String column) {
    if (value is! num || !value.isFinite || value < 0) {
      throw ArgumentError.value(value, column, 'Invalid persisted SRS counter');
    }
    final counter = value.toInt();
    if (value != counter) {
      throw ArgumentError.value(value, column, 'Invalid persisted SRS counter');
    }
    return counter;
  }

  /// Atomic read-modify-write using the existing srs_progress schema.
  /// nextReviewEpoch is persisted as next_due_at, in Unix seconds.
  Future<SrsReviewSchedule> gradeAndPersist({
    required Database progressDb,
    required String lexemeId,
    required String languageCode,
    required int grade,
    DateTime? reviewedAt,
  }) async {
    if (lexemeId.trim().isEmpty || languageCode.trim().isEmpty) {
      throw ArgumentError('A lexeme ID and language code are required');
    }
    return progressDb.transaction((txn) async {
      final existing = await txn.query(
        'srs_progress',
        columns: <String>['repetition_count', 'interval_days', 'ease_factor'],
        where: 'lexeme_id = ? AND target_language_code = ?',
        whereArgs: <Object>[lexemeId, languageCode],
        limit: 1,
      );
      final state = existing.isEmpty
          ? const SrsReviewState()
          : SrsReviewState(
              repetitionCount: _readPersistedCounter(
                existing.first['repetition_count'], 'repetition_count',
              ),
              intervalDays: _readPersistedCounter(
                existing.first['interval_days'], 'interval_days',
              ),
              easeFactor: (existing.first['ease_factor'] as num).toDouble(),
            );
      final result = calculate(
        grade: grade,
        previous: state,
        reviewedAt: reviewedAt,
      );
      final values = <String, Object?>{
        'target_language_code': languageCode,
        'repetition_count': result.repetitionCount,
        'interval_days': result.intervalDays,
        'ease_factor': result.easeFactor,
        'next_due_at': result.nextReviewEpoch,
        'status': result.repetitionCount > 1 ? 'review' : 'learning',
      };
      if (existing.isEmpty) {
        await txn.insert('srs_progress', <String, Object?>{
          'lexeme_id': lexemeId,
          ...values,
        });
      } else {
        await txn.update(
          'srs_progress',
          values,
          where: 'lexeme_id = ? AND target_language_code = ?',
          whereArgs: <Object>[lexemeId, languageCode],
        );
      }
      return result;
    });
  }
}
