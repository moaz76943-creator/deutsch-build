import '../core/content_contract.dart';
import '../models/learner.dart';
import '../language/language_content_quality.dart';

class VocabularyCoach {
  static List<LearningContent> recommend(
    List<LearningContent> items,
    LearnerState state, {
    required LanguageContentQuality contentQuality,
    int limit = 8,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final attempts = <String, List<Attempt>>{};
    for (final attempt in state.meaningAttempts) {
      attempts.putIfAbsent(attempt.itemId, () => []).add(attempt);
    }
    final due = state.meaningReviewCards
        .where((c) => !c.dueAt.isAfter(at))
        .map((c) => c.itemId)
        .toSet();
    const maxRanked = 120;
    final ranked = <LearningContent>[];
    final rankedScores = <int>[];
    for (final item in items) {
      if (!contentQuality.isLearnable(item) || item.sourceText.trim().isEmpty)
        continue;
      final score = _priority(
        item,
        attempts[item.id] ?? const [],
        due.contains(item.id),
      );
      var insertAt = 0;
      while (insertAt < rankedScores.length && rankedScores[insertAt] >= score)
        insertAt++;
      if (ranked.length < maxRanked) {
        ranked.insert(insertAt, item);
        rankedScores.insert(insertAt, score);
      } else if (insertAt < maxRanked) {
        ranked.insert(insertAt, item);
        rankedScores.insert(insertAt, score);
        ranked.removeLast();
        rankedScores.removeLast();
      }
    }
    return ranked.take(limit.clamp(1, 120)).toList(growable: false);
  }

  static int _priority(LearningContent item, List<Attempt> attempts, bool due) {
    if (due) return 1000;
    if (attempts.isEmpty) return 700;
    final errors = attempts.where((a) => !a.correct).length;
    final recent =
        attempts.length > 6 ? attempts.sublist(attempts.length - 6) : attempts;
    final recentErrors = recent.where((a) => !a.correct).length;
    final hintCount = attempts.where((a) => a.hinted).length;
    return 500 +
        errors * 30 +
        recentErrors * 45 +
        hintCount * 8 +
        item.skill.length;
  }
}
