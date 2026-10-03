class SpacedRepetitionItem {
  final String id;
  final double ef;
  final int repetitions;
  final int intervalDays;
  final DateTime nextReviewAt;

  const SpacedRepetitionItem({
    required this.id,
    required this.ef,
    required this.repetitions,
    required this.intervalDays,
    required this.nextReviewAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ef': ef,
      'repetitions': repetitions,
      'intervalDays': intervalDays,
      'nextReviewAt': nextReviewAt.toUtc().toIso8601String(),
    };
  }

  factory SpacedRepetitionItem.fromMap(Map<String, dynamic> map) {
    return SpacedRepetitionItem(
      id: map['id'] as String,
      ef: map['ef'] as double,
      repetitions: map['repetitions'] as int,
      intervalDays: map['intervalDays'] as int,
      nextReviewAt: DateTime.parse(map['nextReviewAt'] as String).toUtc(),
    );
  }
}

class SpacedRepetitionService {
  /// Calculates the next review parameters using the SuperMemo-2 (SM-2) algorithm.
  ///
  /// [item] The current SpacedRepetitionItem, or null if this is the first review.
  /// [itemId] The ID of the item being reviewed.
  /// [quality] User rating from 0 to 5.
  ///   0 - Complete blackout.
  ///   1 - Incorrect response; the correct one remembered.
  ///   2 - Incorrect response; where the correct one seemed easy to recall.
  ///   3 - Correct response recalled with serious difficulty.
  ///   4 - Correct response after a hesitation.
  ///   5 - Perfect response.
  static SpacedRepetitionItem calculateNextReview({
    SpacedRepetitionItem? item,
    required String itemId,
    required int quality,
  }) {
    if (quality < 0 || quality > 5) {
      throw ArgumentError('Quality must be between 0 and 5.');
    }

    int repetitions = item?.repetitions ?? 0;
    double ef = item?.ef ?? 2.5;
    int intervalDays = item?.intervalDays ?? 0;

    if (quality >= 3) {
      if (repetitions == 0) {
        intervalDays = 1;
      } else if (repetitions == 1) {
        intervalDays = 6;
      } else {
        intervalDays = (intervalDays * ef).round();
      }
      repetitions++;
    } else {
      repetitions = 0;
      intervalDays = 1;
    }

    ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (ef < 1.3) {
      ef = 1.3;
    }

    final nextReviewAt = DateTime.now().toUtc().add(
          Duration(days: intervalDays),
        );

    return SpacedRepetitionItem(
      id: itemId,
      ef: ef,
      repetitions: repetitions,
      intervalDays: intervalDays,
      nextReviewAt: nextReviewAt,
    );
  }
}
