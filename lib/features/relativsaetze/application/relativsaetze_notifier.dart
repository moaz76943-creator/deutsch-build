import 'package:flutter/foundation.dart';

import '../domain/relativsaetze_models.dart';
import '../domain/relativsaetze_repository.dart';

final class RelativsaetzeNotifier extends ChangeNotifier {
  RelativsaetzeNotifier(this._repository);

  final RelativsaetzeRepository _repository;

  List<RelativeClauseChallengeItem> _challenges =
      const <RelativeClauseChallengeItem>[];
  RelativeClauseChallengeItem? _currentChallenge;
  List<String> _options = const <String>[];
  String? _selectedPronoun;
  bool? _isCorrect;
  String? _feedbackExplanation;
  RelativeClauseFocus? _activeFocus;
  int _currentIndex = -1;
  bool _isBusy = false;

  RelativeClauseChallengeItem? get currentChallenge => _currentChallenge;

  List<String> get options => _options;

  String? get selectedPronoun => _selectedPronoun;

  bool? get isCorrect => _isCorrect;

  String? get feedbackExplanation => _feedbackExplanation;

  RelativeClauseFocus? get activeFocus => _activeFocus;

  bool get isBusy => _isBusy;

  Future<void> nextChallenge() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      if (_challenges.isEmpty) {
        _challenges = await _repository.getChallenges(
          focus: _activeFocus,
        );
        _currentIndex = -1;
      }
      await _selectNext();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> filterByFocus(RelativeClauseFocus? focus) async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      _activeFocus = focus;
      _challenges = await _repository.getChallenges(focus: focus);
      _currentIndex = -1;
      _currentChallenge = null;
      _options = const <String>[];
      _clearAnswer();
      await _selectNext();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(
    String pronoun, [
    String? constructedSentence,
  ]) async {
    final challenge = _currentChallenge;
    if (_isBusy || challenge == null) return;

    final answer = pronoun.trim();
    if (answer.isEmpty) {
      _selectedPronoun = '';
      _isCorrect = false;
      _feedbackExplanation = 'اختر الضمير النسبي قبل التحقق.';
      notifyListeners();
      return;
    }

    _isBusy = true;
    _selectedPronoun = answer;
    notifyListeners();
    try {
      final sentence =
          constructedSentence ?? challenge.correctSentence;
      final validations = await Future.wait<bool>(<Future<bool>>[
        _repository.validatePronoun(challenge.id, answer),
        _repository.validateSentence(challenge.id, sentence),
      ]);
      final pronounCorrect = validations[0];
      final sentenceCorrect = validations[1];
      _isCorrect = pronounCorrect && sentenceCorrect;
      _feedbackExplanation = _buildFeedback(
        challenge: challenge,
        pronounCorrect: pronounCorrect,
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
      _options = const <String>[];
      _clearAnswer();
      _feedbackExplanation =
          'لا توجد تحديات Relativsätze متاحة لهذا التصنيف.';
      return;
    }

    _currentIndex = (_currentIndex + 1) % _challenges.length;
    _currentChallenge = _challenges[_currentIndex];
    _options = await _repository.getAnswerOptions(
      _currentChallenge!.id,
    );
    _clearAnswer();
  }

  void _clearAnswer() {
    _selectedPronoun = null;
    _isCorrect = null;
    _feedbackExplanation = null;
  }

  static String _buildFeedback({
    required RelativeClauseChallengeItem challenge,
    required bool pronounCorrect,
    required bool sentenceCorrect,
  }) {
    if (pronounCorrect && sentenceCorrect) {
      return challenge.arabicExplanation;
    }

    if (!pronounCorrect && !sentenceCorrect) {
      return 'الضمير وترتيب الجملة يحتاجان مراجعة. '
          '${challenge.arabicExplanation}';
    }

    if (!pronounCorrect) {
      return 'الضمير غير صحيح. الصيغة المطلوبة هنا هي '
          '${challenge.expectedPronoun}. '
          '${challenge.arabicExplanation}';
    }

    return 'الضمير صحيح، لكن ترتيب Relativsatz غير صحيح؛ '
        'تأكد من وضع الفعل المصرف في النهاية. '
        '${challenge.arabicExplanation}';
  }
}
