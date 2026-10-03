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

  NvvChallengeItem? get currentChallenge => _currentChallenge;
  List<String> get displayedOptions => _displayedOptions;
  String? get selectedVerb => _selectedVerb;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  bool get isBusy => _isBusy;
  NvvRegister? get activeRegister => _activeRegister;

  Future<void> checkPair(String selectedVerb) async {
    final challenge = _currentChallenge;
    if (challenge == null) {
      throw StateError('No active Nomen-Verb-Verbindung challenge.');
    }
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

  Future<void> nextChallenge() async {
    if (_isBusy) return;

    _setBusy(true);
    try {
      if (_challenges.isEmpty) {
        _challenges = await _repository.getChallenges(
          register: _activeRegister,
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
      _challenges = await _repository.getChallenges(register: register);
      _currentIndex = _challenges.isEmpty ? -1 : 0;
      if (_challenges.isEmpty) {
        _clearChallenge();
      } else {
        _activate(_challenges.first);
      }
    } finally {
      _setBusy(false);
    }
  }

  void _activate(NvvChallengeItem challenge) {
    _currentChallenge = challenge;
    _selectedVerb = null;
    _isCorrect = null;
    _showExplanation = false;
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

  void _clearChallenge() {
    _currentChallenge = null;
    _displayedOptions = const <String>[];
    _selectedVerb = null;
    _isCorrect = null;
    _showExplanation = false;
    _currentIndex = -1;
  }

  void _setBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    notifyListeners();
  }
}
