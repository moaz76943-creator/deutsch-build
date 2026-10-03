import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/gamification/application/gamification_notifier.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/achievement_models.dart';
import 'package:deutsch_bilarabi/features/gamification/presentation/screens/badges_showcase_screen.dart';
import 'package:deutsch_bilarabi/features/gamification/presentation/widgets/streak_status_widget.dart';

void main() {
  testWidgets('StreakStatusWidget renders seven bounded day indicators', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StreakStatusWidget(
            streak: UserStreak(
              currentDays: 4,
              longestDays: 9,
              lastActivityDate: null,
              streakFreezesAvailable: 1,
            ),
          ),
        ),
      ),
    );

    for (var index = 0; index < 7; index += 1) {
      expect(find.byKey(ValueKey<String>('streak-day-$index')), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('BadgesShowcaseScreen explains locked achievement condition', (
    tester,
  ) async {
    const badge = AchievementBadge(
      id: 'streak_7',
      name: 'أسبوع متواصل',
      description: 'حافظ على عادة التعلم.',
      icon: 'local_fire_department',
      unlockCondition: 'حافظ على سلسلة 7 أيام',
      unlockedAt: null,
    );
    const state = GamificationViewState(
      streak: UserStreak(
        currentDays: 2,
        longestDays: 2,
        lastActivityDate: null,
        streakFreezesAvailable: 1,
      ),
      progress: UserXpRecord(
        totalXp: 50,
        currentLevel: 1,
        levelFloorXp: 0,
        nextLevelXp: 250,
        progressToNextLevel: 0.2,
      ),
      badges: <AchievementBadge>[badge],
      badgeProgress: <String, double>{'streak_7': 2 / 7},
    );

    await tester.pumpWidget(
      const MaterialApp(home: BadgesShowcaseScreen(state: state)),
    );

    expect(find.text('حافظ على سلسلة 7 أيام'), findsOneWidget);
    expect(find.text('مغلق'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
