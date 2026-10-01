import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/streak_milestones_engine.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('StreakMilestonesEngine', () {
    late StreakMilestonesEngine engine;

    setUp(() async {
      engine = StreakMilestonesEngine.instance;
      // Clear database before each test
      final db = await engine.database;
      await db.execute('DELETE FROM streak_milestones');
    });

    test('unlocks badges when streak requirement is met', () async {
      final unlocked = await engine.checkAndUnlockMilestones(5);
      expect(unlocked, contains('streak_3'));
      expect(unlocked, isNot(contains('streak_7')));

      final dbUnlocked = await engine.getUnlockedMilestones();
      expect(dbUnlocked, contains('streak_3'));
    });

    test('does not unlock already unlocked badges', () async {
      await engine.checkAndUnlockMilestones(5);

      final unlockedAgain = await engine.checkAndUnlockMilestones(5);
      expect(unlockedAgain, isEmpty);

      final unlockedLater = await engine.checkAndUnlockMilestones(8);
      expect(unlockedLater, contains('streak_7'));
      expect(unlockedLater, isNot(contains('streak_3')));
    });

    test('unlocks multiple badges if streak jumps', () async {
      final unlocked = await engine.checkAndUnlockMilestones(35);
      expect(unlocked, containsAll(['streak_3', 'streak_7', 'streak_30']));
      expect(unlocked, isNot(contains('streak_100')));
    });
  });
}
