class DeckSummary {
  final int totalCards;
  final int dueCount;
  final int masteredCount;
  final int learningCount;

  const DeckSummary({
    required this.totalCards,
    required this.dueCount,
    required this.masteredCount,
    required this.learningCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeckSummary &&
      other.totalCards == totalCards &&
      other.dueCount == dueCount &&
      other.masteredCount == masteredCount &&
      other.learningCount == learningCount;
  }

  @override
  int get hashCode {
    return totalCards.hashCode ^
      dueCount.hashCode ^
      masteredCount.hashCode ^
      learningCount.hashCode;
  }
}
