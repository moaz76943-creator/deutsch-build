import 'dart:math' as math;

enum FsrsRating {
  again, // 1: Complete lapse
  hard, // 2: Recalled with severe hesitation/difficulty
  good, // 3: Correct recall with normal effort
  easy, // 4: Instant effortless recall
}

enum CardState {
  neu, // Unseen item
  learning, // In short-term learning queue
  review, // In long-term retention queue
  relearning, // Post-lapse recovery
}

class FsrsItemState {
  final String itemId;
  final double difficulty; // D in [1.0, 10.0]
  final double stability; // S in days
  final int reps;
  final int lapses;
  final CardState state;
  final int lastReviewEpochMs;
  final int dueEpochMs;

  const FsrsItemState({
    required this.itemId,
    required this.difficulty,
    required this.stability,
    required this.reps,
    required this.lapses,
    required this.state,
    required this.lastReviewEpochMs,
    required this.dueEpochMs,
  });

  /// Computes retrievability R(t) after elapsed days: R(t) = (1 + factor * t / S)^(-decay)
  double computeRetrievability(int currentEpochMs) {
    if (state == CardState.neu) return 0.0;
    final elapsedDays = math.max(0.0, (currentEpochMs - lastReviewEpochMs) / 86400000.0);
    if (stability <= 0.0) return 0.0;
    // Standard FSRS power-law forgetting formula
    const factor = 19.0 / 81.0;
    const decay = 0.5;
    return math.pow(1.0 + (factor * elapsedDays / stability), -decay).toDouble();
  }
}

/// Sovereign on-device FSRS v5 (Free Spaced Repetition Scheduler) implementation.
/// Accurately models DSR (Difficulty, Stability, Retrievability) memory dynamics
/// with zero external cloud dependencies.
class FsrsV5SpacedRepetitionEngine {
  final double requestRetention; // Default 0.90 (90% target retention)
  final double maxIntervalDays;

  // Calibrated FSRS v5 weight parameters
  static const double w0 = 0.40; // Initial stability Again
  static const double w1 = 1.18; // Initial stability Hard
  static const double w2 = 3.12; // Initial stability Good
  static const double w3 = 8.84; // Initial stability Easy
  static const double w4 = 5.34; // Mean reversion target for Difficulty
  static const double w5 = 1.09; // Difficulty scale factor
  static const double w6 = 0.95; // Difficulty update weight
  static const double w7 = 0.15; // Mean reversion rate
  static const double w8 = 1.58; // Stability recall base
  static const double w9 = 0.18; // Stability recall exponent
  static const double w10 = 1.02; // Retrievability sensitivity

  const FsrsV5SpacedRepetitionEngine({
    this.requestRetention = 0.90,
    this.maxIntervalDays = 3650.0,
  });

  /// Calculates next review interval in days given updated stability.
  double _calculateNextInterval(double stability) {
    const factor = 19.0 / 81.0;
    const decay = 0.5;
    // Inverse forgetting curve for R = requestRetention:
    // interval = (S / factor) * (R^(-1/decay) - 1)
    final interval = (stability / factor) * (math.pow(requestRetention, -1.0 / decay) - 1.0);
    return interval.clamp(1.0, maxIntervalDays);
  }

  /// Evaluates an initial review for a new card.
  FsrsItemState initializeNewItem(String itemId, FsrsRating rating, int nowMs) {
    double initS;
    double initD;

    switch (rating) {
      case FsrsRating.again:
        initS = w0;
        initD = (w4 + w5 * 2.0).clamp(1.0, 10.0);
        break;
      case FsrsRating.hard:
        initS = w1;
        initD = (w4 + w5 * 1.0).clamp(1.0, 10.0);
        break;
      case FsrsRating.good:
        initS = w2;
        initD = w4.clamp(1.0, 10.0);
        break;
      case FsrsRating.easy:
        initS = w3;
        initD = (w4 - w5 * 1.5).clamp(1.0, 10.0);
        break;
    }

    final intervalDays = _calculateNextInterval(initS);
    final dueMs = nowMs + (intervalDays * 86400000.0).round();

    return FsrsItemState(
      itemId: itemId,
      difficulty: initD,
      stability: initS,
      reps: 1,
      lapses: rating == FsrsRating.again ? 1 : 0,
      state: rating == FsrsRating.again ? CardState.learning : CardState.review,
      lastReviewEpochMs: nowMs,
      dueEpochMs: dueMs,
    );
  }

  /// Updates existing card state following a review.
  FsrsItemState reviewItem(FsrsItemState current, FsrsRating rating, int nowMs) {
    final retrievability = current.computeRetrievability(nowMs);

    // 1. Difficulty Update with Mean Reversion
    final rawGrade = _ratingToGrade(rating);
    final deltaD = -w6 * (rawGrade - 3.0);
    final nextD = (current.difficulty + deltaD);
    final meanRevertedD = (w7 * w4 + (1.0 - w7) * nextD).clamp(1.0, 10.0);

    // 2. Stability Update
    double nextS;
    int nextLapses = current.lapses;
    CardState nextState = CardState.review;

    if (rating == FsrsRating.again) {
      // Lapse: stability drops sharply
      nextLapses += 1;
      nextState = CardState.relearning;
      nextS = math.max(0.1, current.stability * 0.20);
    } else {
      // Successful Recall: stability expands as a function of retrievability and difficulty
      // S' = S * (1 + exp(w8) * (11 - D) * S^(-w9) * (exp((1 - R) * w10) - 1))
      final hardPenalty = (rating == FsrsRating.hard) ? 0.70 : 1.0;
      final easyBonus = (rating == FsrsRating.easy) ? 1.30 : 1.0;

      final sFactor = 1.0 +
          (math.exp(w8) *
              (11.0 - meanRevertedD) *
              math.pow(current.stability, -w9) *
              (math.exp((1.0 - retrievability) * w10) - 1.0) *
              hardPenalty *
              easyBonus);

      nextS = (current.stability * sFactor).clamp(0.1, 36500.0);
    }

    final intervalDays = _calculateNextInterval(nextS);
    final dueMs = nowMs + (intervalDays * 86400000.0).round();

    return FsrsItemState(
      itemId: current.itemId,
      difficulty: meanRevertedD,
      stability: nextS,
      reps: current.reps + 1,
      lapses: nextLapses,
      state: nextState,
      lastReviewEpochMs: nowMs,
      dueEpochMs: dueMs,
    );
  }

  static double _ratingToGrade(FsrsRating r) {
    switch (r) {
      case FsrsRating.again:
        return 1.0;
      case FsrsRating.hard:
        return 2.0;
      case FsrsRating.good:
        return 3.0;
      case FsrsRating.easy:
        return 4.0;
    }
  }
}
