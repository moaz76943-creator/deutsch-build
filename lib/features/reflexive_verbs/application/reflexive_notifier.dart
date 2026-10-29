import 'package:flutter/foundation.dart';

import '../domain/reflexive_models.dart';
import '../domain/reflexive_repository.dart';

final class ReflexiveState {
  const ReflexiveState({
    required this.drills,
    required this.currentIndex,
    required this.selectedPronoun,
    required this.checked,
    required this.correct,
    required this.feedbackAr,
    required this.filter,
  });

  final List<ReflexiveDrillItem> drills;
  final int currentIndex;
  final String? selectedPronoun;
  final bool checked;
  final bool correct;
  final String feedbackAr;
  final ReflexiveCase? filter;

  ReflexiveDrillItem get current => drills[currentIndex];
}

final class ReflexiveNotifier extends ChangeNotifier {
  ReflexiveNotifier(this._repository)
      : _state = ReflexiveState(
          drills: List<ReflexiveDrillItem>.unmodifiable(
            _repository.allDrills,
          ),
          currentIndex: 0,
          selectedPronoun: null,
          checked: false,
          correct: false,
          feedbackAr: '',
          filter: null,
        ) {
    if (_state.drills.isEmpty) {
      throw StateError('Reflexive drill bank must not be empty');
    }
  }

  final ReflexiveRepository _repository;
  ReflexiveState _state;

  ReflexiveState get state => _state;

  void checkReflexivePronoun(String candidate) {
    final item = _state.current;
    final normalized = _repository.normalizePronoun(candidate);
    final correct = _repository.isCorrectPronoun(item, normalized);
    _state = ReflexiveState(
      drills: _state.drills,
      currentIndex: _state.currentIndex,
      selectedPronoun: normalized,
      checked: true,
      correct: correct,
      feedbackAr: correct
          ? 'صحيح. ${item.explanationAr}'
          : 'الإجابة الصحيحة: ${item.reflexivePronoun}. ${item.explanationAr}',
      filter: _state.filter,
    );
    notifyListeners();
  }

  void nextDrill() {
    final nextIndex = (_state.currentIndex + 1) % _state.drills.length;
    _state = ReflexiveState(
      drills: _state.drills,
      currentIndex: nextIndex,
      selectedPronoun: null,
      checked: false,
      correct: false,
      feedbackAr: '',
      filter: _state.filter,
    );
    notifyListeners();
  }

  void filterByCase(ReflexiveCase reflexCase) {
    final filtered = _repository.forCase(reflexCase);
    if (filtered.isEmpty) {
      throw StateError('No reflexive drills for ${reflexCase.name}');
    }
    _state = ReflexiveState(
      drills: List<ReflexiveDrillItem>.unmodifiable(filtered),
      currentIndex: 0,
      selectedPronoun: null,
      checked: false,
      correct: false,
      feedbackAr: '',
      filter: reflexCase,
    );
    notifyListeners();
  }
}
