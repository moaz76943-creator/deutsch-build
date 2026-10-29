enum Rating { again, hard, good, easy }

enum CardState { newCard, learning, reviewing, mastered }

class SrsItemState {
  final int intervalDays;
  final int repetitions;
  final double easeFactor;
  final DateTime dueDate;
  final DateTime? lastReviewedDate;
  final CardState state;

  const SrsItemState({
    required this.intervalDays,
    required this.repetitions,
    this.easeFactor = 2.5,
    required this.dueDate,
    this.lastReviewedDate,
    required this.state,
  });

  SrsItemState copyWith({
    int? intervalDays,
    int? repetitions,
    double? easeFactor,
    DateTime? dueDate,
    DateTime? lastReviewedDate,
    CardState? state,
  }) {
    return SrsItemState(
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      dueDate: dueDate ?? this.dueDate,
      lastReviewedDate: lastReviewedDate ?? this.lastReviewedDate,
      state: state ?? this.state,
    );
  }
}
