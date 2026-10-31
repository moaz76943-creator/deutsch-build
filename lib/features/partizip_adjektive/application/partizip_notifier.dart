import 'package:flutter/foundation.dart';

import '../domain/partizip_models.dart';
import '../domain/partizip_repository.dart';

final class PartizipState {
  const PartizipState({
    required this.exercises,
    required this.currentIndex,
    required this.input,
    required this.orderedTokens,
    required this.checked,
    required this.correct,
    required this.feedbackAr,
    required this.filter,
  });

  final List<PartizipExercise> exercises;
  final int currentIndex;
  final String input;
  final List<String> orderedTokens;
  final bool checked;
  final bool correct;
  final String feedbackAr;
  final PartizipKind? filter;

  PartizipExercise get current => exercises[currentIndex];
}

final class PartizipNotifier extends ChangeNotifier {
  PartizipNotifier(this._repository)
      : _state = PartizipState(
          exercises: List<PartizipExercise>.unmodifiable(
            _repository.allExercises,
          ),
          currentIndex: 0,
          input: '',
          orderedTokens: const <String>[],
          checked: false,
          correct: false,
          feedbackAr: '',
          filter: null,
        ) {
    if (_state.exercises.isEmpty) {
      throw StateError('Partizip exercise bank must not be empty');
    }
  }

  final PartizipRepository _repository;
  PartizipState _state;

  PartizipState get state => _state;

  void checkAttribute(String candidate) {
    final exercise = _state.current;
    final correct = _repository.isAnswerCorrect(exercise, candidate);
    _state = PartizipState(
      exercises: _state.exercises,
      currentIndex: _state.currentIndex,
      input: candidate,
      orderedTokens: _state.orderedTokens,
      checked: true,
      correct: correct,
      feedbackAr: correct
          ? 'صحيح. ${exercise.explanationAr}'
          : 'راجع ترتيب الوصف ونهاية الصفة. ${exercise.explanationAr}',
      filter: _state.filter,
    );
    notifyListeners();
  }

  void addToken(String token) {
    if (_state.checked) return;
    final available = List<String>.from(_state.current.attributeTokens);
    for (final selected in _state.orderedTokens) {
      available.remove(selected);
    }
    if (!available.contains(token)) return;
    final next = <String>[..._state.orderedTokens, token];
    _replaceTokens(next);
  }

  void removeLastToken() {
    if (_state.checked || _state.orderedTokens.isEmpty) return;
    final next = List<String>.from(_state.orderedTokens)..removeLast();
    _replaceTokens(next);
  }

  void checkTokenOrder() {
    final correct = _repository.isTokenOrderCorrect(
      _state.current,
      _state.orderedTokens,
    );
    final exercise = _state.current;
    _state = PartizipState(
      exercises: _state.exercises,
      currentIndex: _state.currentIndex,
      input: _state.input,
      orderedTokens: _state.orderedTokens,
      checked: true,
      correct: correct,
      feedbackAr: correct
          ? 'الترتيب صحيح. ${exercise.explanationAr}'
          : 'الوصف الموسّع يجب أن يبقى كاملاً قبل الاسم. ${exercise.explanationAr}',
      filter: _state.filter,
    );
    notifyListeners();
  }

  void nextExercise() {
    final nextIndex = (_state.currentIndex + 1) % _state.exercises.length;
    _state = PartizipState(
      exercises: _state.exercises,
      currentIndex: nextIndex,
      input: '',
      orderedTokens: const <String>[],
      checked: false,
      correct: false,
      feedbackAr: '',
      filter: _state.filter,
    );
    notifyListeners();
  }

  void filterByKind(PartizipKind kind) {
    final filtered = _repository.forKind(kind);
    if (filtered.isEmpty) {
      throw StateError('No Partizip exercises for ${kind.name}');
    }
    _state = PartizipState(
      exercises: List<PartizipExercise>.unmodifiable(filtered),
      currentIndex: 0,
      input: '',
      orderedTokens: const <String>[],
      checked: false,
      correct: false,
      feedbackAr: '',
      filter: kind,
    );
    notifyListeners();
  }

  void _replaceTokens(List<String> tokens) {
    _state = PartizipState(
      exercises: _state.exercises,
      currentIndex: _state.currentIndex,
      input: _state.input,
      orderedTokens: List<String>.unmodifiable(tokens),
      checked: _state.checked,
      correct: _state.correct,
      feedbackAr: _state.feedbackAr,
      filter: _state.filter,
    );
    notifyListeners();
  }
}
