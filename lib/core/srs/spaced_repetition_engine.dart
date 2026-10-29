import 'leitner_box_state.dart';

class SpacedRepetitionEngine {
  static const int _oneDayMs = 86400000;

  static LeitnerCardState calculateNextInterval({
    required LeitnerCardState previousState,
    required int rating,
<<<<<<< HEAD
    int? currentTimeMs,
  }) {
    if (rating < 0 || rating > 3) {
      throw ArgumentError('Invalid rating: must be between 0 and 3');
    }
    if (previousState.easeFactor.isNaN) {
      throw ArgumentError('previousState.easeFactor cannot be NaN');
    }

    final now = currentTimeMs ?? DateTime.now().millisecondsSinceEpoch;

    // Prevent duplicate review processing (debounce within 1 minute)
    if (now - previousState.lastReviewedEpoch < 60000) {
      return previousState;
    }
=======
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
>>>>>>> origin/staging/v2-full-platform-1792367411258400957

    if (rating <= 1) {
      return LeitnerCardState(
        cardId: previousState.cardId,
        currentBox: LeitnerBox.box1,
        lastReviewedEpoch: now,
        nextReviewEpoch: now + (1 * _oneDayMs),
        easeFactor: (previousState.easeFactor - 0.2).clamp(1.3, 3.0),
        consecutiveSuccesses: 0,
      );
    }

    final newSuccesses = previousState.consecutiveSuccesses + 1;
<<<<<<< HEAD
    final nextBoxIndex = (previousState.currentBox.index + 1)
        .clamp(0, LeitnerBox.values.length - 1);
=======
    final nextBoxIndex = (previousState.currentBox.index + 1).clamp(0, LeitnerBox.values.length - 1);
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    final intervalDays = [1, 3, 7, 14, 30][nextBoxIndex];

    return LeitnerCardState(
      cardId: previousState.cardId,
      currentBox: LeitnerBox.values[nextBoxIndex],
      lastReviewedEpoch: now,
      nextReviewEpoch: now + (intervalDays * _oneDayMs),
<<<<<<< HEAD
      easeFactor: (previousState.easeFactor + (rating == 3 ? 0.15 : 0.0))
          .clamp(1.3, 3.0),
=======
      easeFactor: (previousState.easeFactor + (rating == 3 ? 0.15 : 0.0)).clamp(1.3, 3.0),
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
      consecutiveSuccesses: newSuccesses,
    );
  }
}
