import 'package:flutter/foundation.dart';

import '../domain/placement_agent_models.dart';
import '../domain/placement_agent_repository.dart';

final class _PlacementAnswerEvidence {
  const _PlacementAnswerEvidence({
    required this.question,
    required this.correct,
  });

  final PlacementQuestionItem question;
  final bool correct;
}

final class PlacementAgentNotifier extends ChangeNotifier {
  PlacementAgentNotifier(
    this._repository, {
    this.maxQuestions = 8,
  }) : assert(maxQuestions > 0);

  final PlacementAgentRepository _repository;
  final int maxQuestions;

  List<PlacementQuestionItem> _questions = const <PlacementQuestionItem>[];
  final List<_PlacementAnswerEvidence> _answers = <_PlacementAnswerEvidence>[];
  PlacementQuestionItem? _currentQuestion;
  PlacementAssessmentResult? _result;
  int _targetDifficulty = 3;
  bool _isBusy = false;

  PlacementQuestionItem? get currentQuestion => _currentQuestion;

  bool get isCompleted => _result != null;

  bool get isBusy => _isBusy;

  PlacementAssessmentResult? get result => _result;

  double get progress {
    if (isCompleted) return 1;
    final denominator =
        maxQuestions < _questions.length ? maxQuestions : _questions.length;
    if (denominator <= 0) return 0;
    return (_answers.length / denominator).clamp(0.0, 1.0).toDouble();
  }

  Future<void> resetAssessment() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      _questions = await _repository.getCalibratedQuestions();
      _answers.clear();
      _result = null;
      _targetDifficulty = 3;
      _currentQuestion = _selectNextQuestion();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(int selectedIndex) async {
    final question = _currentQuestion;
    if (_isBusy || question == null || isCompleted) return;
    if (selectedIndex < 0 || selectedIndex >= question.options.length) {
      throw RangeError.index(
        selectedIndex,
        question.options,
        'selectedIndex',
      );
    }

    _isBusy = true;
    notifyListeners();
    try {
      final correct = question.isCorrect(selectedIndex);
      _answers.add(
        _PlacementAnswerEvidence(question: question, correct: correct),
      );
      _targetDifficulty = correct
          ? (question.difficulty + 1).clamp(1, 5).toInt()
          : (question.difficulty - 1).clamp(1, 5).toInt();

      final hasReachedLimit = _answers.length >= maxQuestions;
      final nextQuestion = hasReachedLimit ? null : _selectNextQuestion();
      if (hasReachedLimit || nextQuestion == null) {
        _currentQuestion = null;
        _result = _buildResult();
        await _repository.saveAssessmentResult(_result!);
      } else {
        _currentQuestion = nextQuestion;
      }
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  PlacementQuestionItem? _selectNextQuestion() {
    final answeredIds = <String>{
      for (final answer in _answers) answer.question.id,
    };
    final repository = _repository;
    if (repository is AdaptivePlacementQuestionSource) {
      return (repository as AdaptivePlacementQuestionSource).selectNextQuestion(
        answeredIds: answeredIds,
        targetDifficulty: _targetDifficulty,
      );
    }

    final available = _questions
        .where((question) => !answeredIds.contains(question.id))
        .toList(growable: false);
    if (available.isEmpty) return null;
    available.sort((left, right) {
      final leftDistance = (left.difficulty - _targetDifficulty).abs();
      final rightDistance = (right.difficulty - _targetDifficulty).abs();
      final byDistance = leftDistance.compareTo(rightDistance);
      if (byDistance != 0) return byDistance;
      return left.id.compareTo(right.id);
    });
    return available.first;
  }

  PlacementAssessmentResult _buildResult() {
    if (_answers.isEmpty) {
      return PlacementAssessmentResult(
        inferredLevel: LanguageCefrSubLevel.a1_1,
        accuracy: 0,
        masteredSkills: const <String>[],
        skillsToStrengthen: const <String>[],
      );
    }

    final correctCount = _answers.where((answer) => answer.correct).length;
    final accuracy = correctCount / _answers.length;
    var weightedCorrect = 0;
    var weightedTotal = 0;
    final skillEvidence = <String, List<bool>>{};

    for (final answer in _answers) {
      final difficulty = answer.question.difficulty;
      weightedTotal += difficulty;
      if (answer.correct) weightedCorrect += difficulty;
      skillEvidence
          .putIfAbsent(answer.question.targetSkill, () => <bool>[])
          .add(answer.correct);
    }

    final weightedAccuracy =
        weightedTotal == 0 ? 0.0 : weightedCorrect / weightedTotal;
    final diagnosticScore = (accuracy * .70) + (weightedAccuracy * .30);
    final inferredLevel = switch (diagnosticScore) {
      >= .82 => LanguageCefrSubLevel.a2_2,
      >= .62 => LanguageCefrSubLevel.a2_1,
      >= .42 => LanguageCefrSubLevel.a1_2,
      _ => LanguageCefrSubLevel.a1_1,
    };

    final mastered = <String>[];
    final strengthen = <String>[];
    final skills = skillEvidence.keys.toList()..sort();
    for (final skill in skills) {
      final evidence = skillEvidence[skill]!;
      final correct = evidence.where((value) => value).length;
      final skillAccuracy = correct / evidence.length;
      if (skillAccuracy >= .70) {
        mastered.add(skill);
      } else {
        strengthen.add(skill);
      }
    }

    return PlacementAssessmentResult(
      inferredLevel: inferredLevel,
      accuracy: accuracy,
      masteredSkills: mastered,
      skillsToStrengthen: strengthen,
    );
  }
}
