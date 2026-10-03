import '../core/content_contract.dart';
import '../language/language_exercise_strategy.dart';
import '../models/assessment.dart';
import '../models/learner.dart';

class AssessmentEngine {
  static const skills = ['recall', 'listening', 'production', 'transfer'];

  static List<AssessmentQuestion> build<T extends LearningContent>(
    List<T> items,
    LearnerState state, {
    required LanguageExerciseStrategy exerciseStrategy,
    DateTime? now,
    int questionCount = 10,
    int seed = 0,
    required bool Function(T item) isLearnable,
  }) {
    final eligible = items.where(isLearnable).toList();
    if (eligible.isEmpty || questionCount <= 0) return const [];
    final weak = _weakSkill(state);
    final ranked = [...eligible]..sort((a, b) {
        final sa = _priority(a, state, weak, seed);
        final sb = _priority(b, state, weak, seed);
        return sb.compareTo(sa);
      });
    final selected = <T>[];
    final seen = <String>{};
    for (final item in ranked) {
      if (seen.add(item.id)) selected.add(item);
      if (selected.length >= questionCount.clamp(1, 20)) break;
    }
    return List.generate(
      selected.length,
      (i) => exerciseStrategy.assessmentQuestion(selected[i], i, seed),
    );
  }

  static AssessmentResult score<T extends LearningContent>(
    List<AssessmentResponse> responses,
    List<T> items, {
    DateTime? now,
    String? id,
    required LanguageExerciseStrategy exerciseStrategy,
  }) {
    final at = now ?? DateTime.now();
    final valid = responses
        .take(50)
        .where((r) => _findItem(items, r.itemId) != null)
        .toList();
    final scores = <String, List<double>>{};
    var correct = 0, clean = 0;
    final next = <String>[];
    for (final response in valid) {
      final item = _findItem(items, response.itemId);
      if (item == null) continue;
      final ok = response.correct;
      final value = !ok ? 0.0 : (response.hinted ? .7 : 1.0);
      final skill = _skillForQuestionId(
        item,
        response.questionId,
        exerciseStrategy,
      );
      scores.putIfAbsent(skill, () => []).add(value);
      if (ok) {
        correct++;
        if (!response.hinted) clean++;
      } else {
        next.add(item.id);
      }
    }
    final skillScores = <String, double>{
      for (final e in scores.entries)
        e.key: e.value.reduce((a, b) => a + b) / e.value.length,
    };
    final weak = skillScores.entries
        .where((e) => e.value < .7)
        .map((e) => e.key)
        .toList()
      ..sort(
        (a, b) => (skillScores[a] ?? 0).compareTo(skillScores[b] ?? 0),
      );
    final score = valid.isEmpty
        ? 0.0
        : ((valid.fold<double>(0, (sum, r) {
                  final item = _findItem(items, r.itemId);
                  return sum +
                      (item == null || !r.correct ? 0 : (r.hinted ? .7 : 1));
                }) /
                valid.length *
                100)
            .clamp(0, 100));
    return AssessmentResult(
      id: id ?? 't_${at.microsecondsSinceEpoch}',
      at: at,
      answered: valid.length,
      correct: correct,
      cleanCorrect: clean,
      score: score.toDouble(),
      skillScores: skillScores,
      weakSkills: weak,
      nextReviewItemIds: next.toSet().take(20).toList(),
    );
  }

  static T? _findItem<T extends LearningContent>(List<T> items, String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static AssessmentQuestion questionFor<T extends LearningContent>(
    T item,
    String questionId,
    LanguageExerciseStrategy exerciseStrategy,
  ) {
    for (var i = 0; i < AssessmentQuestionType.values.length; i++) {
      final q = exerciseStrategy.assessmentQuestion(item, i, 0);
      if (q.id == questionId) return q;
    }
    return exerciseStrategy.assessmentQuestion(item, 0, 0);
  }

  static String _skillForQuestionId<T extends LearningContent>(
    T item,
    String questionId,
    LanguageExerciseStrategy exerciseStrategy,
  ) =>
      questionFor(item, questionId, exerciseStrategy).skill;

  static double _priority(
    LearningContent x,
    LearnerState s,
    String weak,
    int seed,
  ) {
    final attempts = s.attempts.where((a) => a.itemId == x.id).toList();
    final errors = attempts.where((a) => !a.correct).length;
    final weakBoost = x.skill == weak ? 100 : 0;
    final unseen = attempts.isEmpty ? 30 : 0;
    return (weakBoost + errors * 15 + unseen + ((seed + x.id.hashCode) & 7))
        .toDouble();
  }

  static String _weakSkill(LearnerState s) {
    final keys = <String>{...skills, ...s.attempts.map((x) => x.skill)};
    final values = <String, double>{};
    for (final k in keys) {
      final a = s.attempts.where((x) => x.skill == k).toList();
      final recent = a.reversed.take(10).toList();
      if (recent.isNotEmpty) {
        final recentCorrect = recent.where((x) => x.correct).length;
        values[k] = recentCorrect / recent.length;
      }
    }
    if (values.isEmpty) return 'recall';
    return values.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
  }
}
