import 'package:flutter/foundation.dart';

import '../domain/conjunctions_models.dart';
import '../domain/conjunctions_repository.dart';

enum VerbPositionVerdict { idle, correct, incorrect }

final class ConjunctionsNotifier extends ChangeNotifier {
  ConjunctionsNotifier({
    required ConjunctionsRepository repository,
    this.category,
  }) : _repository = repository;

  final ConjunctionsRepository _repository;
  final ConjunctionCategory? category;

  List<ConjunctionDrillItem> _drills = const <ConjunctionDrillItem>[];
  ConjunctionDrillItem? _currentDrill;
  String? _selectedOption;
  int? _selectedVerbPosition;
  VerbPositionVerdict _verbPositionVerdict = VerbPositionVerdict.idle;
  bool? _isCorrect;
  bool _showExplanation = false;
  bool _isBusy = false;
  int _currentIndex = -1;
  int _answeredCount = 0;
  int _correctCount = 0;

  ConjunctionDrillItem? get currentDrill => _currentDrill;
  String? get selectedOption => _selectedOption;
  int? get selectedVerbPosition => _selectedVerbPosition;
  VerbPositionVerdict get verbPositionVerdict => _verbPositionVerdict;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  bool get isBusy => _isBusy;
  int get answeredCount => _answeredCount;
  int get correctCount => _correctCount;

  double get accuracy =>
      _answeredCount == 0 ? 0 : _correctCount / _answeredCount;

  List<String> get connectorOptions {
    final values = <String>{};
    for (final drill in _drills) {
      values.add(drill.targetConnector);
    }
    return List<String>.unmodifiable(values);
  }

  Future<void> checkAnswer(
    String chosenConnector,
    int chosenVerbPos,
  ) async {
    final drill = _currentDrill;
    if (drill == null) {
      throw StateError('No active conjunction drill.');
    }
    if (_showExplanation) {
      throw StateError('Current drill has already been scored.');
    }

    final normalizedConnector = chosenConnector.trim();
    if (normalizedConnector.isEmpty) {
      throw ArgumentError.value(
        chosenConnector,
        'chosenConnector',
        'must not be empty',
      );
    }

    _setBusy(true);
    try {
      final correct = await _repository.validateAnswer(
        drill.id,
        normalizedConnector,
        chosenVerbPos,
      );

      _selectedOption = normalizedConnector;
      _selectedVerbPosition = chosenVerbPos;
      _verbPositionVerdict = chosenVerbPos == drill.correctVerbPosition
          ? VerbPositionVerdict.correct
          : VerbPositionVerdict.incorrect;
      _isCorrect = correct;
      _showExplanation = true;
      _answeredCount += 1;
      if (correct) _correctCount += 1;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> nextDrill() async {
    if (_isBusy) return;

    _setBusy(true);
    try {
      if (_drills.isEmpty) {
        _drills = await _repository.getDrills(category: category);
      }

      if (_drills.isEmpty) {
        _currentDrill = null;
        _selectedOption = null;
        _selectedVerbPosition = null;
        _verbPositionVerdict = VerbPositionVerdict.idle;
        _isCorrect = null;
        _showExplanation = false;
        return;
      }

      _currentIndex = (_currentIndex + 1) % _drills.length;
      _currentDrill = _drills[_currentIndex];
      _selectedOption = null;
      _selectedVerbPosition = null;
      _verbPositionVerdict = VerbPositionVerdict.idle;
      _isCorrect = null;
      _showExplanation = false;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    notifyListeners();
  }
}
