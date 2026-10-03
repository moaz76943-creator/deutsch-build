import 'package:flutter/foundation.dart';

import '../domain/placement_models.dart';
import '../domain/placement_repository.dart';

final class PlacementNotifier extends ChangeNotifier {
  PlacementNotifier(
    this._repository, {
    this.maxQuestions = 8,
  }) : assert(maxQuestions > 0);

  final PlacementRepository _repository;
  final int maxQuestions;

  final List<PlacementAnswerRecord> _answers =
      <PlacementAnswerRecord>[];
  PlacementQuestionItem? _currentQuestion;
  PlacementResult? _result;
  CefrLevel _targetLevel = CefrLevel.a2;
  double _targetDifficulty = 1.0;
  bool _isBusy = false;

  PlacementQuestionItem? get currentQuestion => _currentQuestion;

  List<PlacementAnswerRecord> get answers =>
      List<PlacementAnswerRecord>.unmodifiable(_answers);

  PlacementResult? get result => _result;

  bool get isBusy => _isBusy;

  bool get isCompleted => _result != null;

  CefrLevel get currentEstimatedLevel =>
      _result?.finalLevel ?? _estimateLevel(_answers);

  double get progress {
    if (isCompleted) return 1;
    return (_answers.length / maxQuestions)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  Future<void> restartAssessment() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      _answers.clear();
      _result = null;
      _targetLevel = CefrLevel.a2;
      _targetDifficulty = 1.0;
      _currentQuestion = await _repository.nextAdaptiveQuestion(
        targetLevel: _targetLevel,
        targetDifficulty: _targetDifficulty,
        excludeIds: const <String>{},
        skillAttempts: const <AssessmentSkillCategory, int>{},
      );
      if (_currentQuestion == null) {
        _result = calculateFinalLevel();
      }
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(int optionIndex) async {
    final question = _currentQuestion;
    if (question == null || _isBusy || isCompleted) return;
    if (optionIndex < 0 || optionIndex >= question.options.length) {
      throw RangeError.index(
        optionIndex,
        question.options,
        'optionIndex',
      );
    }

    _isBusy = true;
    notifyListeners();
    try {
      final correct = question.isCorrect(optionIndex);
      _answers.add(
        PlacementAnswerRecord(
          questionId: question.id,
          level: question.targetLevel,
          skill: question.skill,
          difficultyWeight: question.difficultyWeight,
          isCorrect: correct,
        ),
      );

      _targetLevel = _nextTargetLevel(
        question.targetLevel,
        correct,
      );
      _targetDifficulty = _nextDifficulty(
        question.difficultyWeight,
        correct,
      );

      if (_answers.length >= maxQuestions) {
        _currentQuestion = null;
        _result = calculateFinalLevel();
        return;
      }

      final next = await _repository.nextAdaptiveQuestion(
        targetLevel: _targetLevel,
        targetDifficulty: _targetDifficulty,
        excludeIds: _answeredIds(_answers),
        skillAttempts: _skillAttemptCounts(_answers),
      );
      if (next == null) {
        _currentQuestion = null;
        _result = calculateFinalLevel();
        return;
      }
      _currentQuestion = next;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  PlacementResult calculateFinalLevel() =>
      _repository.calculateStandardizedResult(
        List<PlacementAnswerRecord>.unmodifiable(_answers),
      );

  static CefrLevel _nextTargetLevel(
    CefrLevel answeredLevel,
    bool correct,
  ) {
    final delta = correct ? 1 : -1;
    return CefrLevelMetadata.fromRank(answeredLevel.rank + delta);
  }

  static double _nextDifficulty(
    double answeredDifficulty,
    bool correct,
  ) {
    final delta = correct ? .15 : -.15;
    return (answeredDifficulty + delta)
        .clamp(.55, 1.70)
        .toDouble();
  }

  static Set<String> _answeredIds(
    List<PlacementAnswerRecord> answers,
  ) =>
      <String>{
        for (final answer in answers) answer.questionId,
      };

  static Map<AssessmentSkillCategory, int> _skillAttemptCounts(
    List<PlacementAnswerRecord> answers,
  ) {
    final counts = <AssessmentSkillCategory, int>{};
    for (final answer in answers) {
      counts[answer.skill] = (counts[answer.skill] ?? 0) + 1;
    }
    return counts;
  }

  static CefrLevel _estimateLevel(
    List<PlacementAnswerRecord> answers,
  ) {
    if (answers.isEmpty) return CefrLevel.a2;
    final score = _standardizedScore(answers);
    if (score >= 87.5) return CefrLevel.b2;
    if (score >= 62.5) return CefrLevel.b1;
    if (score >= 37.5) return CefrLevel.a2;
    return CefrLevel.a1;
  }

  static double _standardizedScore(
    List<PlacementAnswerRecord> answers,
  ) {
    var weightedEvidence = 0.0;
    var totalWeight = 0.0;
    for (final answer in answers) {
      final weight =
          answer.difficultyWeight.clamp(.1, 3.0).toDouble();
      final boundaryEvidence =
          (answer.level.rank + (answer.isCorrect ? 1 : 0)) / 4;
      weightedEvidence += boundaryEvidence * weight;
      totalWeight += weight;
    }
    if (totalWeight == 0) return 0;
    return (weightedEvidence / totalWeight * 100)
        .clamp(0.0, 100.0)
        .toDouble();
  }
}
