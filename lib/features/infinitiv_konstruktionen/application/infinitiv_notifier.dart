import 'package:flutter/foundation.dart';

import '../domain/infinitiv_models.dart';
import '../domain/infinitiv_repository.dart';

final class InfinitivNotifier extends ChangeNotifier {
  InfinitivNotifier({
    required InfinitivRepository repository,
  }) : _repository = repository;

  final InfinitivRepository _repository;

  List<InfinitivChallengeItem> _challenges =
      const <InfinitivChallengeItem>[];
  InfinitivChallengeItem? _currentChallenge;
  InfinitivClauseType? _filter;
  String? _selectedAnswer;
  bool? _isCorrect;
  bool _showExplanation = false;
  String _explanationAr = '';
  bool _isBusy = false;
  int _currentIndex = -1;
  int _answeredCount = 0;
  int _correctCount = 0;

  InfinitivChallengeItem? get currentChallenge => _currentChallenge;
  InfinitivClauseType? get filter => _filter;
  String? get selectedAnswer => _selectedAnswer;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  String get explanationAr => _explanationAr;
  bool get isBusy => _isBusy;
  int get answeredCount => _answeredCount;
  int get correctCount => _correctCount;

  double get accuracy =>
      _answeredCount == 0 ? 0 : _correctCount / _answeredCount;

  void selectAnswer(String value) {
    if (_showExplanation || _isBusy) return;
    final challenge = _currentChallenge;
    if (challenge == null) return;

    final normalized = value.trim();
    if (!challenge.answerOptions.contains(normalized)) return;
    if (_selectedAnswer == normalized) return;

    _selectedAnswer = normalized;
    notifyListeners();
  }

  Future<void> checkAnswer() async {
    final challenge = _currentChallenge;
    final answer = _selectedAnswer;
    if (challenge == null) {
      throw StateError('No active infinitive challenge.');
    }
    if (answer == null) {
      throw StateError('Select an answer before scoring.');
    }
    if (_showExplanation) {
      throw StateError('Current challenge has already been scored.');
    }

    _setBusy(true);
    try {
      final correct = await _repository.validateAnswer(
        challenge.id,
        answer,
      );

      _isCorrect = correct;
      _showExplanation = true;
      _explanationAr = challenge.ruleExplanationAr;
      _answeredCount += 1;
      if (correct) _correctCount += 1;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> nextChallenge() async {
    if (_isBusy) return;

    _setBusy(true);
    try {
      if (_challenges.isEmpty) {
        _challenges = await _repository.getChallenges(type: _filter);
      }

      if (_challenges.isEmpty) {
        _currentChallenge = null;
        _currentIndex = -1;
        _clearAttempt();
        return;
      }

      _currentIndex = (_currentIndex + 1) % _challenges.length;
      _currentChallenge = _challenges[_currentIndex];
      _clearAttempt();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> filterByType(InfinitivClauseType type) async {
    if (_isBusy) return;

    _setBusy(true);
    try {
      _filter = type;
      _challenges = await _repository.getChallenges(type: type);
      _currentIndex = _challenges.isEmpty ? -1 : 0;
      _currentChallenge =
          _challenges.isEmpty ? null : _challenges.first;
      _clearAttempt();
    } finally {
      _setBusy(false);
    }
  }

  void reset() {
    _challenges = const <InfinitivChallengeItem>[];
    _currentChallenge = null;
    _filter = null;
    _currentIndex = -1;
    _answeredCount = 0;
    _correctCount = 0;
    _clearAttempt();
    notifyListeners();
  }

  void _clearAttempt() {
    _selectedAnswer = null;
    _isCorrect = null;
    _showExplanation = false;
    _explanationAr = '';
  }

  void _setBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    notifyListeners();
  }
}
