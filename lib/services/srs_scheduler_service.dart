import 'package:sqflite/sqflite.dart';
import '../core/srs/production_srs_engine.dart';
import 'dart:math' as math;

<<<<<<< HEAD
=======
import 'package:sqflite/sqflite.dart';
import '../core/security/monotonic_clock_guard.dart';

/// The existing user_progress_v2.db ledger uses next_due_at (epoch seconds).
/// No content pack is ever modified by this service.
>>>>>>> origin/fix/security-reconciliation-and-audit-lane01-02
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
  dynamic calculate(
          {dynamic lexemeId,
          dynamic targetLanguageCode,
          dynamic db,
          dynamic rating,
          dynamic reviewInterval}) =>
      null;
  Future<dynamic> gradeAndPersist(
          {dynamic item,
          dynamic rating,
          dynamic db,
          dynamic lexemeId,
          dynamic targetLanguageCode}) async =>
      null;

<<<<<<< HEAD
  final Future<Database> Function() _getDb;
=======
  final MonotonicClockGuard _clockGuard;

  SrsSchedulerService({MonotonicClockGuard? clockGuard})
      : _clockGuard = clockGuard ?? MonotonicClockGuard();

  SrsReviewSchedule calculate({
    required int grade,
    SrsReviewState previous = const SrsReviewState(),
    DateTime? reviewedAt,
    int? elapsedDays,
    bool alignToCircadianDay = false,
    int rolloverHour = 4,
    double facetMultiplier = 1.0,
  }) {
    if (grade < 0 || grade > 4) {
      throw RangeError.range(grade, 0, 4, 'grade');
    }
    if (previous.repetitionCount < 0 || previous.intervalDays < 0 ||
        !previous.easeFactor.isFinite || previous.easeFactor < minimumEaseFactor) {
      throw ArgumentError.value(previous, 'previous', 'Invalid SRS state');
    }
    if (facetMultiplier <= 0) {
      throw ArgumentError.value(facetMultiplier, 'facetMultiplier', 'Must be positive');
    }
>>>>>>> origin/fix/security-reconciliation-and-audit-lane01-02

  SrsSchedulerService({required this.db});

  const int debounceSeconds = 60; // 60 seconds debounce

<<<<<<< HEAD
  Future<SrsReviewSchedule?> processReview({
=======
    // Leech detection: repeated failures on previously learned items
    final bool isLeech = !successful &&
        previous.repetitionCount > 0 &&
        previous.easeFactor <= (minimumEaseFactor + 0.15);

    final reviewed = (reviewedAt != null)
        ? reviewedAt.toUtc()
        : _clockGuard.getEffectiveUtcTime();
    final DateTime targetDate;
    if (alignToCircadianDay) {
      final shifted = reviewed.add(Duration(days: interval));
      targetDate = DateTime.utc(
        shifted.year,
        shifted.month,
        shifted.day,
        rolloverHour.clamp(0, 23),
      );
    } else {
      targetDate = reviewed.add(Duration(days: interval));
    }
    final nextEpoch = targetDate.millisecondsSinceEpoch ~/ 1000;

    return SrsReviewSchedule(
      repetitionCount: repetitions,
      intervalDays: interval,
      easeFactor: ease,
      nextReviewEpoch: nextEpoch,
      isLeech: isLeech,
    );
  }

  /// Calculates a recommended SM-2 quality grade based on correctness and response time.
  static int gradeFromResponseTime({
    required bool isCorrect,
    required Duration responseTime,
    Duration rapidThreshold = const Duration(seconds: 3),
    Duration hardThreshold = const Duration(seconds: 10),
  }) {
    if (!isCorrect) return 0;
    if (responseTime <= rapidThreshold) return 4;
    if (responseTime > hardThreshold) return 2;
    return 3;
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
  /// Deduplicates calls via idempotent srs_review_events table when reviewEventId is provided.
  Future<SrsReviewSchedule> gradeAndPersist({
    required Database progressDb,
>>>>>>> origin/fix/security-reconciliation-and-audit-lane01-02
    required String lexemeId,
    required String targetLanguageCode,
    required SrsRating rating,
    int? currentTimeSeconds,
  }) async {
    final int nowSeconds =
        currentTimeSeconds ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

    return await db.transaction((txn) async {
      final List<Map<String, Object?>> results = await txn.query(
        'srs_progress',
        where: 'lexeme_id = ? AND target_language_code = ?',
<<<<<<< HEAD
        whereArgs: [lexemeId, targetLanguageCode],
=======
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

      final reviewed = (reviewedAt != null)
          ? reviewedAt.toUtc()
          : _clockGuard.getEffectiveUtcTime();
      int? elapsedDays;
      if (existing.isNotEmpty && existing.first['next_due_at'] != null) {
        final lastDueEpoch = (existing.first['next_due_at'] as num).toInt();
        final nowEpoch = reviewed.millisecondsSinceEpoch ~/ 1000;
        if (nowEpoch > lastDueEpoch) {
          elapsedDays = (nowEpoch - lastDueEpoch) ~/ secondsPerDay + state.intervalDays;
        }
      }

      final result = calculate(
        grade: grade,
        previous: state,
        reviewedAt: reviewed,
        elapsedDays: elapsedDays,
        alignToCircadianDay: alignToCircadianDay,
>>>>>>> origin/fix/security-reconciliation-and-audit-lane01-02
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
        inferredLastReviewedAt =
            currentState.nextDueAt! - (currentState.intervalDays * 86400);
      }

      if (inferredLastReviewedAt != null) {
        final diff = nowSeconds - inferredLastReviewedAt;
        if (diff >= 0 && diff < _debounceSeconds) {
          return SrsReviewSchedule(
            lexemeId: lexemeId,
            nextReviewDate: DateTime.fromMillisecondsSinceEpoch(
                currentState.nextDueAt! * 1000,
                isUtc: true),
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

      final baseTime =
          DateTime.fromMillisecondsSinceEpoch(nowSeconds * 1000, isUtc: true);
      final DateTime nextDueUtc =
          baseTime.add(Duration(days: nextIntervalDays));
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
