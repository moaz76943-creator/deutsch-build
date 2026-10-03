import 'package:flutter/foundation.dart';

import '../domain/preposition_case_rules.dart';
import '../domain/preposition_models.dart';
import '../domain/prepositions_repository.dart';

enum PrepositionArenaStatus { idle, active, completed }

final class PrepositionArenaState {
  const PrepositionArenaState({
    this.status = PrepositionArenaStatus.idle,
    this.challenges = const <PrepositionChallenge>[],
    this.currentIndex = 0,
    this.correctCount = 0,
    this.answeredCount = 0,
    this.selectedType,
    this.selectedLevel,
    this.lastResult,
  });

  final PrepositionArenaStatus status;
  final List<PrepositionChallenge> challenges;
  final int currentIndex;
  final int correctCount;
  final int answeredCount;
  final PrepositionType? selectedType;
  final String? selectedLevel;
  final PrepositionAnswerResult? lastResult;

  PrepositionChallenge? get currentChallenge {
    if (status != PrepositionArenaStatus.active ||
        currentIndex < 0 ||
        currentIndex >= challenges.length) {
      return null;
    }
    return challenges[currentIndex];
  }

  bool get hasAnsweredCurrent => lastResult != null;

  bool get isCompleted => status == PrepositionArenaStatus.completed;

  double get accuracy =>
      answeredCount == 0 ? 0 : correctCount / answeredCount;

  PrepositionArenaState copyWith({
    PrepositionArenaStatus? status,
    List<PrepositionChallenge>? challenges,
    int? currentIndex,
    int? correctCount,
    int? answeredCount,
    PrepositionType? selectedType,
    String? selectedLevel,
    bool clearSelectedType = false,
    PrepositionAnswerResult? lastResult,
    bool clearLastResult = false,
  }) {
    return PrepositionArenaState(
      status: status ?? this.status,
      challenges: challenges ?? this.challenges,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      answeredCount: answeredCount ?? this.answeredCount,
      selectedType: clearSelectedType
          ? null
          : selectedType ?? this.selectedType,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      lastResult: clearLastResult ? null : lastResult ?? this.lastResult,
    );
  }
}

final class PrepositionArenaNotifier extends ChangeNotifier {
  PrepositionArenaNotifier({
    required PrepositionsRepository repository,
    PrepositionCaseRules rules = const PrepositionCaseRules(),
  })  : _repository = repository,
        _rules = rules;

  final PrepositionsRepository _repository;
  final PrepositionCaseRules _rules;

  PrepositionArenaState _state = const PrepositionArenaState();

  PrepositionArenaState get state => _state;

  void start({
    PrepositionType? type,
    String? level,
    int limit = 10,
  }) {
    final safeLimit = limit.clamp(1, 20).toInt();
    final source = _repository.challenges(type: type, level: level);
    final challenges = source.take(safeLimit).toList(growable: false);

    _state = PrepositionArenaState(
      status: challenges.isEmpty
          ? PrepositionArenaStatus.completed
          : PrepositionArenaStatus.active,
      challenges: List<PrepositionChallenge>.unmodifiable(challenges),
      selectedType: type,
      selectedLevel: level?.trim().toUpperCase(),
    );
    notifyListeners();
  }

  String expectedAnswerForCurrent() {
    final challenge = _state.currentChallenge;
    if (challenge == null) {
      throw StateError('No active preposition challenge.');
    }
    return _expectedFor(challenge).answer;
  }

  PrepositionAnswerResult submit(String rawAnswer) {
    final challenge = _state.currentChallenge;
    if (challenge == null) {
      throw StateError('No active preposition challenge.');
    }
    if (_state.hasAnsweredCurrent) {
      throw StateError('Current challenge has already been scored.');
    }

    final expected = _expectedFor(challenge);
    final selected = rawAnswer.trim();
    final isCorrect =
        selected.toLowerCase() == expected.answer.toLowerCase();
    final result = PrepositionAnswerResult(
      isCorrect: isCorrect,
      selectedAnswer: selected,
      expectedAnswer: expected.answer,
      explanationAr: challenge.explanationAr,
      grammaticalCase: expected.grammaticalCase,
      articleForm: expected.articleForm,
    );

    _state = _state.copyWith(
      correctCount: _state.correctCount + (isCorrect ? 1 : 0),
      answeredCount: _state.answeredCount + 1,
      lastResult: result,
    );
    notifyListeners();
    return result;
  }

  void next() {
    if (_state.status != PrepositionArenaStatus.active) return;
    if (!_state.hasAnsweredCurrent) {
      throw StateError('Answer the current challenge before continuing.');
    }

    final nextIndex = _state.currentIndex + 1;
    if (nextIndex >= _state.challenges.length) {
      _state = _state.copyWith(
        status: PrepositionArenaStatus.completed,
        clearLastResult: true,
      );
    } else {
      _state = _state.copyWith(
        currentIndex: nextIndex,
        clearLastResult: true,
      );
    }
    notifyListeners();
  }

  void restart() {
    start(
      type: _state.selectedType,
      level: _state.selectedLevel,
      limit: _state.challenges.length,
    );
  }

  _ExpectedAnswer _expectedFor(PrepositionChallenge challenge) {
    final preposition = _repository.byId(challenge.prepositionId);
    if (preposition == null) {
      throw StateError(
        'Unknown preposition id: ${challenge.prepositionId}',
      );
    }
    final grammaticalCase = _rules.caseFor(
      preposition: preposition,
      spatialQuestion: challenge.spatialQuestion,
    );

    if (challenge.kind == PrepositionChallengeKind.prepositionChoice) {
      final answer = challenge.correctPreposition?.trim();
      if (answer == null || answer.isEmpty) {
        throw StateError('Missing correct preposition answer.');
      }
      return _ExpectedAnswer(
        answer: answer,
        grammaticalCase: grammaticalCase,
      );
    }

    final baseArticle = challenge.baseArticle;
    if (baseArticle == null) {
      throw StateError('Missing base article for article challenge.');
    }
    final form = _rules.articleForm(
      baseArticle: baseArticle,
      grammaticalCase: grammaticalCase,
    );
    return _ExpectedAnswer(
      answer: form.surfaceArticle,
      grammaticalCase: grammaticalCase,
      articleForm: form,
    );
  }
}

final class _ExpectedAnswer {
  const _ExpectedAnswer({
    required this.answer,
    required this.grammaticalCase,
    this.articleForm,
  });

  final String answer;
  final GermanGrammaticalCase grammaticalCase;
  final GermanArticleCaseForm? articleForm;
}
