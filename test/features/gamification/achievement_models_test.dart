import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/gamification/domain/achievement_models.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_models.dart';

void main() {
  test('UserStreak exposes available freeze days and recent seven-day pattern', () {
    final streak = UserStreak.fromProfile(
      const GamificationProfile(
        currentStreak: 3,
        longestStreak: 8,
        lastLocalDay: '2026-10-03',
        streakFreezeAvailable: true,
      ),
    );

    expect(streak.streakFreezesAvailable, 1);
    expect(streak.freezeAvailable, isTrue);
    expect(
      streak.recentSevenDayActivity,
      <bool>[false, false, false, false, true, true, true],
    );
  });

  test('UserStreak exposes zero freeze days after freeze is consumed', () {
    final streak = UserStreak.fromProfile(
      const GamificationProfile(
        currentStreak: 4,
        longestStreak: 4,
        streakFreezeAvailable: false,
      ),
    );

    expect(streak.streakFreezesAvailable, 0);
    expect(streak.freezeAvailable, isFalse);
  });

  test('UserXpRecord derives deterministic level and progress from total XP', () {
    final record = UserXpRecord.fromProfile(
      const GamificationProfile(totalXp: 375),
    );

    expect(record.totalXp, 375);
    expect(record.xp, 375);
    expect(record.currentLevel, 2);
    expect(record.levelFloorXp, 250);
    expect(record.nextLevelXp, 500);
    expect(record.progressToNextLevel, 0.5);
  });

  test('achievement projections include explicit unlock conditions', () {
    const snapshot = GamificationSnapshot(
      profile: GamificationProfile(totalXp: 80, currentStreak: 3),
      unlocked: <UnlockedMilestone>[],
      badges: GamificationMilestones.defaults,
    );

    final xpBadge = snapshot.achievementBadges
        .firstWhere((badge) => badge.id == 'xp_100');
    final streakBadge = snapshot.achievementBadges
        .firstWhere((badge) => badge.id == 'streak_7');

    expect(xpBadge.unlockCondition, contains('100 XP'));
    expect(streakBadge.unlockCondition, contains('7'));
    expect(xpBadge.isUnlocked, isFalse);
  });
}
