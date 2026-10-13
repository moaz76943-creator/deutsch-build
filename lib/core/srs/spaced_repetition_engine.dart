import 'leitner_box_state.dart';

class SpacedRepetitionEngine {
  static const int _oneDayMs = 86400000;
  static const int _maxSuccesses = 1000000;

  static LeitnerCardState calculateNextInterval({
    required LeitnerCardState previousState,
    required int rating,
    int? currentTimeEpoch,
  }) {
    if (rating < 0 || rating > 3) {
      throw ArgumentError.value(rating, 'rating', 'expected 0..3');
    }
    if (!previousState.easeFactor.isFinite ||
        previousState.easeFactor <= 0 ||
        previousState.consecutiveSuccesses < 0) {
      throw ArgumentError('Invalid previous Leitner state');
    }
    final now = currentTimeEpoch ?? DateTime.now().millisecondsSinceEpoch;
    if (now < 0 || now > 4102444800000) {
      throw ArgumentError.value(now, 'currentTimeEpoch');
    }
    final ease = previousState.easeFactor.clamp(1.3, 3.0).toDouble();
    if (rating <= 1) {
      return LeitnerCardState(
        cardId: previousState.cardId,
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: now,
        nextReviewEpoch: now + _oneDayMs,
        easeFactor: (ease - 0.2).clamp(1.3, 3.0).toDouble(),
        consecutiveSuccesses: 0,
      );
    }

    final successes = previousState.consecutiveSuccesses >= _maxSuccesses
        ? _maxSuccesses
        : previousState.consecutiveSuccesses + 1;
    final boxIndex = (previousState.currentBox.index + 1)
        .clamp(0, LeitnerBox.values.length - 1).toInt();
    final intervalDays = [1, 3, 7, 14, 30][boxIndex];
    return LeitnerCardState(
      cardId: previousState.cardId,
      currentBox: LeitnerBox.values[boxIndex],
      lastReviewedEpoch: now,
      nextReviewEpoch: now + intervalDays * _oneDayMs,
      easeFactor: (ease + (rating == 3 ? 0.15 : 0.0))
          .clamp(1.3, 3.0).toDouble(),
      consecutiveSuccesses: successes,
    );
  }
}
