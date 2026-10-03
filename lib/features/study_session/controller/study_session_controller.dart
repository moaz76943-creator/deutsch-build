import 'package:flutter/foundation.dart';

import '../domain/study_session.dart';
import '../domain/models.dart';
import '../domain/cognitive_overload_shield.dart';

class StudySessionController extends ChangeNotifier {
  final StudySession session;
  final CognitiveOverloadShield shield;

  bool _isPaused = false;
  String? _interventionPrompt;

  StudySessionController({
    required this.session,
    CognitiveOverloadShield? shield,
  }) : shield = shield ?? const CognitiveOverloadShield();

  bool get isPaused => _isPaused;
  String? get interventionPrompt => _interventionPrompt;
  Flashcard? get currentCard {
    if (session.activeQueue.isEmpty ||
        session.currentCardIndex >= session.activeQueue.length) {
      return null;
    }
    return session.activeQueue[session.currentCardIndex];
  }

  void startSession({
    required List<Flashcard> dueCards,
    required List<Flashcard> newCards,
  }) {
    session.startSession(dueCards: dueCards, newCards: newCards);
    _isPaused = false;
    _interventionPrompt = null;
    notifyListeners();
  }

  void submitAnswer(Rating rating) {
    if (_isPaused || currentCard == null) return;

    session.submitAnswer(card: currentCard!, rating: rating);

    if (shield.isOverloaded(
      totalAnswers: session.currentCardIndex,
      correctAnswers: session.correctAnswers,
    )) {
      _isPaused = true;
      _interventionPrompt =
          'You seem to be getting tired. Let\'s take a short break to rest your mind and cement what you\'ve learned.';
    }

    notifyListeners();
  }

  void resumeSession() {
    if (!_isPaused) return;

    _isPaused = false;
    _interventionPrompt = null;
    notifyListeners();
  }
}
