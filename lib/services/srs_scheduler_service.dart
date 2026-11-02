import 'dart:math' as math;

import 'package:sqflite/sqflite.dart';
import '../core/security/monotonic_clock_guard.dart';

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
  final bool isLeech;

  const SrsReviewSchedule({
    required this.repetitionCount,
    required this.intervalDays,
    required this.easeFactor,
    required this.nextReviewEpoch,
    this.isLeech = false,
  });

  SrsReviewState asState() => SrsReviewState(
        repetitionCount: repetitionCount,
        intervalDays: intervalDays,
        easeFactor: easeFactor,
      );
}

/// A deterministic SM-2 scheduler with cognitive enhancements:
/// - Leech remediation & detection
/// - Overdue review interval recovery
/// - Circadian day rollover boundary alignment
/// - Response-time grade scoring
/// - Idempotent review event transaction deduplication
class SrsSchedulerService {
  static const double initialEaseFactor = 2.5;
  static const double minimumEaseFactor = 1.3;
  static const int secondsPerDay = 86400;

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
      interval = math.max(1, (6 * facetMultiplier).round());
    } else {
      // Overdue recovery: if actual elapsed days exceed scheduled interval,
      // factor in a fraction of true retention memory span.
      var baseInterval = previous.intervalDays;
      if (successful && elapsedDays != null && elapsedDays > previous.intervalDays) {
        baseInterval = math.max(
          previous.intervalDays,
          (previous.intervalDays + (elapsedDays - previous.intervalDays) * 0.25).round(),
        );
      }
      interval = math.max(1, (baseInterval * ease * facetMultiplier).round());
    }

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
    required String lexemeId,
    required String languageCode,
    required int grade,
    DateTime? reviewedAt,
    String? reviewEventId,
    bool alignToCircadianDay = false,
  }) async {
    if (lexemeId.trim().isEmpty || languageCode.trim().isEmpty) {
      throw ArgumentError('A lexeme ID and language code are required');
    }
    return progressDb.transaction((txn) async {
      // Ensure review events table for idempotency
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS srs_review_events (
          review_event_id TEXT PRIMARY KEY,
          lexeme_id TEXT NOT NULL,
          target_language_code TEXT NOT NULL,
          grade INTEGER NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');

      final reviewed = (reviewedAt != null)
          ? reviewedAt.toUtc()
          : _clockGuard.getEffectiveUtcTime();
      final nowEpoch = reviewed.millisecondsSinceEpoch ~/ 1000;

      // Check idempotency via explicit ID or temporal inference (debounce 5 mins)
      bool isDuplicate = false;
      if (reviewEventId != null && reviewEventId.trim().isNotEmpty) {
        final existingEvent = await txn.query(
          'srs_review_events',
          where: 'review_event_id = ?',
          whereArgs: <Object>[reviewEventId.trim()],
          limit: 1,
        );
        if (existingEvent.isNotEmpty) {
          isDuplicate = true;
        }
      } else {
        // Temporal inference
        final recentEvents = await txn.query(
          'srs_review_events',
          where: 'lexeme_id = ? AND target_language_code = ? AND created_at >= ? AND created_at <= ?',
          whereArgs: <Object>[lexemeId, languageCode, nowEpoch - 300, nowEpoch],
          limit: 1,
        );
        if (recentEvents.isNotEmpty) {
          isDuplicate = true;
        }
      }

      if (isDuplicate) {
        // Idempotent: already processed. Return current schedule without mutating state.
        final existing = await txn.query(
          'srs_progress',
          where: 'lexeme_id = ? AND target_language_code = ?',
          whereArgs: <Object>[lexemeId, languageCode],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          return SrsReviewSchedule(
            repetitionCount: _readPersistedCounter(existing.first['repetition_count'], 'repetition_count'),
            intervalDays: _readPersistedCounter(existing.first['interval_days'], 'interval_days'),
            easeFactor: (existing.first['ease_factor'] as num).toDouble(),
            nextReviewEpoch: existing.first['next_due_at'] is num ? (existing.first['next_due_at'] as num).toInt() : 0,
          );
        }
      }

      final existing = await txn.query(
        'srs_progress',
        columns: <String>['repetition_count', 'interval_days', 'ease_factor', 'next_due_at'],
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

      int? elapsedDays;
      if (existing.isNotEmpty && existing.first['next_due_at'] != null) {
        final lastDueEpoch = (existing.first['next_due_at'] as num).toInt();
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
      );

      final values = <String, Object?>{
        'target_language_code': languageCode,
        'repetition_count': result.repetitionCount,
        'interval_days': result.intervalDays,
        'ease_factor': result.easeFactor,
        'next_due_at': result.nextReviewEpoch,
        'status': result.isLeech
            ? 'leech'
            : (result.repetitionCount > 1 ? 'review' : 'learning'),
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

      // Record review event for idempotency & audit ledger
      final effectiveEventId = (reviewEventId != null && reviewEventId.trim().isNotEmpty)
          ? reviewEventId.trim()
          : 'auto_${lexemeId}_${languageCode}_$nowEpoch';

      await txn.insert('srs_review_events', <String, Object?>{
        'review_event_id': effectiveEventId,
        'lexeme_id': lexemeId,
        'target_language_code': languageCode,
        'grade': grade,
        'created_at': nowEpoch,
      });

      return result;
    });
  }
}
