import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../lib/features/progress/domain/services/streak_milestones_engine.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    final dbPath = await getDatabasesPath();
    await databaseFactory.deleteDatabase('$dbPath/streak_tracking.db');
    // reset database instance
    await StreakMilestonesEngine.instance.close();
  });

  test('unlocks milestones based on streak', () async {
    final engine = StreakMilestonesEngine.instance;

    await engine.checkAndUnlockMilestones(3);
    var badges = await engine.getUnlockedBadges();
    expect(badges.length, 1);
    expect(badges.first.id, 'streak_3');

    await engine.checkAndUnlockMilestones(8);
    badges = await engine.getUnlockedBadges();
    expect(badges.length, 2);
    expect(badges.any((b) => b.id == 'streak_7'), true);
  });

  test('calculates correct streak', () async {
    final engine = StreakMilestonesEngine.instance;
    final today = DateTime.now();

    await engine.logStudyDay(today.subtract(const Duration(days: 2)));
    await engine.logStudyDay(today.subtract(const Duration(days: 1)));
    await engine.logStudyDay(today);

    final streak = await engine.calculateCurrentStreak();
    expect(streak, 3);
  });

  test('streak breaks when days are missed', () async {
    final engine = StreakMilestonesEngine.instance;
    final today = DateTime.now();

    await engine.logStudyDay(today.subtract(const Duration(days: 3)));
    await engine.logStudyDay(today);

    final streak = await engine.calculateCurrentStreak();
    expect(streak, 1);
  });
}
