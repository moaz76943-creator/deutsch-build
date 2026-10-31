import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/explain_why/deterministic_explain_why_engine.dart';
import '../../../core/explainer/explainer_models.dart';
import '../domain/grammar_drill_evaluator.dart';
import '../domain/grammar_drill_models.dart';
import '../../error_pattern_agent/domain/error_diagnostic_repository.dart';
import '../../error_pattern_agent/domain/error_pattern_models.dart';

final class GrammarDrillState {
  final List<GrammarDrill> exercises;
  final int currentIndex;
  final List<String> orderedTokenIds;
  final String selectedAnswer;
  final int points;
  final int attempts;
  final int correctCount;
  final int positiveStreak;
  final String feedbackAr;
  final String? feedbackReasonCode;
  final bool isAnswered;
  final bool lastAnswerCorrect;
  final bool completed;

  const GrammarDrillState({
    required this.exercises,
    required this.currentIndex,
    required this.orderedTokenIds,
    required this.selectedAnswer,
    required this.points,
    required this.attempts,
    required this.correctCount,
    required this.positiveStreak,
    required this.feedbackAr,
    required this.feedbackReasonCode,
    required this.isAnswered,
    required this.lastAnswerCorrect,
    required this.completed,
  });

  factory GrammarDrillState.initial(List<GrammarDrill> exercises) =>
      GrammarDrillState(
        exercises: List<GrammarDrill>.unmodifiable(exercises),
        currentIndex: 0,
        orderedTokenIds: const <String>[],
        selectedAnswer: '',
        points: 0,
        attempts: 0,
        correctCount: 0,
        positiveStreak: 0,
        feedbackAr: '',
        feedbackReasonCode: null,
        isAnswered: false,
        lastAnswerCorrect: false,
        completed: false,
      );

  GrammarDrill get currentExercise => exercises[currentIndex];

  double get accuracy => attempts == 0 ? 0 : correctCount / attempts;

  GrammarDrillState copyWith({
    int? currentIndex,
    List<String>? orderedTokenIds,
    String? selectedAnswer,
    int? points,
    int? attempts,
    int? correctCount,
    int? positiveStreak,
    String? feedbackAr,
    String? feedbackReasonCode,
    bool clearFeedbackReasonCode = false,
    bool? isAnswered,
    bool? lastAnswerCorrect,
    bool? completed,
  }) =>
      GrammarDrillState(
        exercises: exercises,
        currentIndex: currentIndex ?? this.currentIndex,
        orderedTokenIds: orderedTokenIds ?? this.orderedTokenIds,
        selectedAnswer: selectedAnswer ?? this.selectedAnswer,
        points: points ?? this.points,
        attempts: attempts ?? this.attempts,
        correctCount: correctCount ?? this.correctCount,
        positiveStreak: positiveStreak ?? this.positiveStreak,
        feedbackAr: feedbackAr ?? this.feedbackAr,
        feedbackReasonCode: clearFeedbackReasonCode
            ? null
            : (feedbackReasonCode ?? this.feedbackReasonCode),
        isAnswered: isAnswered ?? this.isAnswered,
        lastAnswerCorrect:
            lastAnswerCorrect ?? this.lastAnswerCorrect,
        completed: completed ?? this.completed,
      );
}

final class GrammarDrillNotifier extends ChangeNotifier {
  final GrammarDrillEvaluator evaluator;
  final ExplainWhyEngine explainWhyEngine;
  final ErrorDiagnosticSink errorDiagnosticSink;
  late GrammarDrillState _state;

  GrammarDrillNotifier(
    List<GrammarDrill> exercises, {
    required this.explainWhyEngine,
    this.evaluator = const GrammarDrillEvaluator(),
    this.errorDiagnosticSink = const NoopErrorDiagnosticSink(),
  }) {
    if (exercises.isEmpty) {
      throw ArgumentError.value(exercises, 'exercises', 'must not be empty');
    }
    _state = GrammarDrillState.initial(exercises);
  }

  GrammarDrillState get state => _state;

  void addSentenceToken(String tokenId) {
    if (_state.isAnswered || _state.completed) return;
    final exercise = _state.currentExercise;
    if (exercise is! SentenceReorderExercise) return;
    if (!exercise.tokens.any((token) => token.id == tokenId)) return;
    if (_state.orderedTokenIds.contains(tokenId)) return;
    _update(
      _state.copyWith(
        orderedTokenIds: List<String>.unmodifiable(
          <String>[..._state.orderedTokenIds, tokenId],
        ),
      ),
    );
  }

