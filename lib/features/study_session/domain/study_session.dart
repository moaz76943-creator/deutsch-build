import 'models.dart';

class StudySession {
  final String sessionId;
  final DateTime startTime;
  final int dailyNewCardsQuota;
  final int dailyReviewLimit;

  final List<Flashcard> activeQueue = [];
  final List<Flashcard> completedCards = [];

  int currentCardIndex = 0;
  int _correctAnswers = 0;

  int get correctAnswers => _correctAnswers;

  StudySession({
    required this.sessionId,
    required this.startTime,
    this.dailyNewCardsQuota = 10,
    this.dailyReviewLimit = 50,
  });

  void startSession({
    required List<Flashcard> dueCards,
    required List<Flashcard> newCards,
  }) {
    activeQueue.clear();
    completedCards.clear();
    currentCardIndex = 0;
    _correctAnswers = 0;

    final reviewCardsToTake = dueCards.take(dailyReviewLimit).toList();
    final newCardsToTake = newCards.take(dailyNewCardsQuota).toList();

    activeQueue.addAll(reviewCardsToTake);
    activeQueue.addAll(newCardsToTake);
  }

  Flashcard? submitAnswer({required Flashcard card, required Rating rating}) {
    if (activeQueue.isEmpty || currentCardIndex >= activeQueue.length) {
      return null;
    }

    if (activeQueue[currentCardIndex].id != card.id) {
      throw ArgumentError(
        'Submitted card does not match the current card in the queue',
      );
    }

    if (rating == Rating.good || rating == Rating.easy) {
      _correctAnswers++;
      completedCards.add(activeQueue[currentCardIndex]);
    } else {
      // Re-add to the end of the queue for reviewing again
      activeQueue.add(activeQueue[currentCardIndex]);
    }

    currentCardIndex++;

    if (currentCardIndex < activeQueue.length) {
      return activeQueue[currentCardIndex];
    }

    return null; // session finished
  }

  SessionResult calculateSessionResult({DateTime? endTime}) {
    final end = endTime ?? DateTime.now();
    final timeSpentSeconds = end.difference(startTime).inSeconds;

    final totalReviewed = currentCardIndex;
    final accuracyPercentage =
        totalReviewed == 0 ? 0.0 : (_correctAnswers / totalReviewed) * 100.0;

    return SessionResult(
      totalReviewed: totalReviewed,
      accuracyPercentage: accuracyPercentage,
      timeSpentSeconds: timeSpentSeconds,
    );
  }
}
