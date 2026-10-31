import '../../../core/content_contract.dart';
import '../../../core/srs_facets.dart';

final class CommuteReviewItem<T extends LearningContent> {
  const CommuteReviewItem({
    required this.item,
    required this.facetType,
    required this.variantKey,
    required this.dueAt,
  });

  final T item;
  final ReviewFacetType facetType;
  final String? variantKey;
  final DateTime dueAt;

  bool get isListening => facetType == ReviewFacetType.listening;
}

enum CommutePlaybackStage {
  targetTerm,
  sourceMeaning,
  targetExample,
  completed,
  cancelled,
}

final class CommutePlaybackReport {
  const CommutePlaybackReport._({
    required this.completed,
    required this.stage,
    this.reason,
  });

  const CommutePlaybackReport.completed()
      : this._(completed: true, stage: CommutePlaybackStage.completed);

  const CommutePlaybackReport.cancelled()
      : this._(
          completed: false,
          stage: CommutePlaybackStage.cancelled,
          reason: 'commute_playback_cancelled',
        );

  const CommutePlaybackReport.failed(CommutePlaybackStage stage, String reason)
      : this._(completed: false, stage: stage, reason: reason);

  final bool completed;
  final CommutePlaybackStage stage;
  final String? reason;

  bool get failed => !completed && stage != CommutePlaybackStage.cancelled;
}
