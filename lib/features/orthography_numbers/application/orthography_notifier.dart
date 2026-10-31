import 'package:flutter/foundation.dart';

import '../domain/orthography_models.dart';
import '../domain/orthography_repository.dart';

final class OrthographyState {
  const OrthographyState({
    required this.exercises,
    required this.currentIndex,
    required this.selectedCommaGaps,
    required this.input,
    required this.checked,
    required this.correct,
    required this.feedbackAr,
    required this.filter,
  });

  final List<OrthographyExercise> exercises;
  final int currentIndex;
  final Set<int> selectedCommaGaps;
  final String input;
  final bool checked;
  final bool correct;
  final String feedbackAr;
  final OrthographyTopic? filter;

  OrthographyExercise get current => exercises[currentIndex];
}

final class OrthographyNotifier extends ChangeNotifier {
  OrthographyNotifier(this._repository)
      : _state = OrthographyState(
          exercises: List<OrthographyExercise>.unmodifiable(
            _repository.allExercises,
          ),
          currentIndex: 0,
          selectedCommaGaps: const <int>{},
          input: '',
          checked: false,
          correct: false,
          feedbackAr: '',
          filter: null,
        ) {
    if (_state.exercises.isEmpty) {
      throw StateError('Orthography exercise bank must not be empty');
    }
  }

  final OrthographyRepository _repository;
  OrthographyState _state;

  OrthographyState get state => _state;

  void toggleCommaAfter(int tokenIndex) {
    final exercise = _state.current;
    if (_state.checked || !exercise.isCommaPlacement) return;
    if (tokenIndex < 0 || tokenIndex >= exercise.tokens.length - 1) {
      return;
    }
    final next = Set<int>.from(_state.selectedCommaGaps);
    if (!next.add(tokenIndex)) next.remove(tokenIndex);
    _replace(
      selectedCommaGaps: Set<int>.unmodifiable(next),
    );
  }

  void checkCommaPlacement() {
    final exercise = _state.current;
    if (!exercise.isCommaPlacement) return;
    final correct = _repository.isCommaPlacementCorrect(
      exercise,
      _state.selectedCommaGaps,
    );
    _replace(
      checked: true,
      correct: correct,
      feedbackAr: correct
          ? 'صحيح. ${exercise.explanationAr}'
          : 'راجع موضع الفاصلة. ${exercise.explanationAr}',
    );
  }

  void checkTextAnswer(String answer) {
    final exercise = _state.current;
    if (exercise.kind != OrthographyExerciseKind.textEntry) return;
    final correct = _repository.isTextAnswerCorrect(exercise, answer);
    _replace(
      input: answer,
      checked: true,
      correct: correct,
      feedbackAr: correct
          ? 'صحيح. ${exercise.explanationAr}'
          : 'راجع الكتابة. ${exercise.explanationAr}',
    );
  }

  void nextExercise() {
    final nextIndex = (_state.currentIndex + 1) % _state.exercises.length;
    _state = OrthographyState(
      exercises: _state.exercises,
      currentIndex: nextIndex,
      selectedCommaGaps: const <int>{},
      input: '',
      checked: false,
      correct: false,
      feedbackAr: '',
      filter: _state.filter,
    );
    notifyListeners();
  }

  void filterByTopic(OrthographyTopic topic) {
    final filtered = _repository.forTopic(topic);
    if (filtered.isEmpty) {
      throw StateError('No orthography exercises for ${topic.name}');
    }
    _state = OrthographyState(
      exercises: List<OrthographyExercise>.unmodifiable(filtered),
      currentIndex: 0,
      selectedCommaGaps: const <int>{},
      input: '',
      checked: false,
      correct: false,
      feedbackAr: '',
      filter: topic,
    );
    notifyListeners();
  }

  void _replace({
    Set<int>? selectedCommaGaps,
    String? input,
    bool? checked,
    bool? correct,
    String? feedbackAr,
  }) {
    _state = OrthographyState(
      exercises: _state.exercises,
      currentIndex: _state.currentIndex,
      selectedCommaGaps:
          selectedCommaGaps ?? _state.selectedCommaGaps,
      input: input ?? _state.input,
      checked: checked ?? _state.checked,
      correct: correct ?? _state.correct,
      feedbackAr: feedbackAr ?? _state.feedbackAr,
      filter: _state.filter,
    );
    notifyListeners();
  }
}
