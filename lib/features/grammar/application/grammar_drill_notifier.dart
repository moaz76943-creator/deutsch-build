import 'package:flutter/foundation.dart';

import '../domain/grammar_drill_evaluator.dart';
import '../domain/grammar_drill_models.dart';

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
        isAnswered: isAnswered ?? this.isAnswered,
        lastAnswerCorrect:
            lastAnswerCorrect ?? this.lastAnswerCorrect,
        completed: completed ?? this.completed,
      );
}

final class GrammarDrillNotifier extends ChangeNotifier {
  final GrammarDrillEvaluator evaluator;
  late GrammarDrillState _state;

  GrammarDrillNotifier(
    List<GrammarDrill> exercises, {
    this.evaluator = const GrammarDrillEvaluator(),
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
    final streak = evaluation.correct ? _state.positiveStreak + 1 : 0;
    final bonus = evaluation.correct ? (streak * 10).clamp(0, 50).toInt() : 0;

    _update(
      _state.copyWith(
        points: _state.points + evaluation.score + bonus,
        attempts: _state.attempts + 1,
        correctCount:
            _state.correctCount + (evaluation.correct ? 1 : 0),
        positiveStreak: streak,
        feedbackAr: evaluation.feedbackAr,
        isAnswered: true,
        lastAnswerCorrect: evaluation.correct,
      ),
    );
  }

  void retry() {
    if (_state.completed) return;
    _update(
      _state.copyWith(
        orderedTokenIds: const <String>[],
        selectedAnswer: '',
        feedbackAr: '',
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
