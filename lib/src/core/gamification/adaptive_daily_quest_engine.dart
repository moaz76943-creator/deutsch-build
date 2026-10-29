/// Daily challenge quest tailored to learner weaknesses.
class DailyQuest {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int currentCount;
  final int rewardXp;
  final bool isCompleted;

  const DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    this.currentCount = 0,
    required this.rewardXp,
    this.isCompleted = false,
  });

  DailyQuest advanceProgress(int increment) {
    final newCount = (currentCount + increment).clamp(0, targetCount);
    return DailyQuest(
      id: id,
      title: title,
      description: description,
      targetCount: targetCount,
      currentCount: newCount,
      rewardXp: rewardXp,
      isCompleted: newCount >= targetCount,
    );
  }
}

/// Generates daily cognitive quests addressing low-stability FSRS items and pronunciation.
class AdaptiveDailyQuestEngine {
  const AdaptiveDailyQuestEngine();

  /// Synthesizes three personalized daily quests based on learner telemetry.
  List<DailyQuest> generateDailyQuests({
    required int weakWordsCount,
    required bool hasPronunciationIssues,
    required int streakDays,
  }) {
    return [
      DailyQuest(
        id: 'quest_fsrs_review',
        title: 'مراجعة تثبيت الذاكرة',
        description: 'راجع $weakWordsCount كلمات ذات ثبات ذاكرة منخفض في جدول FSRS اليوم.',
        targetCount: weakWordsCount > 0 ? weakWordsCount : 10,
        rewardXp: 50,
      ),
      DailyQuest(
        id: 'quest_pronunciation',
        title: 'صقل النطق الصوتي',
        description: hasPronunciationIssues
            ? 'سجل نطق 5 كلمات بدقة فونيمية تزيد عن 80%.'
            : 'أكمل جلستي تدريب استماع ومحاكاة شادوينغ.',
        targetCount: 5,
        rewardXp: 40,
      ),
      DailyQuest(
        id: 'quest_streak_keeper',
        title: 'حارس الحماسة',
        description: 'أكمل درساً كاملاً للحفاظ على سلسلة الـ $streakDays يوماً متتالية.',
        targetCount: 1,
        rewardXp: 30,
      ),
    ];
  }
}
