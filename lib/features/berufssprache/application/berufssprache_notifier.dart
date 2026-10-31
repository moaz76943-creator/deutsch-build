import 'package:flutter/foundation.dart';

import '../domain/berufssprache_models.dart';

final class BerufsspracheNotifier extends ChangeNotifier {
  BerufsspracheNotifier({required BerufsspracheRepository repository})
      : _repository = repository;

  final BerufsspracheRepository _repository;

  List<WorkplacePhrase> _phrases = const <WorkplacePhrase>[];
  WorkplaceTopic? _activeTopic;
  int _currentIndex = -1;
  bool _isBusy = false;
  bool _showArabic = true;
  bool? _lastAnswerCorrect;
  String? _feedbackArabic;

  List<WorkplacePhrase> get phrases => _phrases;
  WorkplaceTopic? get activeTopic => _activeTopic;
  bool get isBusy => _isBusy;
  bool get showArabic => _showArabic;
  bool? get lastAnswerCorrect => _lastAnswerCorrect;
  String? get feedbackArabic => _feedbackArabic;

  WorkplacePhrase? get currentPhrase {
    if (_currentIndex < 0 || _currentIndex >= _phrases.length) return null;
    return _phrases[_currentIndex];
  }

  Future<void> load() async {
    if (_isBusy) return;
    _setBusy(true);
    try {
      _phrases = await _repository.getPhrases(topic: _activeTopic);
      _activateFirstOrEmpty();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> filterByTopic(WorkplaceTopic? topic) async {
    if (_isBusy) return;
    _setBusy(true);
    try {
      _activeTopic = topic;
      _phrases = await _repository.getPhrases(topic: topic);
      _activateFirstOrEmpty();
    } finally {
      _setBusy(false);
    }
  }

  void nextPhrase() {
    if (_phrases.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _phrases.length;
    _resetAnswerState();
    notifyListeners();
  }

  void toggleArabic() {
    _showArabic = !_showArabic;
    notifyListeners();
  }

  Future<void> checkGerman(String candidate) async {
    final phrase = currentPhrase;
    if (phrase == null) {
      throw StateError('No active Berufssprache phrase.');
    }
    if (candidate.trim().isEmpty) {
      throw ArgumentError.value(candidate, 'candidate', 'must not be empty');
    }

    _setBusy(true);
    try {
      final correct = await _repository.validateGermanPhrase(
        phrase.id,
        candidate,
      );
      _lastAnswerCorrect = correct;
      _feedbackArabic = correct
          ? 'مطابقة صحيحة للصياغة المهنية.'
          : 'راجع الصياغة الألمانية وعلامات الأدب المهني في البطاقة.';
    } finally {
      _setBusy(false);
    }
  }

  void clearAnswer() {
    _resetAnswerState();
    notifyListeners();
  }

  void _activateFirstOrEmpty() {
    _currentIndex = _phrases.isEmpty ? -1 : 0;
    _resetAnswerState();
  }

  void _resetAnswerState() {
    _lastAnswerCorrect = null;
    _feedbackArabic = null;
  }

  void _setBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    notifyListeners();
  }
}
