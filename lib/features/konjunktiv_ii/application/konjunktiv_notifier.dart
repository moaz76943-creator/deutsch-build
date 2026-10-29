import 'package:flutter/foundation.dart';

import '../domain/konjunktiv_models.dart';
import '../domain/konjunktiv_repository.dart';

final class KonjunktivNotifier extends ChangeNotifier {
  KonjunktivNotifier(this._repository);

  final KonjunktivRepository _repository;

  List<KonjunktivChallengeItem> _challenges =
      const <KonjunktivChallengeItem>[];
  KonjunktivChallengeItem? _currentChallenge;
  List<String> _options = const <String>[];
  String? _selectedAnswer;
  bool? _isCorrect;
  String? _feedbackExplanation;
  KonjunktivUsage? _activeUsage;
  int _currentIndex = -1;
  bool _isBusy = false;

  KonjunktivChallengeItem? get currentChallenge => _currentChallenge;

  List<String> get options => _options;

  String? get selectedAnswer => _selectedAnswer;

  bool? get isCorrect => _isCorrect;

  String? get feedbackExplanation => _feedbackExplanation;

  KonjunktivUsage? get activeUsage => _activeUsage;

  bool get isBusy => _isBusy;

  Future<void> nextChallenge() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      if (_challenges.isEmpty) {
        _challenges = await _repository.getChallenges(
          usage: _activeUsage,
        );
        _currentIndex = -1;
      }
      await _selectNextFromLoaded();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> filterByUsage(KonjunktivUsage? usage) async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      _activeUsage = usage;
      _challenges = await _repository.getChallenges(usage: usage);
      _currentIndex = -1;
      _currentChallenge = null;
      _options = const <String>[];
      _clearAnswerState();
      await _selectNextFromLoaded();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> checkKonjunktivAnswer(
    String conjugatedForm, [
    String? constructedSentence,
  ]) async {
    if (_isBusy) return;
    final challenge = _currentChallenge;
    if (challenge == null) return;

    final answer = conjugatedForm.trim();
    if (answer.isEmpty) {
      _selectedAnswer = '';
      _isCorrect = false;
      _feedbackExplanation = 'اختر صيغة قبل التحقق.';
      notifyListeners();
      return;
    }

    _isBusy = true;
    _selectedAnswer = answer;
    notifyListeners();
    try {
      final sentence =
          constructedSentence ?? challenge.konjunktivSentence;
      final results = await Future.wait<bool>(<Future<bool>>[
        _repository.validateConjugation(challenge.id, answer),
        _repository.validateSentence(challenge.id, sentence),
      ]);
      final formCorrect = results[0];
      final sentenceCorrect = results[1];
      _isCorrect = formCorrect && sentenceCorrect;
      _feedbackExplanation = _feedbackFor(
        challenge: challenge,
        formCorrect: formCorrect,
        sentenceCorrect: sentenceCorrect,
      );
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _selectNextFromLoaded() async {
    if (_challenges.isEmpty) {
      _currentChallenge = null;
      _options = const <String>[];
      _clearAnswerState();
      _feedbackExplanation =
          'لا توجد تحديات متاحة لهذا التصنيف حالياً.';
      return;
    }

    _currentIndex = (_currentIndex + 1) % _challenges.length;
    _currentChallenge = _challenges[_currentIndex];
    _options = await _repository.getAnswerOptions(
      _currentChallenge!.id,
    );
    _clearAnswerState();
  }

  void _clearAnswerState() {
    _selectedAnswer = null;
    _isCorrect = null;
    _feedbackExplanation = null;
  }

  String _feedbackFor({
    required KonjunktivChallengeItem challenge,
    required bool formCorrect,
    required bool sentenceCorrect,
  }) {
    if (formCorrect && sentenceCorrect) {
      return challenge.arabicExplanation;
    }

    if (!formCorrect && !sentenceCorrect) {
      return 'التصريف وتركيب الجملة يحتاجان مراجعة. '
          '${challenge.arabicExplanation}';
    }

    if (!formCorrect) {
      final expected =
          _options.isEmpty ? 'الصيغة الصحيحة' : _options.first;
      return 'الصيغة المختارة غير صحيحة؛ راجع ${expected}. '
          '${challenge.arabicExplanation}';
    }

    return 'التصريف صحيح، لكن ترتيب الجملة لا يطابق الصياغة المستهدفة. '
        '${challenge.arabicExplanation}';
  }
}
