import '../core/content_contract.dart';
import '../language/language_exercise_strategy.dart';
import '../language/language_content_quality.dart';
import '../language/language_content_intelligence.dart';
import '../models/learner.dart';
import '../models/learning_path.dart';
import 'adaptive_teacher.dart';
import 'memory.dart';
import 'mistake_engine.dart';
import '../models/mistake.dart';
import 'vocabulary_coach.dart';
import 'mastery.dart';
import 'adaptive_focus.dart';
import 'learning_intelligence.dart';
import 'production_engine.dart';

class LearningEngine {
  static LearningPath buildPlan(
    List<LearningContent> items,
    LearnerState state, {
    required LanguageExerciseStrategy exerciseStrategy,
    required LanguageContentQuality contentQuality,
    required LanguageContentIntelligence contentIntelligence,
    DateTime? now,
    int dailyGoal = 10,
  }) {
    final at = now ?? DateTime.now();
    final goal = dailyGoal.clamp(5, 20).toInt();
    final eligible =
        items.where((x) => contentQuality.issues(x).isEmpty).toList();
    final eligibleById = <String, LearningContent>{
      for (final item in eligible) item.id: item,
    };
    final meaningAttempts = state.meaningAttempts.toList(growable: false);
    final attemptsByItem = <String, List<Attempt>>{};
    for (final attempt in meaningAttempts) {
      (attemptsByItem[attempt.itemId] ??= <Attempt>[]).add(attempt);
    }
    final teacher = AdaptiveTeacher.next(state, now: at);
    final weak = teacher.skill;
    final mistakes = MistakeEngine.from(
      meaningAttempts,
      eligible,
      now: at,
    ).items;
    final due = MemoryQueue.rank(
      state.meaningReviewCards,
      now: at,
      limit: goal,
    );
    final teacherBudget = teacher.itemCount.clamp(1, goal).toInt();
    final reviewBoost = (teacher.reviewPressure * 12).round();
    var selected = <LearningPathItem>[];
    final seen = <String>{};
    void add(String id, String mode, String reason, int priority) {
      if (!seen.add(id) || selected.length >= goal) return;
      final item = eligibleById[id];
      if (item != null)
        selected.add(
          LearningPathItem(
            item: item,
            mode: mode,
            reason: reason,
            priority: priority,
          ),
        );
    }

    for (final card in due)
      add(
        card.itemId,
        'review',
        MemoryQueue.reason(card, now: at).name,
        120 + MemoryQueue.priority(card, at).round() + reviewBoost,
      );
    for (final m in mistakes) {
      if (selected.length >= goal) break;
      add(
        m.itemId,
        _modeForMistake(m.category),
        '${m.diagnosis} • ${m.errorCount} أخطاء من ${m.attemptCount} محاولات',
        90 + m.severity,
      );
    }
    final coached = VocabularyCoach.recommend(
      eligible,
      state,
      contentQuality: contentQuality,
      limit: eligible.length,
      now: at,
    );
    final priorityById = <String, int>{
      for (final item in coached)
        item.id: _itemPriority(item, attemptsByItem, weak),
    };
    final remaining = [...coached];
    final intelligenceLimit =
        (goal * 3).clamp(20, 120).clamp(1, remaining.length).toInt();
    final intelligenceCandidates =
        remaining.take(intelligenceLimit).toList(growable: false);
    final intelligence = LearningIntelligence.rankSession(
      intelligenceCandidates,
      state,
      contentIntelligence: contentIntelligence,
      now: at,
      limit: intelligenceLimit,
    );
    final intelligenceById = {for (final d in intelligence) d.itemId: d};
    while (selected.length < goal && remaining.isNotEmpty) {
      var bestIndex = 0;
      var bestScore = double.negativeInfinity;
      for (var i = 0; i < remaining.length; i++) {
        final candidate = remaining[i];
        final score = (priorityById[candidate.id] ?? 0) -
            _topicPenalty(candidate, selected) +
            (intelligenceById[candidate.id]?.priority ?? 0) * .35;
        if (score > bestScore) {
          bestScore = score;
          bestIndex = i;
        }
      }
      final item = remaining.removeAt(bestIndex);
      const _topicCap = 2;
      if (_topicCount(selected, item.topic) >= _topicCap &&
          _hasTopicAlternative(remaining, selected)) continue;
      final decision = intelligenceById[item.id];
      final itemAttempts = attemptsByItem[item.id] ?? const <Attempt>[];
      final adaptiveMode = AdaptiveFocus.modeForRows(
        item.id,
        itemAttempts,
        reviewCard: state.reviewCards[item.id],
        now: at,
      );
      final selectedMode = decision?.recommendedMode ?? adaptiveMode;
      final hasHistory = itemAttempts.isNotEmpty;
      if (!hasHistory &&
          teacher.newContentReadiness < .5 &&
          selected.length >= teacherBudget) continue;
      final mastery = Mastery.forItemRows(
        item.id,
        itemAttempts,
        reviewCard: state.reviewCards[item.id],
        now: at,
      );
      final isWeak = item.skill == weak || hasHistory;
      final contentProfile = contentIntelligence.profile(item);
      final curriculumPenalty = !hasHistory &&
              teacher.newContentReadiness < .70 &&
              contentProfile.inferredLevel == ContentLevel.b1
          ? 30
          : 0;
      final productionTask =
          (selectedMode == 'production' || item.skill == 'production')
              ? ProductionEngine.buildFor(
                  item,
                  exerciseStrategy: exerciseStrategy,
                  isLearnable: contentQuality.isLearnable,
                )
              : null;
      final productionHint =
          productionTask == null ? '' : ' • ${productionTask.prompt}';
      add(
        item.id,
        hasHistory ? selectedMode : 'new',
        hasHistory
            ? '${decision?.reason ?? 'تدريب موجّه: ${mastery.nextAction}'} • المراجعة التالية خلال ${mastery.nextReviewDays} يوم.$productionHint'
            : (teacher.newContentReadiness < .75
                ? 'محتوى جديد بجرعة محسوبة حسب جاهزيتك.$productionHint'
                : 'اختيار ذكي من مفردات مناسبة لمسارك.$productionHint'),
        isWeak
            ? 70
            : ((30 + (teacher.newContentReadiness * 10).round()) -
                curriculumPenalty),
      );
    }
    selected = _interleave(selected);
    final reviewCount = selected.where((x) => x.mode == 'review').length;
    final repairCount = selected.where((x) => x.mode == 'repair').length;
    final newCount = selected.where((x) => x.mode == 'new').length;
    return LearningPath(
      items: selected,
      focusSkill: weak,
      reviewCount: reviewCount,
      repairCount: repairCount,
      newCount: newCount,
      listeningCount: _balancedCount(selected, 'listening'),
      productionCount: _balancedCount(selected, 'production'),
    );
  }

