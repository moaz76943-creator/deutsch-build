import 'package:flutter/foundation.dart';

import '../domain/buergeramt_models.dart';
import '../domain/buergeramt_repository.dart';

final class BuergeramtNotifier extends ChangeNotifier {
  BuergeramtNotifier(this._repository);

  final BuergeramtRepository _repository;

  List<BureaucracyScenario> _situations = const <BureaucracyScenario>[];
  List<BureaucracyDialogueTurn> _dialogue =
      const <BureaucracyDialogueTurn>[];
  BureaucracyScenario? _activeScenario;
  int _currentTurnIndex = 0;
  String? _selectedChoiceId;
  bool? _isCorrect;
  bool _showExplanation = false;
  String _feedbackAr = '';
  bool _isLoading = false;
  int _generation = 0;

  List<BureaucracyScenario> get situations =>
      List<BureaucracyScenario>.unmodifiable(_situations);
  List<BureaucracyDialogueTurn> get dialogue =>
      List<BureaucracyDialogueTurn>.unmodifiable(_dialogue);
  BureaucracyScenario? get activeScenario => _activeScenario;
  int get currentTurnIndex => _currentTurnIndex;
  String? get selectedChoiceId => _selectedChoiceId;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  String get feedbackAr => _feedbackAr;
  bool get isLoading => _isLoading;

  BureaucracyDialogueTurn? get currentTurn {
    if (_dialogue.isEmpty || _currentTurnIndex >= _dialogue.length) {
      return null;
    }
    return _dialogue[_currentTurnIndex];
  }

  bool get isLastTurn =>
      _dialogue.isNotEmpty && _currentTurnIndex == _dialogue.length - 1;

  Future<void> load() async {
    final generation = ++_generation;
    _isLoading = true;
    notifyListeners();

    try {
      final situations = await _repository.getSituations();
      if (generation != _generation) return;

      _situations = List<BureaucracyScenario>.unmodifiable(situations);
      if (_situations.isEmpty) {
        _activeScenario = null;
        _dialogue = const <BureaucracyDialogueTurn>[];
        _resetTurnState();
        return;
      }

      final first = _situations.first;
      final turns = await _repository.getDialogue(first.id);
      if (generation != _generation) return;

      _activeScenario = first;
      _dialogue = List<BureaucracyDialogueTurn>.unmodifiable(turns);
      _currentTurnIndex = 0;
      _resetAnswerState();
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> switchSituation(BureaucracySituation type) async {
    final scenario = _findSituation(type);
    if (scenario == null) {
      throw ArgumentError.value(type, 'type', 'situation is not available');
    }

    final generation = ++_generation;
    _isLoading = true;
    _activeScenario = scenario;
    _dialogue = const <BureaucracyDialogueTurn>[];
    _currentTurnIndex = 0;
    _resetAnswerState();
    notifyListeners();

    try {
      final turns = await _repository.getDialogue(scenario.id);
      if (generation != _generation ||
          _activeScenario?.id != scenario.id) {
        return;
      }
      _dialogue = List<BureaucracyDialogueTurn>.unmodifiable(turns);
      _currentTurnIndex = 0;
      _resetAnswerState();
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> selectResponse(String choiceId) async {
    final scenario = _activeScenario;
    final turn = currentTurn;
    if (scenario == null ||
        turn == null ||
        turn.choices.isEmpty ||
        _showExplanation) {
      return;
    }

    final choice = _findChoice(turn, choiceId);
    if (choice == null) {
      throw ArgumentError.value(
        choiceId,
        'choiceId',
        'choice is not available for this turn',
      );
    }

    final generation = ++_generation;
    _selectedChoiceId = choice.id;
    _isCorrect = null;
    _showExplanation = false;
    _feedbackAr = '';
    notifyListeners();

    final correct = await _repository.checkChoice(
      scenarioId: scenario.id,
      turnId: turn.id,
      choiceId: choice.id,
    );
    if (generation != _generation ||
        _activeScenario?.id != scenario.id ||
        currentTurn?.id != turn.id ||
        _selectedChoiceId != choice.id) {
      return;
    }

    _isCorrect = correct;
    _feedbackAr = choice.feedbackAr;
    _showExplanation = true;
    notifyListeners();
  }

  void nextTurn() {
    final turn = currentTurn;
    if (turn == null || isLastTurn) return;
    if (turn.choices.isNotEmpty && !_showExplanation) return;

    _generation++;
    _currentTurnIndex++;
    _resetAnswerState();
    notifyListeners();
  }

  void restartDialogue() {
    if (_dialogue.isEmpty) return;
    _generation++;
    _currentTurnIndex = 0;
    _resetAnswerState();
    notifyListeners();
  }

  BureaucracyScenario? _findSituation(BureaucracySituation type) {
    for (final situation in _situations) {
      if (situation.type == type) return situation;
    }
    return null;
  }

  static DialogueChoice? _findChoice(
    BureaucracyDialogueTurn turn,
    String choiceId,
  ) {
    for (final choice in turn.choices) {
      if (choice.id == choiceId) return choice;
    }
    return null;
  }

  void _resetTurnState() {
    _currentTurnIndex = 0;
    _resetAnswerState();
  }

  void _resetAnswerState() {
    _selectedChoiceId = null;
    _isCorrect = null;
    _showExplanation = false;
    _feedbackAr = '';
  }
}
