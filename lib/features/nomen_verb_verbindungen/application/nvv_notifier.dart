import 'package:flutter/foundation.dart';

import '../domain/nvv_models.dart';
import '../domain/nvv_repository.dart';

final class NvvNotifier extends ChangeNotifier {
  NvvNotifier({required NvvRepository repository}) : _repository = repository;

  final NvvRepository _repository;

  List<NvvChallengeItem> _challenges = const <NvvChallengeItem>[];
  NvvChallengeItem? _currentChallenge;
  List<String> _displayedOptions = const <String>[];
  String? _selectedVerb;
  bool? _isCorrect;
  bool _showExplanation = false;
  bool _isBusy = false;
  int _currentIndex = -1;
  NvvRegister? _activeRegister;
  NvvContext? _activeContext;

  ReplacementDirection _replacementDirection =
      ReplacementDirection.simpleToNvv;
  String? _replacementAnswer;
  bool? _replacementCorrect;
  bool _showReplacementExplanation = false;

  NvvChallengeItem? get currentChallenge => _currentChallenge;
  List<String> get displayedOptions => _displayedOptions;
  String? get selectedVerb => _selectedVerb;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  bool get isBusy => _isBusy;
  NvvRegister? get activeRegister => _activeRegister;
  NvvContext? get activeContext => _activeContext;
  ReplacementDirection get replacementDirection => _replacementDirection;
  String? get replacementAnswer => _replacementAnswer;
  bool? get replacementCorrect => _replacementCorrect;
  bool get showReplacementExplanation => _showReplacementExplanation;

  Future<void> checkPair(String selectedVerb) async {
    final challenge = _requireChallenge();
    if (_showExplanation) {
      throw StateError('Current challenge has already been checked.');
    }

    final verb = selectedVerb.trim();
    if (verb.isEmpty) {
      throw ArgumentError.value(
        selectedVerb,
        'selectedVerb',
        'must not be empty',
      );
    }

    _setBusy(true);
    try {
      _selectedVerb = verb;
      _isCorrect = await _repository.validateAnswer(challenge.id, verb);
      _showExplanation = true;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> checkReplacement(String candidate) async {
    final challenge = _requireChallenge();
    if (_showReplacementExplanation) {
      throw StateError('Current replacement has already been checked.');
    }

    final answer = candidate.trim();
    if (answer.isEmpty) {
      throw ArgumentError.value(
        candidate,
        'candidate',
        'must not be empty',
      );
    }

    _setBusy(true);
    try {
      _replacementAnswer = answer;
      _replacementCorrect = await _repository.validateReplacement(
        challenge.id,
        _replacementDirection,
        answer,
      );
      _showReplacementExplanation = true;
    } finally {
      _setBusy(false);
    }
  }

  void setReplacementDirection(ReplacementDirection direction) {
    if (_replacementDirection == direction) return;
    _replacementDirection = direction;
    _clearReplacementState();
    notifyListeners();
  }

  Future<void> nextChallenge() async {
    if (_isBusy) return;

    _setBusy(true);
    try {
      if (_challenges.isEmpty) {
        _challenges = await _repository.getChallenges(
          register: _activeRegister,
          context: _activeContext,
        );
      }

      if (_challenges.isEmpty) {
        _clearChallenge();
        return;
      }

      _currentIndex = (_currentIndex + 1) % _challenges.length;
      _activate(_challenges[_currentIndex]);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> filterByRegister(NvvRegister register) async {
    if (_isBusy) return;

    _setBusy(true);
    try {
      _activeRegister = register;
      _activeContext = null;
      _challenges = await _repository.getChallenges(register: register);
      _activateFirstOrClear();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> filterByContext(NvvContext context) async {
    if (_isBusy) return;

    _setBusy(true);
    try {
      _activeContext = context;
      _activeRegister = null;
      _challenges = await _repository.getChallenges(context: context);
      _activateFirstOrClear();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> clearFilters() async {
    if (_isBusy) return;

    _setBusy(true);
    try {
      _activeRegister = null;
      _activeContext = null;
      _challenges = await _repository.getChallenges();
      _activateFirstOrClear();
    } finally {
      _setBusy(false);
    }
  }

  void _activateFirstOrClear() {
    _currentIndex = _challenges.isEmpty ? -1 : 0;
    if (_challenges.isEmpty) {
      _clearChallenge();
    } else {
      _activate(_challenges.first);
    }
  }

  void _activate(NvvChallengeItem challenge) {
    _currentChallenge = challenge;
    _selectedVerb = null;
    _isCorrect = null;
    _showExplanation = false;
    _clearReplacementState();
    _displayedOptions = _buildOptions(challenge);
  }

  List<String> _buildOptions(NvvChallengeItem challenge) {
    final verbs = <String>{challenge.correctVerb};
    for (final item in _challenges) {
      if (item.correctVerb != challenge.correctVerb) {
        verbs.add(item.correctVerb);
      }
      if (verbs.length >= 4) break;
    }

    final options = verbs.toList(growable: false)..sort();
    return List<String>.unmodifiable(options);
  }

  NvvChallengeItem _requireChallenge() {
    final challenge = _currentChallenge;
    if (challenge == null) {
      throw StateError('No active Nomen-Verb-Verbindung challenge.');
    }
    return challenge;
  }

  void _clearReplacementState() {
    _replacementAnswer = null;
    _replacementCorrect = null;
    _showReplacementExplanation = false;
  }

  void _clearChallenge() {
    _currentChallenge = null;
    _displayedOptions = const <String>[];
    _selectedVerb = null;
    _isCorrect = null;
    _showExplanation = false;
    _clearReplacementState();
    _currentIndex = -1;
  }

  void _setBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    notifyListeners();
  }
}
