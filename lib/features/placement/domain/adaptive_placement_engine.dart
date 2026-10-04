import 'dart:math' as math;

import 'placement_models.dart';

final class AdaptivePlacementEngine {
  const AdaptivePlacementEngine();

  static const int defaultMaxQuestions = 9;
  static const int minQuestionsBeforeEarlyStop = 5;

  AssessmentSession start({
    required String sessionId,
    DateTime? now,
    int maxQuestions = defaultMaxQuestions,
  }) {
    final boundedMax = maxQuestions.clamp(5, 15).toInt();
    return AssessmentSession(
      id: sessionId,
      startedAt: now ?? DateTime.now(),
      currentLevel: PlacementLevel.a2,
      abilityEstimate: 1.0,
      answers: const <PlacementAnswer>[],
      maxQuestions: boundedMax,
    );
  }

  AssessmentSession recordAnswer({
    required AssessmentSession session,
    required PlacementQuestion question,
    required String selectedOptionId,
  }) {
    if (session.completed) {
      throw StateError('Placement session is already complete.');
    }
    if (session.answeredQuestionIds.contains(question.id)) {
      throw StateError('Placement question has already been answered.');
    }

    final correct = question.isCorrect(selectedOptionId);
    final nextLevel = correct
        ? PlacementLevel.fromRank(question.level.rank + 1)
        : PlacementLevel.fromRank(question.level.rank - 1);
    final ability = _updatedAbility(
      current: session.abilityEstimate,
      difficulty: question.level.rank,
      correct: correct,
    );
    final answers = List<PlacementAnswer>.unmodifiable(
      <PlacementAnswer>[
        ...session.answers,
        PlacementAnswer(
          questionId: question.id,
          questionLevel: question.level,
          pattern: question.pattern,
          skillTag: question.skillTag,
          selectedOptionId: selectedOptionId,
          correct: correct,
          reviewItemId: question.reviewItemId,
        ),
      ],
    );

    final updated = session.copyWith(
      currentLevel: nextLevel,
      abilityEstimate: ability,
      answers: answers,
    );
    return shouldStop(updated)
        ? updated.copyWith(completed: true)
        : updated;
  }

  bool shouldStop(AssessmentSession session) {
    if (session.answers.length >= session.maxQuestions) return true;
    if (session.answers.length < minQuestionsBeforeEarlyStop) return false;

    final recent = session.answers.reversed.take(3).toList(growable: false);
    final unanimous = recent.every((answer) => answer.correct) ||
        recent.every((answer) => !answer.correct);
    final decisiveAbility =
        session.abilityEstimate <= .35 || session.abilityEstimate >= 2.65;
    return unanimous && decisiveAbility;
  }

  PlacementResult resultFor(AssessmentSession session) {
    if (session.answers.isEmpty) {
      throw StateError('Cannot score an empty placement session.');
    }

    final score =
        (session.abilityEstimate / 3 * 100).clamp(0.0, 100.0).toDouble();
    final level = _levelForScore(score);
    final correct = session.answers.where((answer) => answer.correct).length;
    final wrong = session.answers.where((answer) => !answer.correct).toList();
    final reviewItemIds = <String>[];
    for (final answer in wrong) {
      final id = answer.reviewItemId?.trim();
      if (id != null && id.isNotEmpty && !reviewItemIds.contains(id)) {
        reviewItemIds.add(id);
      }
    }

    return PlacementResult(
      level: level,
      proficiencyScore: score,
      confidence: _confidence(session),
      answeredCount: session.answers.length,
      correctCount: correct,
      recommendations: _recommendations(wrong, level),
      reviewItemIds: List<String>.unmodifiable(reviewItemIds.take(20)),
      initialReviewIntervalDays: switch (level) {
        PlacementLevel.a1 => 1,
        PlacementLevel.a2 => 2,
        PlacementLevel.b1 => 3,
        PlacementLevel.b2 => 4,
      },
      initialSrsDifficulty: switch (level) {
        PlacementLevel.a1 => 1.70,
        PlacementLevel.a2 => 1.40,
        PlacementLevel.b1 => 1.15,
        PlacementLevel.b2 => 1.0,
      },
    );
  }

  double _updatedAbility({
    required double current,
    required int difficulty,
    required bool correct,
  }) {
    final target = correct
        ? math.min(3.0, difficulty + .65)
        : math.max(0.0, difficulty - .65);
    return (current * .55 + target * .45).clamp(0.0, 3.0).toDouble();
  }

  PlacementLevel _levelForScore(double score) {
    if (score < 30) return PlacementLevel.a1;
    if (score < 55) return PlacementLevel.a2;
    if (score < 80) return PlacementLevel.b1;
    return PlacementLevel.b2;
  }

  double _confidence(AssessmentSession session) {
    final sample =
        (session.answers.length / session.maxQuestions).clamp(0.0, 1.0);
    final decisive = session.abilityEstimate <= .35 ||
        session.abilityEstimate >= 2.65;
    final evidenceBoost = session.answers.length >= minQuestionsBeforeEarlyStop
        ? (decisive ? .25 : .12)
        : 0.0;
    return (.55 + sample * .33 + evidenceBoost)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  List<String> _recommendations(
    List<PlacementAnswer> wrong,
    PlacementLevel level,
  ) {
    final counts = <String, int>{};
    for (final answer in wrong) {
      counts[answer.skillTag] = (counts[answer.skillTag] ?? 0) + 1;
    }
    final ranked = counts.entries.toList()
      ..sort((left, right) {
        final byCount = right.value.compareTo(left.value);
        if (byCount != 0) return byCount;
        return left.key.compareTo(right.key);
      });

    final recommendations = <String>[
      switch (level) {
        PlacementLevel.a1 =>
          'ابدأ بتثبيت مفردات A1 والجمل اليومية القصيرة قبل رفع الحمل.',
        PlacementLevel.a2 =>
          'ابدأ من A2 مع مراجعة انتقائية لثغرات A1 التي ظهرت في الاختبار.',
        PlacementLevel.b1 =>
          'ابدأ من B1 مع مراجعات قصيرة للمهارات التي أخطأت فيها فقط.',
        PlacementLevel.b2 =>
          'ابدأ من B2 مع مراجعة مركزة فقط للثغرات التي كشفها الاختبار.',
      },
    ];
    for (final entry in ranked.take(2)) {
      recommendations.add(_recommendationForSkill(entry.key));
    }
    return List<String>.unmodifiable(recommendations);
  }

  String _recommendationForSkill(String skill) => switch (skill) {
        'grammar' => 'أعطِ أولوية لتمارين القواعد وبناء الجملة.',
        'listening' => 'زد جرعة الاستماع القصير وإعادة الاستماع الموجّه.',
        'translation' => 'راجع الربط المباشر بين المعنى العربي والتعبير الألماني.',
        'vocabulary' => 'ثبّت المفردات عالية التكرار قبل إضافة كلمات جديدة.',
        _ => 'راجع الأسئلة التي أخطأت فيها ضمن جلسات قصيرة متكررة.',
      };
}
