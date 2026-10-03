import 'package:flutter/foundation.dart';

import '../domain/separable_verbs_models.dart';
import '../domain/separable_verbs_repository.dart';

final class SeparableVerbsNotifier extends ChangeNotifier {
  SeparableVerbsNotifier(this._repository);

  final SeparableVerbsRepository _repository;

  List<VerbPrefixDrillItem> _allDrills = const <VerbPrefixDrillItem>[];
  List<VerbPrefixDrillItem> _visibleDrills = const <VerbPrefixDrillItem>[];
  int _currentIndex = 0;
  PrefixType? _activeFilter;
  PrefixPlacement? _selectedPlacement;
  String? _selectedConjugation;
  bool? _isCorrect;
  String _explanation = '';
  bool _isBusy = false;

  VerbPrefixDrillItem? get currentVerb {
    if (_visibleDrills.isEmpty) return null;
    final safeIndex =
        _currentIndex >= 0 && _currentIndex < _visibleDrills.length
            ? _currentIndex
            : 0;
    return _visibleDrills[safeIndex];
  }

  String get interactiveSentence =>
      currentVerb?.trainingSentenceTemplate ?? '';

  PrefixType? get activeFilter => _activeFilter;

  PrefixPlacement? get selectedPlacement => _selectedPlacement;

  String? get selectedConjugation => _selectedConjugation;

  bool? get isCorrect => _isCorrect;

  String get explanation => _explanation;

  bool get isBusy => _isBusy;

  int get drillNumber => _visibleDrills.isEmpty ? 0 : _currentIndex + 1;

  int get drillCount => _visibleDrills.length;

  Future<void> initialize() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      _allDrills = await _repository.getDrills();
      _visibleDrills = List<VerbPrefixDrillItem>.unmodifiable(_allDrills);
      _currentIndex = 0;
      _activeFilter = null;
      _resetAnswerState();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> checkPrefixPlacement(
    PrefixPlacement placement, {
    required String conjugatedVerb,
  }) async {
    final item = currentVerb;
    if (item == null || _isBusy) return;

    _isBusy = true;
    _selectedPlacement = placement;
    _selectedConjugation = conjugatedVerb.trim();
    notifyListeners();
    try {
      final correct = await _repository.validateAnswer(
        drillId: item.id,
        selectedPlacement: placement,
        conjugatedVerb: conjugatedVerb,
      );
      _isCorrect = correct;
      _explanation = correct
          ? 'صحيح: السابقة ${item.prefix}. ${item.ruleExplanation}'
          : _incorrectExplanation(item, placement, conjugatedVerb);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void nextDrill() {
    if (_visibleDrills.isEmpty || _isBusy) return;
    _currentIndex = (_currentIndex + 1) % _visibleDrills.length;
    _resetAnswerState();
    notifyListeners();
  }

  Future<void> filterByType(PrefixType type) async {
    if (_isBusy) return;
    if (_allDrills.isEmpty) {
      await initialize();
    }
    _activeFilter = type;
    _visibleDrills = List<VerbPrefixDrillItem>.unmodifiable(
      _allDrills.where((item) => item.prefixType == type),
    );
    _currentIndex = 0;
    _resetAnswerState();
    notifyListeners();
  }

  void clearFilter() {
    if (_isBusy || _allDrills.isEmpty) return;
    _activeFilter = null;
    _visibleDrills = List<VerbPrefixDrillItem>.unmodifiable(_allDrills);
    _currentIndex = 0;
    _resetAnswerState();
    notifyListeners();
  }

  void _resetAnswerState() {
    _selectedPlacement = null;
    _selectedConjugation = null;
    _isCorrect = null;
    _explanation = '';
  }

  String _incorrectExplanation(
    VerbPrefixDrillItem item,
    PrefixPlacement placement,
    String conjugatedVerb,
  ) {
    final selectedVerb = conjugatedVerb.trim();
    final verbCorrect =
        selectedVerb.toLowerCase() == item.expectedConjugatedVerb.toLowerCase();
    final placementCorrect = placement == item.expectedPlacement;

    if (!verbCorrect && !placementCorrect) {
      return 'يوجد خطآن: التصريف الصحيح مع ${item.subjectPronoun} هو '
          '${item.expectedConjugatedVerb}، وموضع السابقة ${item.prefix} هو '
          '${item.placementLabel}. ${item.ruleExplanation}';
    }
    if (!verbCorrect) {
      return 'موضع السابقة صحيح، لكن التصريف يحتاج تعديلًا: '
          '${item.subjectPronoun} → ${item.expectedConjugatedVerb}.';
    }
    return 'التصريف صحيح، لكن موضع السابقة ${item.prefix} غير صحيح: '
        '${item.ruleExplanation}';
  }
}
