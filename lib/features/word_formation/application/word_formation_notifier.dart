import 'package:flutter/foundation.dart';

import '../domain/word_formation_models.dart';
import '../domain/word_formation_repository.dart';

final class WordFormationNotifier extends ChangeNotifier {
  WordFormationNotifier(this._repository);

  final WordFormationRepository _repository;

  List<WordDerivationItem> _drills = const <WordDerivationItem>[];
  int _currentIndex = 0;
  SuffixCategory? _activeCategory;
  String? _selectedSuffix;
  String? _formedWord;
  String? _generatedArticle;
  bool? _isCorrect;
  bool _showExplanation = false;
  bool _isLoading = false;
  int _requestGeneration = 0;

  List<WordDerivationItem> get drills =>
      List<WordDerivationItem>.unmodifiable(_drills);
  int get currentIndex => _currentIndex;
  SuffixCategory? get activeCategory => _activeCategory;
  String? get selectedSuffix => _selectedSuffix;
  String? get formedWord => _formedWord;
  String? get generatedArticle => _generatedArticle;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  bool get isLoading => _isLoading;

  WordDerivationItem? get currentDrill {
    if (_drills.isEmpty || _currentIndex >= _drills.length) return null;
    return _drills[_currentIndex];
  }

  List<String> get availableSuffixes {
    final current = currentDrill;
    if (current == null) return const <String>[];

    final preferred = <String>[
      for (final item in _drills)
        if (item.category == current.category) item.suffix,
    ];
    final fallback = <String>[
      for (final item in _drills) item.suffix,
    ];

    final unique = <String>{...preferred, ...fallback}.toList(growable: false);
    if (unique.length <= 5) return unique;

    final answer = current.suffix;
    final distractors = unique.where((value) => value != answer).take(4);
    return <String>[answer, ...distractors];
  }

  Future<void> load({SuffixCategory? category}) async {
    final generation = ++_requestGeneration;
    _isLoading = true;
    notifyListeners();

    final loaded = await _repository.getDrills(category: category);
    if (generation != _requestGeneration) return;

    _drills = List<WordDerivationItem>.unmodifiable(loaded);
    _activeCategory = category;
    _currentIndex = 0;
    _clearAttempt();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> combineSuffix(String suffix) async {
    final drill = currentDrill;
    if (drill == null || _showExplanation) return;

    final selected = _normalizeForCategory(suffix, drill.category);
    final expected = _normalizeForCategory(drill.suffix, drill.category);
    final generation = ++_requestGeneration;

    _selectedSuffix = selected;
    _formedWord = drill.composeAttempt(selected);
    _generatedArticle = WordDerivationItem.articleForAffix(
      selected,
      category: drill.category,
    );
    _isCorrect = null;
    _showExplanation = false;
    notifyListeners();

    final wordCorrect = await _repository.checkDerivedWord(
      drill.id,
      _formedWord!,
    );
    final articleCorrect = await _repository.checkArticle(
      drill.id,
      _generatedArticle ?? '',
    );

    if (generation != _requestGeneration ||
        currentDrill?.id != drill.id) {
      return;
    }

    _isCorrect =
        selected == expected && wordCorrect && articleCorrect;
    _showExplanation = true;
    notifyListeners();
  }

  void nextDrill() {
    if (_drills.isEmpty) return;
    _requestGeneration++;
    _currentIndex = (_currentIndex + 1) % _drills.length;
    _clearAttempt();
    notifyListeners();
  }

  Future<void> filterByCategory(SuffixCategory category) async {
    await load(category: category);
  }

  Future<void> clearCategoryFilter() async {
    await load();
  }

  void _clearAttempt() {
    _selectedSuffix = null;
    _formedWord = null;
    _generatedArticle = null;
    _isCorrect = null;
    _showExplanation = false;
  }

  static String _normalizeForCategory(
    String value,
    SuffixCategory category,
  ) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return '';

    if (category == SuffixCategory.verbPrefixDerivation) {
      return trimmed.endsWith('-') ? trimmed : '$trimmed-';
    }

    return trimmed.startsWith('-') ? trimmed : '-$trimmed';
  }
}
