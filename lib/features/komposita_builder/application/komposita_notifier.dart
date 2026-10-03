import 'package:flutter/foundation.dart';

import '../../../core/localization/german_article_style.dart';
import '../domain/komposita_models.dart';
import '../domain/komposita_repository.dart';

enum KompositaMode { deconstruct, assemble }

final class KompositaNotifier extends ChangeNotifier {
  KompositaNotifier({
    required KompositaRepository repository,
  }) : _repository = repository;

  final KompositaRepository _repository;

  List<KompositaChallengeItem> _challenges =
      const <KompositaChallengeItem>[];
  KompositaChallengeItem? _currentChallenge;
  KompositaMode _mode = KompositaMode.assemble;
  GermanArticle? _selectedArticle;
  LinkingElement? _selectedLinkingElement;
  List<String> _assembledParts = const <String>[];
  bool? _isCorrect;
  bool _showExplanation = false;
  String _explanationAr = '';
  bool _isBusy = false;
  int _currentIndex = -1;

  KompositaChallengeItem? get currentChallenge => _currentChallenge;
  KompositaMode get mode => _mode;
  GermanArticle? get selectedArticle => _selectedArticle;
  LinkingElement? get selectedLinkingElement => _selectedLinkingElement;
  List<String> get assembledParts => _assembledParts;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  String get explanationAr => _explanationAr;
  bool get isBusy => _isBusy;

  void setMode(KompositaMode value) {
    if (_mode == value) return;
    _mode = value;
    _clearAttempt();
    notifyListeners();
  }

  void choosePart(String rawWord) {
    final challenge = _currentChallenge;
    if (challenge == null || _showExplanation) return;

    final word = rawWord.trim();
    if (word.isEmpty) return;

    final allowedCount = challenge.parts
        .where((part) => part.word == word)
        .length;
    final selectedCount = _assembledParts
        .where((part) => part == word)
        .length;
    if (allowedCount == 0 || selectedCount >= allowedCount) return;

    _assembledParts = List<String>.unmodifiable(
      <String>[..._assembledParts, word],
    );
    notifyListeners();
  }

  void removeLastPart() {
    if (_assembledParts.isEmpty || _showExplanation) return;
    _assembledParts = List<String>.unmodifiable(
      _assembledParts.sublist(0, _assembledParts.length - 1),
    );
    notifyListeners();
  }

  void clearAssembly() {
    if (_assembledParts.isEmpty || _showExplanation) return;
    _assembledParts = const <String>[];
    notifyListeners();
  }

  void selectArticle(GermanArticle article) {
    if (_showExplanation) return;
    if (_selectedArticle == article) return;
    _selectedArticle = article;
    notifyListeners();
  }

  void selectLinkingElement(LinkingElement element) {
    if (_showExplanation) return;
    if (_selectedLinkingElement == element) return;
    _selectedLinkingElement = element;
    notifyListeners();
  }

  Future<void> checkComposition(
    List<String> orderedParts,
    LinkingElement linkingElement,
    GermanArticle finalArticle,
  ) async {
    final challenge = _currentChallenge;
    if (challenge == null) {
      throw StateError('No active Komposita challenge.');
    }
    if (_showExplanation) {
      throw StateError('Current challenge has already been scored.');
    }

    final normalizedParts = orderedParts
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (normalizedParts.isEmpty) {
      throw ArgumentError.value(
        orderedParts,
        'orderedParts',
        'must contain at least one part',
      );
    }

    _setBusy(true);
    try {
      final correct = await _repository.validateComposition(
        challenge.id,
        orderedParts: normalizedParts,
        linkingElement: linkingElement,
        finalArticle: finalArticle,
      );

      _assembledParts = List<String>.unmodifiable(normalizedParts);
      _selectedLinkingElement = linkingElement;
      _selectedArticle = finalArticle;
      _isCorrect = correct;
      _showExplanation = true;
      _explanationAr = challenge.derivationExplanationAr;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> nextChallenge() async {
    if (_isBusy) return;

    _setBusy(true);
    try {
      if (_challenges.isEmpty) {
        _challenges = await _repository.getChallenges();
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

  void reset() {
    _challenges = const <KompositaChallengeItem>[];
    _currentChallenge = null;
    _mode = KompositaMode.assemble;
    _currentIndex = -1;
    _clearAttempt();
    notifyListeners();
  }

  void _clearAttempt() {
    _selectedArticle = null;
    _selectedLinkingElement = null;
    _assembledParts = const <String>[];
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
