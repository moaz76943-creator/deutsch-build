import 'package:flutter/foundation.dart';

import '../domain/comparison_models.dart';
import '../domain/comparison_repository.dart';

final class ComparisonNotifier extends ChangeNotifier {
  ComparisonNotifier(this._repository);

  final ComparisonRepository _repository;

  List<ComparisonChallengeItem> _challenges =
      const <ComparisonChallengeItem>[];
  int _currentIndex = 0;
  ComparisonDegree _targetDegree = ComparisonDegree.komparativ;
  ComparisonRuleType? _activeRuleType;
  String? _selectedAnswer;
  String? _selectedConnector;
  bool? _isCorrect;
  bool _showExplanation = false;
  bool _isLoading = false;
  int _requestGeneration = 0;

  List<ComparisonChallengeItem> get challenges =>
      List<ComparisonChallengeItem>.unmodifiable(_challenges);
  int get currentIndex => _currentIndex;
  ComparisonDegree get targetDegree => _targetDegree;
  ComparisonRuleType? get activeRuleType => _activeRuleType;
  String? get selectedAnswer => _selectedAnswer;
  String? get selectedConnector => _selectedConnector;
  bool? get isCorrect => _isCorrect;
  bool get showExplanation => _showExplanation;
  bool get isLoading => _isLoading;

  ComparisonChallengeItem? get currentChallenge {
    if (_challenges.isEmpty || _currentIndex >= _challenges.length) return null;
    return _challenges[_currentIndex];
  }

  Future<void> load({ComparisonRuleType? ruleType}) async {
    final generation = ++_requestGeneration;
    _isLoading = true;
    notifyListeners();

    final loaded = await _repository.getChallenges(ruleType: ruleType);
    if (generation != _requestGeneration) return;

    _challenges = List<ComparisonChallengeItem>.unmodifiable(loaded);
    _activeRuleType = ruleType;
    _currentIndex = 0;
    _clearAnswerState();
    _isLoading = false;
    notifyListeners();
  }

  void setTargetDegree(ComparisonDegree degree) {
    if (_targetDegree == degree) return;
    _requestGeneration++;
    _targetDegree = degree;
    _clearAnswerState();
    notifyListeners();
  }

  Future<void> checkComparisonAnswer({
    required String form,
    String? connector,
  }) async {
    final challenge = currentChallenge;
    if (challenge == null || _showExplanation) return;

    final normalizedForm = form.trim();
    final normalizedConnector = connector?.trim();
    final generation = ++_requestGeneration;

    _selectedAnswer = normalizedForm;
    _selectedConnector = normalizedConnector;
    _isCorrect = null;
    _showExplanation = false;
    notifyListeners();

    final formCorrect = await _repository.checkForm(
      challenge.id,
      _targetDegree,
      normalizedForm,
    );
    final expectedConnector = challenge.connectorFor(_targetDegree);
    final connectorCorrect = expectedConnector == null
        ? true
        : await _repository.checkConnector(
            challenge.id,
            _targetDegree,
            normalizedConnector ?? '',
          );

    if (generation != _requestGeneration ||
        currentChallenge?.id != challenge.id) {
      return;
    }

    _isCorrect = formCorrect && connectorCorrect;
    _showExplanation = true;
    notifyListeners();
  }

  void nextChallenge() {
    if (_challenges.isEmpty) return;
    _requestGeneration++;
    _currentIndex = (_currentIndex + 1) % _challenges.length;
    _clearAnswerState();
    notifyListeners();
  }

  Future<void> filterByRuleType(ComparisonRuleType? ruleType) async {
    await load(ruleType: ruleType);
  }

  void _clearAnswerState() {
    _selectedAnswer = null;
    _selectedConnector = null;
    _isCorrect = null;
    _showExplanation = false;
  }
}
