import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_clock_integrity_source.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_models.dart';
import 'package:deutsch_bilarabi/features/gamification/gamification_engine.dart';
import 'package:flutter_test/flutter_test.dart';

GamificationReviewEvent _event({
  required String id,
  required DateTime atUtc,
  required int elapsedMs,
  required int bootCount,
  int offsetMinutes = 180,
}) =>
    GamificationReviewEvent(
      reviewId: id,
      facetType: ReviewFacetType.meaningRecall,
      correct: true,
      hinted: false,
      requestedXp: 10,
      occurredAtUtc: atUtc,
      timezoneOffsetMinutes: offsetMinutes,
      clockIntegrityStamp: GamificationClockIntegrityStamp(
        elapsedRealtimeMilliseconds: elapsedMs,
        bootCount: bootCount,
      ),
    );

void main() {
  group('same-boot monotonic clock integrity', () {
    const profile = GamificationProfile(
      totalXp: 40,
      currentStreak: 3,
      longestStreak: 3,
      lastReviewAtUtc: null,
      lastLocalDay: '2026-10-02',
      lastTimezoneOffsetMinutes: 180,
      lastMonotonicElapsedMilliseconds: 1000000,
      lastBootCount: 7,
    );

    test('forward wall-clock jump fails closed without inflating streak', () {
      final current = GamificationProfile(
        totalXp: profile.totalXp,
        currentStreak: profile.currentStreak,
        longestStreak: profile.longestStreak,
        lastReviewAtUtc: DateTime.utc(2026, 10, 2, 8),
        lastLocalDay: profile.lastLocalDay,
        lastTimezoneOffsetMinutes: profile.lastTimezoneOffsetMinutes,
        lastMonotonicElapsedMilliseconds:
            profile.lastMonotonicElapsedMilliseconds,
        lastBootCount: profile.lastBootCount,
      );

      final result = GamificationEngine.apply(
        current,
        _event(
          id: 'jump',
          atUtc: DateTime.utc(2026, 10, 3, 8),
          elapsedMs: 1060000,
          bootCount: 7,
        ),
      );

      expect(result.clockAnomaly, isTrue);
      expect(result.awardedXp, 0);
      expect(result.profile.currentStreak, 3);
      expect(result.profile.lastLocalDay, '2026-10-02');
      expect(result.profile.clockAnomalyDetected, isTrue);
      expect(result.profile.lastMonotonicElapsedMilliseconds, 1000000);
    });

    test('matching wall and elapsed time advances streak normally', () {
      final current = GamificationProfile(
        totalXp: profile.totalXp,
        currentStreak: profile.currentStreak,
        longestStreak: profile.longestStreak,
        lastReviewAtUtc: DateTime.utc(2026, 10, 2, 8),
        lastLocalDay: profile.lastLocalDay,
        lastTimezoneOffsetMinutes: profile.lastTimezoneOffsetMinutes,
        lastMonotonicElapsedMilliseconds:
            profile.lastMonotonicElapsedMilliseconds,
        lastBootCount: profile.lastBootCount,
      );

      final result = GamificationEngine.apply(
        current,
        _event(
          id: 'legit',
          atUtc: DateTime.utc(2026, 10, 3, 8),
          elapsedMs: 87400000,
          bootCount: 7,
        ),
      );

      expect(result.clockAnomaly, isFalse);
      expect(result.profile.currentStreak, 4);
      expect(result.profile.lastMonotonicElapsedMilliseconds, 87400000);
      expect(result.profile.lastBootCount, 7);
    });

    test('new boot re-baselines monotonic stamp without false anomaly', () {
      final current = GamificationProfile(
        totalXp: profile.totalXp,
        currentStreak: profile.currentStreak,
        longestStreak: profile.longestStreak,
        lastReviewAtUtc: DateTime.utc(2026, 10, 2, 8),
        lastLocalDay: profile.lastLocalDay,
        lastTimezoneOffsetMinutes: profile.lastTimezoneOffsetMinutes,
        lastMonotonicElapsedMilliseconds:
            profile.lastMonotonicElapsedMilliseconds,
        lastBootCount: profile.lastBootCount,
      );

      final result = GamificationEngine.apply(
        current,
        _event(
          id: 'reboot',
          atUtc: DateTime.utc(2026, 10, 3, 8),
          elapsedMs: 30000,
          bootCount: 8,
        ),
      );

      expect(result.clockAnomaly, isFalse);
      expect(result.profile.currentStreak, 4);
      expect(result.profile.lastMonotonicElapsedMilliseconds, 30000);
      expect(result.profile.lastBootCount, 8);
    });

    test('missing platform stamp preserves the last trusted anchor', () {
      final current = GamificationProfile(
        totalXp: profile.totalXp,
        currentStreak: profile.currentStreak,
        longestStreak: profile.longestStreak,
        lastReviewAtUtc: DateTime.utc(2026, 10, 2, 8),
        lastLocalDay: profile.lastLocalDay,
        lastTimezoneOffsetMinutes: profile.lastTimezoneOffsetMinutes,
        lastMonotonicElapsedMilliseconds:
            profile.lastMonotonicElapsedMilliseconds,
        lastBootCount: profile.lastBootCount,
      );

      final result = GamificationEngine.apply(
        current,
        GamificationReviewEvent(
          reviewId: 'probe-unavailable',
          facetType: ReviewFacetType.meaningRecall,
          correct: true,
          hinted: false,
          requestedXp: 10,
          occurredAtUtc: DateTime.utc(2026, 10, 2, 9),
          timezoneOffsetMinutes: 180,
        ),
      );

      expect(result.clockAnomaly, isFalse);
      expect(result.profile.lastMonotonicElapsedMilliseconds, 1000000);
      expect(result.profile.lastBootCount, 7);
    });

    test('same-boot monotonic regression fails closed', () {
      final current = GamificationProfile(
        totalXp: profile.totalXp,
        currentStreak: profile.currentStreak,
        longestStreak: profile.longestStreak,
        lastReviewAtUtc: DateTime.utc(2026, 10, 2, 8),
        lastLocalDay: profile.lastLocalDay,
        lastTimezoneOffsetMinutes: profile.lastTimezoneOffsetMinutes,
        lastMonotonicElapsedMilliseconds:
            profile.lastMonotonicElapsedMilliseconds,
        lastBootCount: profile.lastBootCount,
      );

      final result = GamificationEngine.apply(
        current,
        _event(
          id: 'mono-regression',
          atUtc: DateTime.utc(2026, 10, 2, 9),
          elapsedMs: 999000,
          bootCount: 7,
        ),
      );

      expect(result.clockAnomaly, isTrue);
      expect(result.profile.currentStreak, 3);
      expect(result.awardedXp, 0);
    });
  });
}
