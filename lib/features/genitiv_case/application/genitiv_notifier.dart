import 'package:flutter/foundation.dart';

import '../domain/genitiv_models.dart';
import '../domain/genitiv_repository.dart';

final class GenitivNotifier extends ChangeNotifier {
  GenitivNotifier({
    required GenitivRepository repository,
  }) : _repository = repository;

  final GenitivRepository _repository;

  List<GenitivChallengeItem> _challenges =
      const <GenitivChallengeItem>[];
  GenitivChallengeItem? _currentChallenge;
  GenitivDrillType? _filter;
  String? _selectedArticle;
  String? _selectedNounSuffix;
  String? _selectedPreposition;
  bool? _isCorrect;
  bool _showExplanation = false;
  String _explanationAr = '';
  bool _isBusy = false;
  int _currentIndex = -1;

  GenitivChallengeItem? get currentChallenge => _currentChallenge;
  GenitivDrillType? get filter => _filter;
  String? get selectedArticle => _selectedArticle;
  String? get selectedNounSuffix => _selectedNounSuffix;
  String? get selectedPreposition => _selectedPreposition;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  String get explanationAr => _explanationAr;
  bool get isBusy => _isBusy;

  void selectArticle(String value) {
    if (_showExplanation) return;
    final normalized = value.trim().toLowerCase();
    if (normalized != 'des' && normalized != 'der') return;
    if (_selectedArticle == normalized) return;
    _selectedArticle = normalized;
    notifyListeners();
  }

  void selectNounSuffix(String value) {
    if (_showExplanation) return;
    final normalized = value.trim().toLowerCase();
    if (!const <String>{'', 's', 'es'}.contains(normalized)) return;
    if (_selectedNounSuffix == normalized) return;
    _selectedNounSuffix = normalized;
    notifyListeners();
  }

  void selectPreposition(String value) {
    if (_showExplanation) return;
    final normalized = value.trim().toLowerCase();
    if (!const <String>{
      'wegen',
      'während',
      'trotz',
      'anstatt',
    }.contains(normalized)) {
      return;
    }
    if (_selectedPreposition == normalized) return;
    _selectedPreposition = normalized;
    notifyListeners();
  }

  Future<void> checkGenitivAnswer(
    String chosenArticle,
    String chosenNounSuffix, {
    String? chosenPreposition,
  }) async {
    final challenge = _currentChallenge;
    if (challenge == null) {
      throw StateError('No active Genitiv challenge.');
    }
    if (_showExplanation) {
      throw StateError('Current Genitiv challenge has already been scored.');
    }

    _setBusy(true);
    try {
      final normalizedArticle = chosenArticle.trim().toLowerCase();
      final normalizedSuffix = chosenNounSuffix.trim().toLowerCase();
      final normalizedPreposition =
          chosenPreposition?.trim().toLowerCase();

      final correct = await _repository.validateAnswer(
        challenge.id,
        chosenArticle: normalizedArticle,
        chosenNounSuffix: normalizedSuffix,
        chosenPreposition: normalizedPreposition,
      );

      _selectedArticle = normalizedArticle;
      _selectedNounSuffix = normalizedSuffix;
      _selectedPreposition = normalizedPreposition;
      _isCorrect = correct;
      _showExplanation = true;
      _explanationAr = challenge.explanationAr;
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

  Future<void> filterByType(GenitivDrillType type) async {
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

  void _clearAttempt() {
    _selectedArticle = null;
    _selectedNounSuffix = null;
    _selectedPreposition = null;
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
