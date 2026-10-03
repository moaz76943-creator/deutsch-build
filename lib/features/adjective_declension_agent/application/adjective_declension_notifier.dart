import 'package:flutter/foundation.dart';

import '../domain/adjective_declension_models.dart';
import '../domain/adjective_declension_repository.dart';

final class AdjectiveDeclensionNotifier extends ChangeNotifier {
  AdjectiveDeclensionNotifier(this._repository);

  static const Set<String> supportedEndings = <String>{
    '-e',
    '-en',
    '-er',
    '-es',
    '-em',
  };

  final AdjectiveDeclensionRepository _repository;

  List<AdjectiveExerciseItem> _exercises = const <AdjectiveExerciseItem>[];
  DeclensionType? _activeType;
  int _currentIndex = 0;
  String? _selectedEnding;
  bool? _isCorrect;
  bool _showExplanation = false;
  bool _isLoading = false;
  int _selectionGeneration = 0;

  List<AdjectiveExerciseItem> get exercises =>
      List<AdjectiveExerciseItem>.unmodifiable(_exercises);
  DeclensionType? get activeType => _activeType;
  int get currentIndex => _currentIndex;
  String? get selectedEnding => _selectedEnding;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  bool get isLoading => _isLoading;

  AdjectiveExerciseItem? get currentExercise {
    if (_exercises.isEmpty || _currentIndex >= _exercises.length) return null;
    return _exercises[_currentIndex];
  }

  Future<void> load({DeclensionType? type}) async {
    _isLoading = true;
    _activeType = type;
    _selectionGeneration++;
    notifyListeners();
    try {
      final loaded = await _repository.getExercises(type: type);
      _exercises = List<AdjectiveExerciseItem>.unmodifiable(loaded);
      _currentIndex = 0;
      _clearAnswerState();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectEnding(String ending) async {
    final exercise = currentExercise;
    if (exercise == null || _showExplanation) return;

    final normalized = _normalizeEnding(ending);
    if (!supportedEndings.contains(normalized)) {
      throw ArgumentError.value(
        ending,
        'ending',
        'unsupported adjective ending',
      );
    }

    final generation = ++_selectionGeneration;
    _selectedEnding = normalized;
    _isCorrect = null;
    _showExplanation = false;
    notifyListeners();

    final correct = await _repository.checkAnswer(exercise.id, normalized);
    if (generation != _selectionGeneration ||
        currentExercise?.id != exercise.id) {
      return;
    }

    _isCorrect = correct;
    _showExplanation = true;
    notifyListeners();
  }

  void nextExercise() {
    if (_exercises.isEmpty || !_showExplanation) return;
    _selectionGeneration++;
    _currentIndex = (_currentIndex + 1) % _exercises.length;
    _clearAnswerState();
    notifyListeners();
  }

  Future<void> reset() async {
    await load(type: _activeType);
  }

  void _clearAnswerState() {
    _selectedEnding = null;
    _isCorrect = null;
    _showExplanation = false;
  }

  static String _normalizeEnding(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return '';
    return trimmed.startsWith('-') ? trimmed : '-$trimmed';
  }
}
