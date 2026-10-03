import 'dart:math' as math;

import '../core/content_contract.dart';
import '../core/srs_facets.dart';
import '../language/language_exercise_strategy.dart';
import '../models/assessment.dart';
import '../models/diagnostic_placement.dart';
import '../models/learner.dart';

final class AdaptivePlacementEngine {
  const AdaptivePlacementEngine._();

  static const int defaultMaxQuestions = 10;
  static const int minQuestionsBeforeAdaptiveStop = 7;
  static const List<DiagnosticDimension> _dimensionOrder =
      <DiagnosticDimension>[
    DiagnosticDimension.meaning,
    DiagnosticDimension.grammar,
    DiagnosticDimension.transfer,
    DiagnosticDimension.listening,
  ];

  static DiagnosticQuestion? nextQuestion<T extends LearningContent>({
    required List<T> items,
    required LearnerState state,
    required List<DiagnosticResponse> responses,
    required LanguageExerciseStrategy exerciseStrategy,
    required bool Function(T item) isLearnable,
    int seed = 0,
    int maxQuestions = defaultMaxQuestions,
  }) {
    final boundedMax = maxQuestions.clamp(1, 20).toInt();
    if (shouldStop(responses, maxQuestions: boundedMax)) return null;

    final usedIds = <String>{for (final response in responses) response.itemId};
    final eligible = items
        .where(isLearnable)
        .where(
          (item) =>
              item.id.trim().isNotEmpty &&
              item.sourceText.trim().isNotEmpty &&
              item.translationText.trim().isNotEmpty &&
              !usedIds.contains(item.id),
        )
        .toList(growable: false);
    if (eligible.isEmpty) return null;

    final dimension = _targetDimension(responses, state);
    final difficulty = _targetDifficulty(responses);
    final priorAttempts = <String, int>{};
    for (final attempt in state.meaningAttempts) {
      priorAttempts[attempt.itemId] = (priorAttempts[attempt.itemId] ?? 0) + 1;
    }

    T? selected;
    AssessmentQuestion? selectedQuestion;
    var selectedScore = 1 << 30;
    for (final item in eligible) {
      final question = _questionForDimension(
        item,
        dimension,
        exerciseStrategy,
        seed,
      );
      if (question == null) continue;
      final complexityDistance =
          (_contentComplexity(item) - difficulty).abs() * 100;
      final priorPenalty =
          (priorAttempts[item.id] ?? 0).clamp(0, 20).toInt() * 7;
      final tie = _stableHash('$seed|${item.id}|${dimension.wireName}') % 29;
      final dimensionPenalty = dimension == DiagnosticDimension.grammar &&
              item.grammaticalMarker.trim().isEmpty
          ? 400
          : 0;
      final score = complexityDistance + priorPenalty + dimensionPenalty + tie;
      if (selected == null || score < selectedScore) {
        selected = item;
        selectedQuestion = question;
        selectedScore = score;
      }
    }
    if (selected == null || selectedQuestion == null) return null;

    return DiagnosticQuestion(
      question: selectedQuestion,
      dimension: dimension,
      difficultyBand: difficulty,
    );
  }

  static bool shouldStop(
    List<DiagnosticResponse> responses, {
    int maxQuestions = defaultMaxQuestions,
  }) {
    final boundedMax = maxQuestions.clamp(1, 20).toInt();
    if (responses.length >= boundedMax) return true;
    final scored = responses.where((response) => !response.skipped).toList();
    if (scored.length < minQuestionsBeforeAdaptiveStop) return false;

    final unavailable = <DiagnosticDimension>{
      for (final response in responses)
        if (response.skipped) response.dimension,
    };
    final available = _dimensionOrder
        .where((dimension) => !unavailable.contains(dimension))
        .toSet();
    final measured = <DiagnosticDimension>{
      for (final response in scored) response.dimension,
    };
    return available.isNotEmpty && measured.containsAll(available);
  }

  static PlacementDiagnosticResult score(
    List<DiagnosticResponse> responses, {
    int maxQuestions = defaultMaxQuestions,
  }) {
    final boundedMax = maxQuestions.clamp(1, 20).toInt();
    final bounded = responses.take(boundedMax).toList();
    final scored = bounded.where((response) => !response.skipped).toList();
    final buckets = <DiagnosticDimension, List<double>>{};
    var cleanCorrect = 0;
    var evidence = 0.0;
    final reviewIds = <String>[];

    for (final response in scored) {
      final value = response.evidenceValue;
      evidence += value;
      (buckets[response.dimension] ??= <double>[]).add(value);
      if (response.correct && !response.hinted) cleanCorrect++;
      if (!response.correct && !reviewIds.contains(response.itemId)) {
        reviewIds.add(response.itemId);
      }
    }

    final dimensionScores = <DiagnosticDimension, double>{
      for (final entry in buckets.entries)
        entry.key: entry.value.reduce((a, b) => a + b) / entry.value.length,
    };
    final score = scored.isEmpty
        ? 0.0
        : (evidence / scored.length * 100).clamp(0.0, 100.0).toDouble();
    final weak = dimensionScores.entries
        .where((entry) => entry.value < .65)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final skippedDimensions = <DiagnosticDimension>{
      for (final response in bounded)
        if (response.skipped) response.dimension,
    };
    final availableCount = math.max(
      1,
      _dimensionOrder.length - skippedDimensions.length,
    );
    final coverage =
        (dimensionScores.length / availableCount).clamp(0.0, 1.0).toDouble();
    final sample = (scored.length / boundedMax).clamp(0.0, 1.0).toDouble();
    final confidence = (coverage * sample).clamp(0.0, 1.0).toDouble();

    return PlacementDiagnosticResult(
      answered: bounded.length,
      scoredAnswers: scored.length,
      cleanCorrect: cleanCorrect,
      score: score,
      confidence: confidence,
      band: _bandFor(score),
      dimensionScores: Map<DiagnosticDimension, double>.unmodifiable(
        dimensionScores,
      ),
      weakDimensions: weak.map((entry) => entry.key).toList(growable: false),
      reviewItemIds: List<String>.unmodifiable(reviewIds.take(20)),
    );
  }

