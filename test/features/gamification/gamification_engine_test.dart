import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_models.dart';
import 'package:deutsch_bilarabi/features/gamification/gamification_engine.dart';

GamificationReviewEvent event(
  String id,
  DateTime at, {
  int xp = 10,
  int offsetMinutes = 180,
}) => GamificationReviewEvent(
  reviewId: id,
  facetType: ReviewFacetType.listening,
  correct: true,
  hinted: false,
  requestedXp: xp,
  occurredAtUtc: at.toUtc(),
  timezoneOffsetMinutes: offsetMinutes,
);

void main() {
  test('awards XP and starts streak on first SRS review', () {
    final result = GamificationEngine.apply(
      const GamificationProfile(),
      event('r1', DateTime.utc(2026, 10, 2, 7)),
    );

    expect(result.awardedXp, 10);
    expect(result.profile.totalXp, 10);
    expect(result.profile.currentStreak, 1);
    expect(result.profile.lastLocalDay, '2026-10-02');
  });

  test('increments streak only on the next local calendar day', () {
    final first = GamificationEngine.apply(
      const GamificationProfile(),
      event('r1', DateTime.utc(2026, 10, 2, 7)),
    );
    final sameDay = GamificationEngine.apply(
      first.profile,
      event('r2', DateTime.utc(2026, 10, 2, 18)),
    );
    final nextDay = GamificationEngine.apply(
      sameDay.profile,
      event('r3', DateTime.utc(2026, 10, 3, 7)),
    );

    expect(sameDay.profile.currentStreak, 1);
    expect(nextDay.profile.currentStreak, 2);
    expect(nextDay.profile.longestStreak, 2);
  });

  test('missed local day resets current streak without losing longest', () {
    const profile = GamificationProfile(
      totalXp: 300,
      currentStreak: 7,
      longestStreak: 7,
      lastReviewAtUtc: null,
      lastLocalDay: '2026-10-01',
      lastTimezoneOffsetMinutes: 180,
    );

    final result = GamificationEngine.apply(
      profile,
      event('r4', DateTime.utc(2026, 10, 4, 7)),
    );

    expect(result.profile.currentStreak, 1);
    expect(result.profile.longestStreak, 7);
  });

  test('backward clock manipulation fails closed with zero XP', () {
    final last = DateTime.utc(2026, 10, 2, 15);
    final result = GamificationEngine.apply(
      GamificationProfile(
        totalXp: 90,
        currentStreak: 3,
        longestStreak: 4,
        lastReviewAtUtc: last,
        lastLocalDay: '2026-10-02',
        lastTimezoneOffsetMinutes: 180,
      ),
      event('r5', DateTime.utc(2026, 10, 2, 12)),
    );

    expect(result.clockAnomaly, isTrue);
    expect(result.awardedXp, 0);
    expect(result.profile.totalXp, 90);
    expect(result.profile.currentStreak, 3);
    expect(result.profile.clockAnomalyDetected, isTrue);
  });

  test('local-day regression from timezone manipulation fails closed', () {
    final result = GamificationEngine.apply(
      GamificationProfile(
        totalXp: 90,
        currentStreak: 3,
        longestStreak: 4,
        lastReviewAtUtc: DateTime.utc(2026, 10, 2, 1),
        lastLocalDay: '2026-10-02',
        lastTimezoneOffsetMinutes: 780,
      ),
      event('r6', DateTime.utc(2026, 10, 2, 2), offsetMinutes: -720),
    );

    expect(result.clockAnomaly, isTrue);
    expect(result.awardedXp, 0);
    expect(result.profile.currentStreak, 3);
  });

  test('unlocks milestones from XP and streak thresholds', () {
    final result = GamificationEngine.apply(
      GamificationProfile(
        totalXp: 95,
        currentStreak: 6,
        longestStreak: 6,
        lastReviewAtUtc: DateTime.utc(2026, 10, 1, 7),
        lastLocalDay: '2026-10-01',
        lastTimezoneOffsetMinutes: 180,
      ),
      event('r7', DateTime.utc(2026, 10, 2, 7)),
    );

    expect(
      result.newlyUnlocked.map((badge) => badge.id),
      containsAll(<String>['xp_100', 'streak_7']),
    );
  });

  test('one-day excused absence consumes freeze and preserves streak', () {
    final result = GamificationEngine.apply(
      GamificationProfile(
        totalXp: 200,
        currentStreak: 4,
        longestStreak: 6,
        lastReviewAtUtc: DateTime.utc(2026, 10, 1, 7),
        lastLocalDay: '2026-10-01',
        lastTimezoneOffsetMinutes: 180,
      ),
      GamificationReviewEvent(
        reviewId: 'freeze_1',
        facetType: ReviewFacetType.meaningRecall,
        correct: true,
        hinted: false,
        requestedXp: 10,
        occurredAtUtc: DateTime.utc(2026, 10, 3, 7),
        timezoneOffsetMinutes: 180,
        useStreakFreeze: true,
      ),
    );

    expect(result.profile.currentStreak, 5);
    expect(result.profile.longestStreak, 6);
    expect(result.profile.streakFreezeAvailable, isFalse);
    expect(result.streakFreezeUsed, isTrue);
  });

  test('streak freeze does not cover more than one missed local day', () {
    final result = GamificationEngine.apply(
      GamificationProfile(
        currentStreak: 8,
        longestStreak: 8,
        lastReviewAtUtc: DateTime.utc(2026, 10, 1, 7),
        lastLocalDay: '2026-10-01',
        lastTimezoneOffsetMinutes: 180,
      ),
      GamificationReviewEvent(
        reviewId: 'freeze_2',
        facetType: ReviewFacetType.meaningRecall,
        correct: true,
        hinted: false,
        requestedXp: 10,
        occurredAtUtc: DateTime.utc(2026, 10, 4, 7),
        timezoneOffsetMinutes: 180,
        useStreakFreeze: true,
      ),
    );

    expect(result.profile.currentStreak, 1);
    expect(result.profile.longestStreak, 8);
    expect(result.profile.streakFreezeAvailable, isTrue);
    expect(result.streakFreezeUsed, isFalse);
  });

}
