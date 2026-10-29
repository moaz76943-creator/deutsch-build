import 'package:test/test.dart';
import 'package:deutsch_build/src/core/gamification/adaptive_daily_quest_engine.dart';

void main() {
  group('AdaptiveDailyQuestEngine Tests', () {
    const engine = AdaptiveDailyQuestEngine();

    test('Generates 3 personalized quests tailored to weak words and pronunciation', () {
      final quests = engine.generateDailyQuests(
        weakWordsCount: 8,
        hasPronunciationIssues: true,
        streakDays: 12,
      );

      expect(quests.length, equals(3));
      expect(quests[0].targetCount, equals(8));
      expect(quests[1].description, contains('80%'));
      expect(quests[2].description, contains('12'));
    });

    test('Advances quest progress and marks completed accurately', () {
      var quest = const DailyQuest(
        id: 'q1',
        title: 'Test',
        description: 'Test',
        targetCount: 5,
        rewardXp: 50,
      );

      expect(quest.isCompleted, isFalse);
      quest = quest.advanceProgress(3);
      expect(quest.currentCount, equals(3));
      expect(quest.isCompleted, isFalse);

      quest = quest.advanceProgress(2);
      expect(quest.currentCount, equals(5));
      expect(quest.isCompleted, isTrue);
    });
  });
}