  void removeSentenceToken(String tokenId) {
    if (_state.isAnswered || _state.completed) return;
    _update(
      _state.copyWith(
        orderedTokenIds: List<String>.unmodifiable(
          _state.orderedTokenIds.where((id) => id != tokenId),
        ),
      ),
    );
  }

  void setAnswer(String answer) {
    if (_state.isAnswered || _state.completed) return;
    _update(_state.copyWith(selectedAnswer: answer));
  }

  void checkAnswer() {
    if (_state.isAnswered || _state.completed) return;
    final current = _state.currentExercise;
    final Object answer = current is SentenceReorderExercise
        ? _state.orderedTokenIds
        : _state.selectedAnswer;
    final evaluation = evaluator.evaluate(current, answer);
    final explanation = explainWhyEngine.explain(
      ExplainerRequest(
        reasonCode: evaluation.reasonCode,
        correct: evaluation.correct,
        arguments: evaluation.reasonArguments,
      ),
    );
    final streak = evaluation.correct ? _state.positiveStreak + 1 : 0;
    final bonus = evaluation.correct ? (streak * 10).clamp(0, 50).toInt() : 0;

    _update(
      _state.copyWith(
        points: _state.points + evaluation.score + bonus,
        attempts: _state.attempts + 1,
        correctCount:
            _state.correctCount + (evaluation.correct ? 1 : 0),
        positiveStreak: streak,
        feedbackAr: explanation.text,
        feedbackReasonCode: explanation.reasonCode,
        isAnswered: true,
        lastAnswerCorrect: evaluation.correct,
      ),
    );
    if (!evaluation.correct) {
      unawaited(_recordDiagnosticFailure(current, answer));
    }
  }

  Future<void> _recordDiagnosticFailure(
    GrammarDrill exercise,
    Object answer,
  ) async {
    final signal = switch (exercise) {
      SentenceReorderExercise sentence => LearningFailureSignal(
          source: ErrorEventSource.grammar,
          skillTag: 'sentence_reorder',
          expected: _sentenceText(
            sentence,
            sentence.correctTokenIds,
          ),
          actual: _sentenceText(
            sentence,
            answer is List<String> ? answer : const <String>[],
          ),
          focus: 'V2 / Satzstellung',
          occurredAt: DateTime.now(),
        ),
      CaseSelectionDrill grammarCase => LearningFailureSignal(
          source: ErrorEventSource.grammar,
          skillTag: 'case_${grammarCase.targetCase.name}',
          expected: grammarCase.expectedArticle,
          actual: answer.toString(),
          focus: grammarCase.noun,
          occurredAt: DateTime.now(),
        ),
      VerbConjugationDrill verb => LearningFailureSignal(
          source: ErrorEventSource.grammar,
          skillTag: 'verb_conjugation',
          expected: verb.expectedForm,
          actual: answer.toString(),
          focus: verb.infinitive,
          occurredAt: DateTime.now(),
        ),
    };
    try {
      await errorDiagnosticSink.recordFailure(signal);
    } on Object {
      // Diagnostics never block the exercise feedback loop.
    }
  }

  String _sentenceText(
    SentenceReorderExercise exercise,
    List<String> ids,
  ) {
    final byId = <String, GrammarToken>{
      for (final token in exercise.tokens) token.id: token,
    };
    return ids
        .map((id) => byId[id]?.text)
        .whereType<String>()
        .join(' ');
  }

  void retry() {
    if (_state.completed) return;
    _update(
      _state.copyWith(
        orderedTokenIds: const <String>[],
        selectedAnswer: '',
        feedbackAr: '',
        clearFeedbackReasonCode: true,
        isAnswered: false,
        lastAnswerCorrect: false,
      ),
    );
  }

  void next() {
    if (_state.completed) return;
    final nextIndex = _state.currentIndex + 1;
    if (nextIndex >= _state.exercises.length) {
      _update(_state.copyWith(completed: true));
      return;
    }
    _update(
      _state.copyWith(
        currentIndex: nextIndex,
        orderedTokenIds: const <String>[],
        selectedAnswer: '',
        feedbackAr: '',
        clearFeedbackReasonCode: true,
        isAnswered: false,
        lastAnswerCorrect: false,
      ),
    );
  }

  void restart() {
    _update(GrammarDrillState.initial(_state.exercises));
  }

  void _update(GrammarDrillState value) {
    _state = value;
    notifyListeners();
  }
}
