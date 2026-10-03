import 'package:flutter/foundation.dart';

import '../domain/imperativ_models.dart';
import '../domain/imperativ_repository.dart';

final class ImperativState {
  const ImperativState({
    required this.drills,
    required this.currentIndex,
    required this.input,
    required this.checked,
    required this.correct,
    required this.feedbackAr,
    required this.filter,
  });

  final List<ImperativDrillItem> drills;
  final int currentIndex;
  final String input;
  final bool checked;
  final bool correct;
  final String feedbackAr;
  final ImperativTarget? filter;

  ImperativDrillItem get current => drills[currentIndex];

  ImperativState copyWith({
    List<ImperativDrillItem>? drills,
    int? currentIndex,
    String? input,
    bool? checked,
    bool? correct,
    String? feedbackAr,
    ImperativTarget? filter,
    bool clearFilter = false,
  }) =>
      ImperativState(
        drills: drills ?? this.drills,
        currentIndex: currentIndex ?? this.currentIndex,
        input: input ?? this.input,
        checked: checked ?? this.checked,
        correct: correct ?? this.correct,
        feedbackAr: feedbackAr ?? this.feedbackAr,
        filter: clearFilter ? null : (filter ?? this.filter),
      );
}

final class ImperativNotifier extends ChangeNotifier {
  ImperativNotifier(this._repository)
      : _state = ImperativState(
          drills: List<ImperativDrillItem>.unmodifiable(
            _repository.allDrills,
          ),
          currentIndex: 0,
          input: '',
          checked: false,
          correct: false,
          feedbackAr: '',
          filter: null,
        ) {
    if (_state.drills.isEmpty) {
      throw StateError('Imperativ drill bank must not be empty');
    }
  }

  final ImperativRepository _repository;
  ImperativState _state;

  ImperativState get state => _state;

  void checkImperativForm(String input) {
    final item = _state.current;
    final correct = _repository.isCorrect(item, input);
    _state = _state.copyWith(
      input: input,
      checked: true,
      correct: correct,
      feedbackAr: correct
          ? 'صحيح. ${item.explanationAr}'
          : 'راجع الصيغة: ${item.correctForm} — ${item.explanationAr}',
    );
    notifyListeners();
  }

  void nextDrill() {
    final nextIndex = (_state.currentIndex + 1) % _state.drills.length;
    _state = _state.copyWith(
      currentIndex: nextIndex,
      input: '',
      checked: false,
      correct: false,
      feedbackAr: '',
    );
    notifyListeners();
  }

  void filterByTarget(ImperativTarget target) {
    final filtered = _repository.forTarget(target);
    if (filtered.isEmpty) {
      throw StateError('No Imperativ drills for ${target.name}');
    }
    _state = ImperativState(
      drills: List<ImperativDrillItem>.unmodifiable(filtered),
      currentIndex: 0,
      input: '',
      checked: false,
      correct: false,
      feedbackAr: '',
      filter: target,
    );
    notifyListeners();
  }
}
