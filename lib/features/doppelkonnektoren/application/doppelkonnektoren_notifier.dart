import 'package:flutter/foundation.dart';

import '../domain/doppelkonnektoren_models.dart';
import '../domain/doppelkonnektoren_repository.dart';

final class DoppelkonnektorenNotifier extends ChangeNotifier {
  DoppelkonnektorenNotifier(this._repository);

  final DoppelkonnektorenRepository _repository;

  List<DoppelConnectorChallengeItem> _challenges =
      const <DoppelConnectorChallengeItem>[];
  DoppelConnectorChallengeItem? _currentChallenge;
  List<String> _connectorOptions = const <String>[];
  String? _selectedConnector;
  bool? _isCorrect;
  String? _feedbackExplanation;
  DoppelConnectorType? _activeType;
  int _currentIndex = -1;
  bool _isBusy = false;

  DoppelConnectorChallengeItem? get currentChallenge => _currentChallenge;

  List<String> get connectorOptions => _connectorOptions;

  String? get selectedConnector => _selectedConnector;

  bool? get isCorrect => _isCorrect;

  String? get feedbackExplanation => _feedbackExplanation;

  DoppelConnectorType? get activeType => _activeType;

  bool get isBusy => _isBusy;

  Future<void> nextChallenge() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      if (_challenges.isEmpty) {
        _challenges = await _repository.getChallenges(
          type: _activeType,
        );
        _currentIndex = -1;
      }
      await _selectNext();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> filterByType(DoppelConnectorType? type) async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      _activeType = type;
      _challenges = await _repository.getChallenges(type: type);
      _currentIndex = -1;
      _currentChallenge = null;
      _connectorOptions = const <String>[];
      _clearAnswerState();
      await _selectNext();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(
    String connectorFormula, [
    String? constructedSentence,
  ]) async {
    final challenge = _currentChallenge;
    if (_isBusy || challenge == null) return;

    final selected = connectorFormula.trim();
    if (selected.isEmpty) {
      _selectedConnector = '';
      _isCorrect = false;
      _feedbackExplanation = 'اختر الرابط المزدوج قبل التحقق.';
      notifyListeners();
      return;
    }

    final selectedType = _typeForFormula(selected);
    _isBusy = true;
    _selectedConnector = selected;
    notifyListeners();
    try {
      final sentence =
          constructedSentence ?? challenge.correctSentence;
      final pairCorrect = selectedType != null &&
          await _repository.validateConnectorPair(
            challenge.id,
            selectedType.firstPart,
            selectedType.secondPart,
          );
      final sentenceCorrect = await _repository.validateSentence(
        challenge.id,
        sentence,
      );
      _isCorrect = pairCorrect && sentenceCorrect;
      _feedbackExplanation = _buildFeedback(
        challenge: challenge,
        pairCorrect: pairCorrect,
        sentenceCorrect: sentenceCorrect,
      );
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _selectNext() async {
    if (_challenges.isEmpty) {
      _currentChallenge = null;
      _connectorOptions = const <String>[];
      _clearAnswerState();
      _feedbackExplanation =
          'لا توجد تحديات Doppelkonnektoren متاحة لهذا التصنيف.';
      return;
    }

    _currentIndex = (_currentIndex + 1) % _challenges.length;
    _currentChallenge = _challenges[_currentIndex];
    _connectorOptions = await _repository.getConnectorOptions(
      _currentChallenge!.id,
    );
    _clearAnswerState();
  }

  void _clearAnswerState() {
    _selectedConnector = null;
    _isCorrect = null;
    _feedbackExplanation = null;
  }

  static DoppelConnectorType? _typeForFormula(String value) {
    final normalized = _normalizeFormula(value);
    for (final type in DoppelConnectorType.values) {
      if (_normalizeFormula(type.formula) == normalized) return type;
    }
    return null;
  }

  static String _normalizeFormula(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('...', '…')
      .replaceAll(RegExp(r'\s+'), ' ');

  static String _buildFeedback({
    required DoppelConnectorChallengeItem challenge,
    required bool pairCorrect,
    required bool sentenceCorrect,
  }) {
    if (pairCorrect && sentenceCorrect) {
      return challenge.arabicExplanation;
    }

    if (!pairCorrect && !sentenceCorrect) {
      return 'اختيار الرابط وبنية الجملة يحتاجان مراجعة. '
          '${challenge.arabicExplanation}';
    }

    if (!pairCorrect) {
      return 'الرابط الصحيح هنا هو ${challenge.type.formula}. '
          '${challenge.arabicExplanation}';
    }

    return 'الرابط صحيح، لكن ترتيب الجملة لا يطابق البنية المستهدفة. '
        '${challenge.arabicExplanation}';
  }
}
