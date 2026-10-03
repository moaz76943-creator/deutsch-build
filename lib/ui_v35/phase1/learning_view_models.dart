final class LearningCardViewModel {
  final String sourceText;
  final String targetText;
  final String prompt;
  final double progress;

  const LearningCardViewModel({
    required this.sourceText,
    required this.targetText,
    required this.prompt,
    required this.progress,
  });

  factory LearningCardViewModel.fromNeutralMap(Map<String, Object?> map) {
    final sourceText = _requiredText(map, 'sourceText');
    final targetText = _requiredText(map, 'targetText');
    final prompt = (map['prompt'] as String?) ?? '';
    final rawProgress = map['progress'];

    return LearningCardViewModel(
      sourceText: sourceText,
      targetText: targetText,
      prompt: prompt,
      progress:
          rawProgress is num ? rawProgress.toDouble().clamp(0.0, 1.0) : 0.0,
    );
  }
}

final class TodayHomeViewModel {
  final String title;
  final int dueCount;
  final int dailyGoal;
  final int completedToday;

  const TodayHomeViewModel({
    required this.title,
    required this.dueCount,
    required this.dailyGoal,
    required this.completedToday,
  });
}

final class StudyCardViewModel {
  final String sourceText;
  final String targetText;
  final String prompt;
  final double progress;

  const StudyCardViewModel({
    required this.sourceText,
    required this.targetText,
    required this.prompt,
    required this.progress,
  });
}

final class ReviewQueueItemViewModel {
  final String id;
  final String sourceText;
  final String targetText;
  final String dueLabel;

  const ReviewQueueItemViewModel({
    required this.id,
    required this.sourceText,
    required this.targetText,
    required this.dueLabel,
  });
}

final class ReviewQueueViewModel {
  final List<ReviewQueueItemViewModel> items;

  const ReviewQueueViewModel({required this.items});
}

String _requiredText(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! String || value.trim().isEmpty) {
    throw ArgumentError.value(value, key, 'must be a non-empty string');
  }
  return value;
}
