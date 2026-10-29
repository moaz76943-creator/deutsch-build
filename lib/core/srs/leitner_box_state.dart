enum LeitnerBox { box1, box2, box3, box4, box5 }

class LeitnerCardState {
  final String cardId;
  final LeitnerBox currentBox;
  final int lastReviewedEpoch;
  final int nextReviewEpoch;
  final double easeFactor;
  final int consecutiveSuccesses;

  // Permit reading legacy persisted records; validate before scheduling.
  const LeitnerCardState({
    required this.cardId,
    required this.currentBox,
    required this.lastReviewedEpoch,
    required this.nextReviewEpoch,
    this.easeFactor = 2.5,
    this.consecutiveSuccesses = 0,
  });

  bool get isDueForReview =>
      isDueAt(DateTime.now().millisecondsSinceEpoch);

  bool isDueAt(int currentEpoch) => currentEpoch >= nextReviewEpoch;
}
