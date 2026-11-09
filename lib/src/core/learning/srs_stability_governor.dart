import 'dart:math';

/// Memory state of a learning card in the Spaced Repetition System.
class SrsCardState {
  final String cardId;
  int repetitionCount;
  double stabilityDays;
  double difficulty;
  DateTime lastReviewUtc;

  SrsCardState({
    required this.cardId,
    this.repetitionCount = 0,
    this.stabilityDays = 1.0,
    this.difficulty = 0.3,
    DateTime? lastReviewUtc,
  }) : lastReviewUtc = lastReviewUtc ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() => {
        'id': cardId,
        'reps': repetitionCount,
        'stability': stabilityDays,
        'difficulty': difficulty,
        'last_review': lastReviewUtc.toIso8601String(),
      };
}

/// Spaced repetition scheduling governor based on retrievability decay.
/// Bounds review interval leaps to prevent schedule clustering.
class SrsStabilityGovernor {
  final double requestRetention;
  final int maxIntervalDays;

  SrsStabilityGovernor({
    this.requestRetention = 0.90,
    this.maxIntervalDays = 180,
  });

  /// Compute retrievability R(t) = exp(ln(requestRetention) * (t / S)).
  double computeRetrievability(SrsCardState card, DateTime asOfUtc) {
    final elapsedDays = asOfUtc.difference(card.lastReviewUtc).inMilliseconds / (1000 * 86400);
    if (elapsedDays <= 0) return 1.0;
    final factor = log(requestRetention);
    return exp(factor * (elapsedDays / card.stabilityDays)).clamp(0.0, 1.0);
  }

  /// Update card stability following a review rating (1 = fail, 2 = hard, 3 = good, 4 = easy).
  SrsCardState processReview(SrsCardState current, int rating) {
    if (rating < 1 || rating > 4) {
      throw ArgumentError('Rating must be between 1 and 4');
    }

    final newCard = SrsCardState(
      cardId: current.cardId,
      repetitionCount: current.repetitionCount + 1,
      difficulty: current.difficulty,
      lastReviewUtc: DateTime.now().toUtc(),
    );

    if (rating == 1) {
      // Lapse: drop stability
      newCard.stabilityDays = 0.5;
      newCard.difficulty = min(1.0, current.difficulty + 0.15);
    } else {
      // Successful recall: scale stability
      final ratingMultiplier = (rating == 2) ? 1.2 : (rating == 3 ? 2.5 : 3.5);
      final newStability = current.stabilityDays * ratingMultiplier * (1.0 - current.difficulty * 0.3);
      newCard.stabilityDays = min(maxIntervalDays.toDouble(), max(1.0, newStability));

      if (rating == 4) {
        newCard.difficulty = max(0.1, current.difficulty - 0.05);
      }
    }

    return newCard;
  }
}
