import 'dart:math' as math;

/// Learner review grade rating.
enum ReviewRating {
  blackout, // 0 - total failure
  difficult, // 1 - retrieved with intense hesitation
  good, // 2 - retrieved with slight delay
  instantMastery, // 3 - effortless recall
}

/// Spaced repetition state incorporating stability, retrievability, and non-linear lapse penalties.
class MemoryState {
  final double stability; // Days until R drops to 90%
  final double difficulty; // 1.0 (trivial) to 10.0 (maximum difficulty)
  final double retrievability; // Probability of recall today (0.0 to 1.0)
  final int reps;
  final int lapses;
  final int nextIntervalDays;

  const MemoryState({
    required this.stability,
    required this.difficulty,
    required this.retrievability,
    required this.reps,
    required this.lapses,
    required this.nextIntervalDays,
  });

  factory MemoryState.initial() => const MemoryState(
        stability: 1.0,
        difficulty: 5.0,
        retrievability: 1.0,
        reps: 0,
        lapses: 0,
        nextIntervalDays: 1,
      );
}

/// Hybrid SM-18 and FSRS continuous interval calculator.
class Sm18HybridScheduler {
  final double desiredRetention;

  const Sm18HybridScheduler({this.desiredRetention = 0.90});

  /// Calculates the current retrievability given days elapsed since last review.
  double estimateRetrievability(double stability, int daysElapsed) {
    if (stability <= 0.0) return 0.0;
    // Forgetting curve: R = (1 + factor * t / S)^(-power)
    return math.exp(-0.10536 * daysElapsed / stability).clamp(0.0, 1.0);
  }

  /// Evaluates memory update after a review event.
  MemoryState review({
    required MemoryState previousState,
    required ReviewRating rating,
    required int daysElapsed,
  }) {
    double s = previousState.stability;
    double d = previousState.difficulty;
    int reps = previousState.reps + 1;
    int lapses = previousState.lapses;

    switch (rating) {
      case ReviewRating.blackout:
        lapses++;
        // Non-linear lapse penalty
        s = math.max(0.5, s * 0.25);
        d = math.min(10.0, d + 1.5);
        break;
      case ReviewRating.difficult:
        s = s * (1.0 + (0.5 / d));
        d = math.min(10.0, d + 0.5);
        break;
      case ReviewRating.good:
        s = s * (1.0 + (2.2 / math.sqrt(d)));
        d = math.max(1.0, d - 0.2);
        break;
      case ReviewRating.instantMastery:
        s = s * (1.0 + (3.8 / math.sqrt(d)));
        d = math.max(1.0, d - 0.6);
        break;
    }

    // Interval to reach target desired retention
    final nextInterval = (-s * math.log(desiredRetention) / 0.10536).round();
    final clampedInterval = math.max(1, nextInterval);

    return MemoryState(
      stability: double.parse(s.toStringAsFixed(3)),
      difficulty: double.parse(d.toStringAsFixed(2)),
      retrievability: 1.0,
      reps: reps,
      lapses: lapses,
      nextIntervalDays: clampedInterval,
    );
  }
}
