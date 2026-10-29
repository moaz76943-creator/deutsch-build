enum LeitnerBox { box1, box2, box3, box4, box5 }

class LeitnerCardState {
  final String cardId;
  final LeitnerBox currentBox;
  final int lastReviewedEpoch;
  final int nextReviewEpoch;
  final double easeFactor;
  final int consecutiveSuccesses;

  const LeitnerCardState({
    required this.cardId,
    required this.currentBox,
    required this.lastReviewedEpoch,
    required this.nextReviewEpoch,
    this.easeFactor = 2.5,
    this.consecutiveSuccesses = 0,
  })  : assert(easeFactor >= 0, 'easeFactor cannot be negative or NaN'),
        assert(consecutiveSuccesses >= 0,
            'consecutiveSuccesses cannot be negative');

<<<<<<< HEAD
  bool get isDueForReview => isDueAt(DateTime.now().millisecondsSinceEpoch);

  bool isDueAt(int nowEpoch) => nowEpoch >= nextReviewEpoch;
=======
  bool get isDueForReview =>
      DateTime.now().millisecondsSinceEpoch >= nextReviewEpoch;
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
}