  static DiagnosticDimension _targetDimension(
    List<DiagnosticResponse> responses,
    LearnerState state,
  ) {
    final skipped = <DiagnosticDimension>{
      for (final response in responses)
        if (response.skipped) response.dimension,
    };
    final scored = responses.where((response) => !response.skipped).toList();
    if (scored.isEmpty) {
      final prior = _priorWeakDimension(state);
      if (prior != null && !skipped.contains(prior)) return prior;
    }
    if (scored.isNotEmpty) {
      final last = scored.last;
      final sameDimensionCount = scored
          .where((response) => response.dimension == last.dimension)
          .length;
      if (!last.correct &&
          sameDimensionCount < 2 &&
          !skipped.contains(last.dimension)) {
        return last.dimension;
      }
    }

    DiagnosticDimension? selected;
    var lowest = 1 << 30;
    for (final dimension in _dimensionOrder) {
      if (skipped.contains(dimension)) continue;
      final count =
          scored.where((response) => response.dimension == dimension).length;
      if (selected == null || count < lowest) {
        selected = dimension;
        lowest = count;
      }
    }
    return selected ?? DiagnosticDimension.meaning;
  }

  static int _targetDifficulty(List<DiagnosticResponse> responses) {
    final scored = responses.where((response) => !response.skipped).toList();
    if (scored.isEmpty) return 1;
    final last = scored.last;
    if (!last.correct) {
      return math.max(0, last.difficultyBand - 1).toInt();
    }
    if (last.hinted) return last.difficultyBand.clamp(0, 3).toInt();
    return math.min(3, last.difficultyBand + 1).toInt();
  }

  static int _contentComplexity(LearningContent item) {
    var score = 0;
    if (item.grammaticalMarker.trim().isNotEmpty) score++;
    if (item.exampleText.trim().split(RegExp(r'\s+')).length >= 6) score++;
    if (item.acceptedForms.length > 1) score++;
    return score.clamp(0, 3).toInt();
  }

  static DiagnosticDimension? _priorWeakDimension(LearnerState state) {
    final pressure = <DiagnosticDimension, int>{};
    for (final card in state.reviewCards.values) {
      final dimension = _dimensionForFacet(card.facetType);
      if (dimension == null) continue;
      final value = card.failures * 2 + card.lapses;
      if (value <= 0) continue;
      pressure[dimension] = (pressure[dimension] ?? 0) + value;
    }
    if (pressure.isEmpty) return null;

    DiagnosticDimension? selected;
    var highest = -1;
    for (final dimension in _dimensionOrder) {
      final value = pressure[dimension] ?? 0;
      if (value > highest) {
        selected = dimension;
        highest = value;
      }
    }
    return selected;
  }

  static DiagnosticDimension? _dimensionForFacet(ReviewFacetType facet) {
    switch (facet) {
      case ReviewFacetType.meaningRecall:
      case ReviewFacetType.spelling:
        return DiagnosticDimension.meaning;
      case ReviewFacetType.gender:
      case ReviewFacetType.plural:
      case ReviewFacetType.caseForm:
      case ReviewFacetType.verbValency:
      case ReviewFacetType.prepositionCase:
      case ReviewFacetType.separablePrefix:
      case ReviewFacetType.auxiliary:
        return DiagnosticDimension.grammar;
      case ReviewFacetType.listening:
      case ReviewFacetType.pronunciation:
        return DiagnosticDimension.listening;
      case ReviewFacetType.collocation:
      case ReviewFacetType.production:
        return DiagnosticDimension.production;
      case ReviewFacetType.unknown:
        return null;
    }
  }

  static AssessmentQuestion? _questionForDimension<T extends LearningContent>(
    T item,
    DiagnosticDimension dimension,
    LanguageExerciseStrategy strategy,
    int seed,
  ) {
    final desired = switch (dimension) {
      DiagnosticDimension.meaning => AssessmentQuestionType.recall,
      DiagnosticDimension.grammar => AssessmentQuestionType.grammar,
      DiagnosticDimension.listening => AssessmentQuestionType.listening,
      DiagnosticDimension.transfer => AssessmentQuestionType.translation,
      DiagnosticDimension.production => AssessmentQuestionType.production,
    };
    for (var index = 0; index < AssessmentQuestionType.values.length; index++) {
      final question = strategy.assessmentQuestion(item, index, seed);
      if (question.type != desired) continue;
      if (dimension == DiagnosticDimension.meaning) return question;
      return AssessmentQuestion(
        id: question.id,
        itemId: question.itemId,
        prompt: question.prompt,
        expected: question.expected,
        type: question.type,
        accepted: const <String>[],
        skill: question.skill,
      );
    }
    return null;
  }

  static DiagnosticPlacementBand _bandFor(double score) {
    if (score < 35) return DiagnosticPlacementBand.foundation;
    if (score < 55) return DiagnosticPlacementBand.basic;
    if (score < 75) return DiagnosticPlacementBand.developing;
    return DiagnosticPlacementBand.strong;
  }

  static int _stableHash(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}