  static String _modeForMistake(MistakeCategory category) {
    switch (category) {
      case MistakeCategory.listening:
        return 'listening';
      case MistakeCategory.production:
      case MistakeCategory.writing:
        return 'production';
      case MistakeCategory.translation:
      case MistakeCategory.grammar:
      case MistakeCategory.wordOrder:
        return 'transfer';
      case MistakeCategory.article:
      case MistakeCategory.vocabulary:
        return 'recall';
    }
  }

  static int _itemPriority(
    LearningContent item,
    Map<String, List<Attempt>> attemptsByItem,
    String weak,
  ) {
    final a = attemptsByItem[item.id] ?? const <Attempt>[];
    final e = a.where((x) => !x.correct).length;
    return (item.skill == weak ? 80 : 0) +
        e * 8 +
        (a.isEmpty ? 25 : 0) +
        item.id.hashCode.abs() % 7;
  }

  static int _balancedCount(List<LearningPathItem> items, String mode) => items
      .where((x) => _sessionMode(x) == mode)
      .length
      .clamp(0, items.length)
      .toInt();
  static String _sessionMode(LearningPathItem item) {
    if (item.item.skill == 'listening') return 'listening';
    if (item.item.skill == 'production' || item.mode == 'consolidate')
      return 'production';
    if (item.item.skill == 'transfer') return 'production';
    return 'recall';
  }

  static List<LearningPathItem> _interleave(List<LearningPathItem> source) {
    if (source.length < 3) return source;
    final remaining = [...source];
    final output = <LearningPathItem>[];
    final usedModes = <String>{};
    final usedTopics = <String>{};
    while (remaining.isNotEmpty) {
      remaining.sort((a, b) => b.priority.compareTo(a.priority));
      var index = remaining.indexWhere(
        (x) =>
            !usedModes.contains(x.mode) && !usedTopics.contains(x.item.topic),
      );
      if (index < 0)
        index = remaining.indexWhere((x) => !usedTopics.contains(x.item.topic));
      if (index < 0)
        index = remaining.indexWhere((x) => !usedModes.contains(x.mode));
      if (index < 0) index = 0;
      final item = remaining.removeAt(index);
      output.add(item);
      usedModes.add(item.mode);
      usedTopics.add(item.item.topic);
    }
    return output;
  }

  static int _topicCount(List<LearningPathItem> selected, String topic) =>
      selected.where((x) => x.item.topic == topic).length;
  static bool _hasTopicAlternative(
    List<dynamic> remaining,
    List<LearningPathItem> selected,
  ) {
    final topics = {for (final x in selected) x.item.topic};
    return remaining.any((x) => !topics.contains(x.item.topic));
  }

  static int _topicPenalty(
    LearningContent item,
    List<LearningPathItem> selected,
  ) {
    final same = selected.where((x) => x.item.topic == item.topic).length;
    return same * 18;
  }
}
