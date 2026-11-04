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

  // A legacy caller without an event ID still represents a durable review.
  // Generate an isolate/restart-independent identity so its timestamp is
  // retained in the existing journal without pretending retries deduplicate.
  static String _newAnonymousReviewEventId() {
    final random = math.Random.secure();
    final nonce = List<int>.generate(16, (_) => random.nextInt(256))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return 'LEGACY_ANON_$nonce';
  }

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

  // Reject corrupt numeric progress before acknowledging a replay or
  // overwriting a learner's durable schedule. SQLite INTEGER affinity
  // can still store a fractional REAL after a damaged import.
  static double _readPersistedEaseFactor(Object? value) {
    if (value is! num || !value.isFinite || value < minimumEaseFactor) {
      throw ArgumentError.value(
          value, 'ease_factor', 'Invalid persisted SRS ease factor');
    }
    return value.toDouble();
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
    // Persisted keys are exact identities. Accepting leading/trailing whitespace
    // silently creates a second progress row for the same learner content.
    // Reject malformed keys instead of trimming or migrating existing rows.
    if (lexemeId.trim().isEmpty ||
        languageCode.trim().isEmpty ||
        lexemeId != lexemeId.trim() ||
        languageCode != languageCode.trim()) {
      throw ArgumentError('Invalid lexeme ID or language code');
    }
    // A supplied event ID must never silently become a non-idempotent write.
    // In particular, whitespace-only IDs previously bypassed the journal
    // and could advance the same learner review on every retry. Preserve the
    // existing null (legacy/no-ID) API without normalizing distinct IDs.
    if (reviewEventId != null &&
        (reviewEventId.trim().isEmpty ||
            reviewEventId != reviewEventId.trim())) {
      throw ArgumentError.value(
        reviewEventId, 'reviewEventId', 'Invalid review event identity');
    }
    final durableEventId = reviewEventId ?? _newAnonymousReviewEventId();
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

      // Check idempotency if a unique review event ID was supplied
      if (reviewEventId != null && reviewEventId.trim().isNotEmpty) {
        final existingEvent = await txn.query(
          'srs_review_events',
          where: 'review_event_id = ?',
          whereArgs: <Object>[reviewEventId.trim()],
          limit: 1,
        );
        if (existingEvent.isNotEmpty) {
          // The review ID is an immutable command identity, not just a
          // duplicate counter. A replay for a different card, target language
          // or grade must never be acknowledged as the original review.
          final committed = existingEvent.single;
          if (committed['lexeme_id'] != lexemeId ||
              committed['target_language_code'] != languageCode ||
              committed['grade'] != grade) {
            throw StateError('Review event ID reused with a conflicting payload');
          }

          // The committed review instant is immutable as well. A retry that
          // supplies a different explicit timestamp must not be acknowledged
          // as the original learning action. Old INTEGER-second journals
          // cannot distinguish instants within that second; preserve their
          // legacy replay semantics without changing the database schema.
          final committedAt = committed['created_at'];
          if (committedAt is! num ||
              !committedAt.isFinite ||
              committedAt < 0) {
            throw StateError('Committed review has invalid timestamp');
          }
          if (reviewedAt != null) {
            final attemptedMicros = reviewedAt.toUtc().microsecondsSinceEpoch;
            final sameInstant = committedAt is int
                ? attemptedMicros ~/ Duration.microsecondsPerSecond == committedAt
                : (committedAt * Duration.microsecondsPerSecond).round() ==
                    attemptedMicros;
            if (!sameInstant) {
              throw StateError('Review event ID reused with a conflicting timestamp');
            }
          }

          // Idempotent: return the current durable schedule without advancing
          // it. If the progress row is missing, fail closed rather than
          // resurrecting a committed review and risking duplicate XP/SRS.
          final existing = await txn.query(
            'srs_progress',
            where: 'lexeme_id = ? AND target_language_code = ?',
            whereArgs: <Object>[lexemeId, languageCode],
            limit: 1,
          );
          if (existing.isEmpty) {
            throw StateError('Committed review is missing its progress row');
          }
          return SrsReviewSchedule(
            repetitionCount: _readPersistedCounter(
                existing.first['repetition_count'], 'repetition_count'),
            intervalDays: _readPersistedCounter(
                existing.first['interval_days'], 'interval_days'),
            easeFactor: _readPersistedEaseFactor(existing.first['ease_factor']),
            nextReviewEpoch: _readPersistedCounter(
                existing.first['next_due_at'], 'next_due_at'),
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
      // The event journal and SRS row form one durable learner history.
      // A delayed older event must not rewind the saved schedule after a
      // process restart, and a missing progress row must not be recreated
      // when committed events already prove that the learner studied it.
      // Use the existing transaction and journal; no schema migration.
      var reviewed = (reviewedAt != null)
          ? reviewedAt.toUtc()
          : _clockGuard.getEffectiveUtcTime();
      // Legacy callers may omit the event ID, but must not bypass the
      // committed journal's stale-review or missing-progress-row guards.
      // Only deduplication of the new event itself depends on an ID.
      final latestRows = await txn.rawQuery(
        'SELECT MAX(created_at) AS latest_review_at FROM srs_review_events '
        'WHERE lexeme_id = ? AND target_language_code = ?',
        <Object>[lexemeId, languageCode],
      );
      final latest = latestRows.single['latest_review_at'];
      if (latest != null) {
        if (existing.isEmpty) {
          throw StateError('Committed review is missing its progress row');
        }
        // Existing journal rows contain integer epoch seconds. New rows may
        // contain fractional seconds to preserve review ordering within one
        // second; SQLite's INTEGER affinity retains fractional REAL values.
        // Reject malformed journal timestamps rather than ignoring history.
        if (latest is! num || !latest.isFinite || latest < 0) {
          throw ArgumentError.value(
              latest, 'created_at', 'Invalid persisted review timestamp');
        }
        final latestMicros =
            (latest * Duration.microsecondsPerSecond).round();
        // A fresh scheduler after process death has no prior clock anchor.
        // For an ordinary new review (no caller-supplied instant), continue
        // after the last durable event even if the device clock moved back.
        // Explicitly timestamped delayed commands must still fail closed.
        if (reviewedAt == null &&
            reviewed.microsecondsSinceEpoch <= latestMicros) {
          reviewed = DateTime.fromMicrosecondsSinceEpoch(
            latestMicros + 1,
            isUtc: true,
          );
        }
        if (reviewed.microsecondsSinceEpoch < latestMicros) {
          throw StateError('Stale review cannot overwrite durable progress');
        }
      }

      final state = existing.isEmpty
          ? const SrsReviewState()
          : SrsReviewState(
              repetitionCount: _readPersistedCounter(
                existing.first['repetition_count'], 'repetition_count',
              ),
              intervalDays: _readPersistedCounter(
                existing.first['interval_days'], 'interval_days',
              ),
              easeFactor: _readPersistedEaseFactor(existing.first['ease_factor']),
            );

      int? elapsedDays;
      if (existing.isNotEmpty && existing.first['next_due_at'] != null) {
        final lastDueEpoch = _readPersistedCounter(
            existing.first['next_due_at'], 'next_due_at');
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

      // Every successful review contributes to the durable stale-review
      // watermark. Previously null-ID calls left no journal entry, allowing
      // older anonymous writes after restart and lost-row resurrection.
      // Only caller-supplied IDs are eligible for exact replay deduplication.
      await txn.insert('srs_review_events', <String, Object?>{
        'review_event_id': durableEventId,
        'lexeme_id': lexemeId,
        'target_language_code': languageCode,
        'grade': grade,
        // Preserve subsecond ordering without changing the existing table.
        // Legacy INTEGER epoch-second rows remain readable and comparable.
        'created_at':
            reviewed.microsecondsSinceEpoch / Duration.microsecondsPerSecond,
      });

      return result;
    });
  }
}
