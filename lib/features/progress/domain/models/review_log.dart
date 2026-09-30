class ReviewLog {
  final String id;
  final String cardId;
  final int rating;
  final DateTime reviewTimestamp;
  final int scheduledInterval;
  final int durationSeconds;

  const ReviewLog({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.reviewTimestamp,
    required this.scheduledInterval,
    required this.durationSeconds,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReviewLog &&
      other.id == id &&
      other.cardId == cardId &&
      other.rating == rating &&
      other.reviewTimestamp == reviewTimestamp &&
      other.scheduledInterval == scheduledInterval &&
      other.durationSeconds == durationSeconds;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      cardId.hashCode ^
      rating.hashCode ^
      reviewTimestamp.hashCode ^
      scheduledInterval.hashCode ^
      durationSeconds.hashCode;
  }
}
