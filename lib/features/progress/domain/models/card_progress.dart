import 'srs_item_state.dart';

class CardProgress {
  final String cardId;
  final SrsItemState srsItemState;
  final int totalViews;
  final int successCount;
  final int failureCount;
  final DateTime? firstReviewedAt;
  final DateTime? lastReviewedAt;

  const CardProgress({
    required this.cardId,
    required this.srsItemState,
    required this.totalViews,
    required this.successCount,
    required this.failureCount,
    this.firstReviewedAt,
    this.lastReviewedAt,
  });

  CardProgress copyWith({
    String? cardId,
    SrsItemState? srsItemState,
    int? totalViews,
    int? successCount,
    int? failureCount,
    DateTime? firstReviewedAt,
    DateTime? lastReviewedAt,
  }) {
    return CardProgress(
      cardId: cardId ?? this.cardId,
      srsItemState: srsItemState ?? this.srsItemState,
      totalViews: totalViews ?? this.totalViews,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      firstReviewedAt: firstReviewedAt ?? this.firstReviewedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CardProgress &&
        other.cardId == cardId &&
        other.srsItemState == srsItemState &&
        other.totalViews == totalViews &&
        other.successCount == successCount &&
        other.failureCount == failureCount &&
        other.firstReviewedAt == firstReviewedAt &&
        other.lastReviewedAt == lastReviewedAt;
  }

  @override
  int get hashCode {
    return cardId.hashCode ^
        srsItemState.hashCode ^
        totalViews.hashCode ^
        successCount.hashCode ^
        failureCount.hashCode ^
        firstReviewedAt.hashCode ^
        lastReviewedAt.hashCode;
  }
}
