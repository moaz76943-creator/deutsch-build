import 'srs_models.dart';

class SrsEngine {
  static const double _minEaseFactor = 1.3;

  SrsItemState calculateNextState(
    SrsItemState currentState,
    Rating rating,
    DateTime reviewTimeUtc,
  ) {
    if (!reviewTimeUtc.isUtc) {
      throw ArgumentError('reviewTimeUtc must be in UTC');
    }

    int nextInterval = currentState.intervalDays;
    int nextRepetitions = currentState.repetitions;
    double nextEaseFactor = currentState.easeFactor;
    CardState nextState = currentState.state;

    switch (rating) {
      case Rating.again:
        nextRepetitions = 0;
        nextInterval = 1;
        nextEaseFactor -= 0.20;
        nextState = CardState.learning;
        break;
      case Rating.hard:
        if (nextRepetitions == 0) {
          nextInterval = 1;
        } else {
          nextInterval = (nextInterval * 1.2).round();
        }
        nextRepetitions++;
        nextEaseFactor -= 0.15;
        nextState = CardState.reviewing;
        break;
      case Rating.good:
        if (nextRepetitions == 0) {
          nextInterval = 1;
        } else if (nextRepetitions == 1) {
          nextInterval = 6;
        } else {
          nextInterval = (nextInterval * nextEaseFactor).round();
        }
        nextRepetitions++;
        nextState = CardState.reviewing;
        break;
      case Rating.easy:
        if (nextRepetitions == 0) {
          nextInterval = 4;
        } else if (nextRepetitions == 1) {
          nextInterval = (6 * 1.3).round();
        } else {
          nextInterval = (nextInterval * nextEaseFactor * 1.3).round();
        }
        nextRepetitions++;
        nextEaseFactor += 0.15;
        nextState = CardState.mastered; // Just mapping it logically
        break;
    }

    if (nextEaseFactor < _minEaseFactor) {
      nextEaseFactor = _minEaseFactor;
    }

    // Ensure interval is at least 1 day for any progression
    if (nextInterval < 1) {
      nextInterval = 1;
    }

    DateTime dueDate = reviewTimeUtc.add(Duration(days: nextInterval));

    return currentState.copyWith(
      intervalDays: nextInterval,
      repetitions: nextRepetitions,
      easeFactor: nextEaseFactor,
      dueDate: dueDate,
      lastReviewedDate: reviewTimeUtc,
      state: nextState,
    );
  }
}
