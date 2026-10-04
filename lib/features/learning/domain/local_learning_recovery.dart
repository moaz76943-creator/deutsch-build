import '../../../core/content_contract.dart';
import '../../../core/progress/pair_progress_models.dart';
import '../../../core/srs_facets.dart';

typedef LearningRecoveryContentLookup = LearningContent? Function(
  String conceptId,
);

enum LocalLearningRecoveryReason {
  due,
  previousErrors,
  dueAndPreviousErrors,
}

final class LocalLearningRecoveryItem {
  const LocalLearningRecoveryItem({
    required this.item,
    required this.reason,
    required this.facetType,
    required this.variantKey,
    required this.dueAt,
    required this.incorrectCount,
    required this.successRate,
  });

  final LearningContent item;
  final LocalLearningRecoveryReason reason;
  final ReviewFacetType facetType;
  final String? variantKey;
  final DateTime dueAt;
  final int incorrectCount;
  final double successRate;

  String get reviewKey => ReviewFacetKey(
        conceptId: item.id,
        facetType: facetType,
        variantKey: variantKey,
      ).storageKey;
}

final class LocalLearningRecoveryPlan {
  LocalLearningRecoveryPlan({
    required this.pairKey,
    required this.generatedAtUtc,
    required this.estimatedMinutes,
    required Iterable<LocalLearningRecoveryItem> items,
  }) : items = List<LocalLearningRecoveryItem>.unmodifiable(items);

  final String pairKey;
  final DateTime generatedAtUtc;
  final int estimatedMinutes;
  final List<LocalLearningRecoveryItem> items;
}

/// Pure, local-only recovery policy over the canonical pair progress snapshot.
///
/// It owns no persistence and never creates new SRS state. Candidates are
/// limited to already-due review cards or cards with recorded previous errors.
/// Selection memory is bounded by [maxSessionItems] rather than the size of the
/// learner history.
final class LocalLearningRecoveryPlanner {
  const LocalLearningRecoveryPlanner({
    this.minSessionItems = 4,
    this.maxSessionItems = 8,
    this.estimatedSecondsPerItem = 75,
  })  : assert(minSessionItems > 0),
        assert(maxSessionItems >= minSessionItems),
        assert(estimatedSecondsPerItem > 0);

  final int minSessionItems;
  final int maxSessionItems;
  final int estimatedSecondsPerItem;

  LocalLearningRecoveryPlan? build({
    required PairProgressSnapshot snapshot,
    required LearningRecoveryContentLookup contentLookup,
    DateTime? now,
  }) {
    final generatedAtUtc = (now ?? DateTime.now()).toUtc();
    final selected = <_RecoveryCandidate>[];
    final seenReviewKeys = <String>{};

    for (final card in snapshot.cards) {
      final review = card.reviewCard;
      if (review == null || !review.facetKey.isValid) continue;

      final isDue = !review.dueAt.toUtc().isAfter(generatedAtUtc);
      final hasPreviousErrors =
          card.incorrectCount > 0 || review.failures > 0;
      if (!isDue && !hasPreviousErrors) continue;

      final item = contentLookup(review.itemId);
      if (item == null) continue;

      final candidate = _RecoveryCandidate(
        item: item,
        reason: switch ((isDue, hasPreviousErrors)) {
          (true, true) =>
            LocalLearningRecoveryReason.dueAndPreviousErrors,
          (true, false) => LocalLearningRecoveryReason.due,
          (false, true) =>
            LocalLearningRecoveryReason.previousErrors,
          (false, false) => throw StateError('unreachable'),
        },
        facetType: review.facetType,
        variantKey: review.variantKey,
        dueAt: review.dueAt.toUtc(),
        lastReviewedAt: card.lastReviewedAt.toUtc(),
        incorrectCount: card.incorrectCount,
        failureCount: review.failures,
        successRate: review.successRate,
      );

      if (!seenReviewKeys.add(candidate.reviewKey)) continue;
      _insertBounded(selected, candidate, maxSessionItems);
    }

    if (selected.length < minSessionItems) return null;

    final items = selected
        .map((candidate) => candidate.toRecoveryItem())
        .toList(growable: false);
    final estimatedMinutes =
        ((items.length * estimatedSecondsPerItem) / 60)
            .ceil()
            .clamp(5, 10)
            .toInt();

    return LocalLearningRecoveryPlan(
      pairKey: snapshot.pairKey,
      generatedAtUtc: generatedAtUtc,
      estimatedMinutes: estimatedMinutes,
      items: items,
    );
  }

  static void _insertBounded(
    List<_RecoveryCandidate> selected,
    _RecoveryCandidate candidate,
    int limit,
  ) {
    var index = 0;
    while (index < selected.length &&
        _compare(selected[index], candidate) <= 0) {
      index += 1;
    }
    selected.insert(index, candidate);
    if (selected.length > limit) {
      selected.removeLast();
    }
  }

  static int _compare(
    _RecoveryCandidate a,
    _RecoveryCandidate b,
  ) {
    if (a.isDue != b.isDue) return a.isDue ? -1 : 1;

    if (a.isDue && b.isDue) {
      final dueAt = a.dueAt.compareTo(b.dueAt);
      if (dueAt != 0) return dueAt;
    }

    final errors = b.errorWeight.compareTo(a.errorWeight);
    if (errors != 0) return errors;

    final success = a.successRate.compareTo(b.successRate);
    if (success != 0) return success;

    final lastReviewed = a.lastReviewedAt.compareTo(b.lastReviewedAt);
    if (lastReviewed != 0) return lastReviewed;

    return a.reviewKey.compareTo(b.reviewKey);
  }
}

final class _RecoveryCandidate {
  const _RecoveryCandidate({
    required this.item,
    required this.reason,
    required this.facetType,
    required this.variantKey,
    required this.dueAt,
    required this.lastReviewedAt,
    required this.incorrectCount,
    required this.failureCount,
    required this.successRate,
  });

  final LearningContent item;
  final LocalLearningRecoveryReason reason;
  final ReviewFacetType facetType;
  final String? variantKey;
  final DateTime dueAt;
  final DateTime lastReviewedAt;
  final int incorrectCount;
  final int failureCount;
  final double successRate;

  bool get isDue => reason != LocalLearningRecoveryReason.previousErrors;
  int get errorWeight => incorrectCount + failureCount;

  String get reviewKey => ReviewFacetKey(
        conceptId: item.id,
        facetType: facetType,
        variantKey: variantKey,
      ).storageKey;

  LocalLearningRecoveryItem toRecoveryItem() {
    return LocalLearningRecoveryItem(
      item: item,
      reason: reason,
      facetType: facetType,
      variantKey: variantKey,
      dueAt: dueAt,
      incorrectCount: incorrectCount,
      successRate: successRate,
    );
  }
}
