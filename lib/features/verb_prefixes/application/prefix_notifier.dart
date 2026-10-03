import 'package:flutter/foundation.dart';

import '../domain/prefix_models.dart';
import '../domain/prefix_repository.dart';

final class PrefixNotifier extends ChangeNotifier {
  PrefixNotifier(this._repository);

  final PrefixRepository _repository;

  List<PrefixDrillItem> _drills = const <PrefixDrillItem>[];
  VerbPrefixClass? _activeClass;
  int _currentIndex = 0;
  String _answerText = '';
  bool? _isCorrect;
  bool _showExplanation = false;
  String _feedbackAr = '';
  bool _isLoading = false;
  int _generation = 0;

  List<PrefixDrillItem> get drills =>
      List<PrefixDrillItem>.unmodifiable(_drills);
  VerbPrefixClass? get activeClass => _activeClass;
  int get currentIndex => _currentIndex;
  String get answerText => _answerText;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  String get feedbackAr => _feedbackAr;
  bool get isLoading => _isLoading;

  PrefixDrillItem? get currentDrill {
    if (_drills.isEmpty || _currentIndex >= _drills.length) return null;
    return _drills[_currentIndex];
  }

  bool get canCheck =>
      currentDrill != null &&
      _answerText.trim().isNotEmpty &&
      !_showExplanation;

  Future<void> load({VerbPrefixClass? verbClass}) async {
    final generation = ++_generation;
    _isLoading = true;
    _activeClass = verbClass;
    notifyListeners();

    try {
      final loaded = await _repository.getDrills(verbClass: verbClass);
      if (generation != _generation) return;
      _drills = List<PrefixDrillItem>.unmodifiable(loaded);
      _currentIndex = 0;
      _resetAnswerState();
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void updateAnswer(String value) {
    if (_showExplanation) return;
    _generation++;
    _answerText = value;
    _isCorrect = null;
    _feedbackAr = '';
    notifyListeners();
  }

  Future<void> checkAnswer(String answer) async {
    final drill = currentDrill;
    if (drill == null || _showExplanation) return;

    final generation = ++_generation;
    _answerText = answer.trim();
    _isCorrect = null;
    _feedbackAr = '';
    notifyListeners();

    final correct = await _repository.checkAnswer(
      drillId: drill.id,
      answer: _answerText,
    );
    if (generation != _generation || currentDrill?.id != drill.id) {
      return;
    }

    _isCorrect = correct;
    _feedbackAr = correct
        ? 'إجابة صحيحة. راقب موضع السابقة وشكل Partizip II.'
        : 'راجع ترتيب الفعل السابقة. قارن إجابتك بالنموذج والشرح.';
    _showExplanation = true;
    notifyListeners();
  }

  void nextDrill() {
    if (_drills.isEmpty || !_showExplanation) return;
    _generation++;
    _currentIndex = (_currentIndex + 1) % _drills.length;
    _resetAnswerState();
    notifyListeners();
  }

  Future<void> switchVerbClass(VerbPrefixClass verbClass) async {
    if (_activeClass == verbClass && _drills.isNotEmpty) {
      _generation++;
      _currentIndex = 0;
      _resetAnswerState();
      notifyListeners();
      return;
    }
    await load(verbClass: verbClass);
  }

  Future<void> showAllClasses() async {
    if (_activeClass == null && _drills.isNotEmpty) {
      _generation++;
      _currentIndex = 0;
      _resetAnswerState();
      notifyListeners();
      return;
    }
    await load();
  }

  void _resetAnswerState() {
    _answerText = '';
    _isCorrect = null;
    _showExplanation = false;
    _feedbackAr = '';
  }
}
