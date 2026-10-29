import 'package:flutter/foundation.dart';

import '../domain/passiv_models.dart';
import '../domain/passiv_repository.dart';

final class PassivNotifier extends ChangeNotifier {
  PassivNotifier(this._repository);

  final PassivRepository _repository;

  List<PassivDrillItem> _drills = const <PassivDrillItem>[];
  PassivType? _activeType;
  int _currentIndex = 0;
  String? _selectedAuxiliary;
  String? _selectedPreposition;
  String? _selectedPartizipII;
  bool? _isCorrect;
  bool _showExplanation = false;
  bool _isLoading = false;
  int _generation = 0;

  List<PassivDrillItem> get drills =>
      List<PassivDrillItem>.unmodifiable(_drills);
  PassivType? get activeType => _activeType;
  int get currentIndex => _currentIndex;
  String? get selectedAuxiliary => _selectedAuxiliary;
  String? get selectedPreposition => _selectedPreposition;
  String? get selectedPartizipII => _selectedPartizipII;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  bool get isLoading => _isLoading;

  PassivDrillItem? get currentDrill {
    if (_drills.isEmpty || _currentIndex >= _drills.length) return null;
    return _drills[_currentIndex];
  }

  List<String> get auxiliaryOptions {
    final current = currentDrill;
    if (current == null) return const <String>[];
    return _options(
      correct: current.auxiliaryForm,
      candidates: _drills.map((item) => item.auxiliaryForm),
      limit: 4,
    );
  }

  List<String> get prepositionOptions => const <String>['von', 'durch'];

  List<String> get partizipOptions {
    final current = currentDrill;
    if (current == null) return const <String>[];
    return _options(
      correct: current.partizipII,
      candidates: _drills.map((item) => item.partizipII),
      limit: 4,
    );
  }

  bool get canCheck =>
      currentDrill != null &&
      _selectedAuxiliary != null &&
      _selectedPreposition != null &&
      _selectedPartizipII != null &&
      !_showExplanation;

  Future<void> load({PassivType? type}) async {
    final generation = ++_generation;
    _isLoading = true;
    _activeType = type;
    notifyListeners();

    try {
      final loaded = await _repository.getDrills(type: type);
      if (generation != _generation) return;
      _drills = List<PassivDrillItem>.unmodifiable(loaded);
      _currentIndex = 0;
      _clearAnswerState();
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void selectAuxiliary(String value) {
    if (_showExplanation || currentDrill == null) return;
    _generation++;
    _selectedAuxiliary = value.trim();
    _isCorrect = null;
    notifyListeners();
  }

  void selectPreposition(String value) {
    if (_showExplanation || currentDrill == null) return;
    _generation++;
    _selectedPreposition = value.trim().toLowerCase();
    _isCorrect = null;
    notifyListeners();
  }

  void selectPartizipII(String value) {
    if (_showExplanation || currentDrill == null) return;
    _generation++;
    _selectedPartizipII = value.trim();
    _isCorrect = null;
    notifyListeners();
  }

  Future<void> checkTransformation({
    required String auxiliaryForm,
    required String agentPreposition,
    required String partizipII,
  }) async {
    final drill = currentDrill;
    if (drill == null || _showExplanation) return;

    final generation = ++_generation;
    _selectedAuxiliary = auxiliaryForm.trim();
    _selectedPreposition = agentPreposition.trim().toLowerCase();
    _selectedPartizipII = partizipII.trim();
    _isCorrect = null;
    notifyListeners();

    final correct = await _repository.checkTransformation(
      drillId: drill.id,
      auxiliaryForm: _selectedAuxiliary!,
      agentPreposition: _selectedPreposition!,
      partizipII: _selectedPartizipII!,
    );
    if (generation != _generation || currentDrill?.id != drill.id) return;

    _isCorrect = correct;
    _showExplanation = true;
    notifyListeners();
  }

  void nextDrill() {
    if (_drills.isEmpty || !_showExplanation) return;
    _generation++;
    _currentIndex = (_currentIndex + 1) % _drills.length;
    _clearAnswerState();
    notifyListeners();
  }

  Future<void> switchPassivType(PassivType type) async {
    if (_activeType == type && _drills.isNotEmpty) {
      _generation++;
      _currentIndex = 0;
      _clearAnswerState();
      notifyListeners();
      return;
    }
    await load(type: type);
  }

  void _clearAnswerState() {
    _selectedAuxiliary = null;
    _selectedPreposition = null;
    _selectedPartizipII = null;
    _isCorrect = null;
    _showExplanation = false;
  }

  static List<String> _options({
    required String correct,
    required Iterable<String> candidates,
    required int limit,
  }) {
    final unique = <String>{correct};
    for (final candidate in candidates) {
      if (unique.length >= limit) break;
      unique.add(candidate);
    }
    final options = unique.toList(growable: false)..sort();
    return List<String>.unmodifiable(options);
  }
}
