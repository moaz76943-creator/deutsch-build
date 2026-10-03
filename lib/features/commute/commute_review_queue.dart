import '../../core/content_contract.dart';
import '../../core/srs_facets.dart';
import '../../models/learner.dart';
import 'domain/commute_models.dart';

final class CommuteReviewQueueBuilder<T extends LearningContent> {
  CommuteReviewQueueBuilder(Iterable<T> corpus)
      : _itemsById = <String, T>{
          for (final item in corpus)
            if (item.id.trim().isNotEmpty) item.id.trim(): item,
        };

  final Map<String, T> _itemsById;

  List<CommuteReviewItem<T>> build(
    LearnerState state, {
    DateTime? now,
    int limit = 50,
  }) {
    final clock = now ?? DateTime.now();
    final safeLimit = limit.clamp(1, 100).toInt();
    final cards = state.reviewCards.values
        .where((card) => _supportedFacet(card.facetType))
        .where((card) => !card.dueAt.isAfter(clock))
        .toList(growable: false)
      ..sort((a, b) {
        final due = a.dueAt.compareTo(b.dueAt);
        if (due != 0) return due;
        final id = a.itemId.compareTo(b.itemId);
        if (id != 0) return id;
        return a.facetType.index.compareTo(b.facetType.index);
      });

    final result = <CommuteReviewItem<T>>[];
    for (final card in cards) {
      final item = _itemsById[card.itemId.trim()];
      if (item == null || !_hasCompleteAudioSequence(item)) continue;
      result.add(
        CommuteReviewItem<T>(
          item: item,
          facetType: card.facetType,
          variantKey: card.variantKey,
          dueAt: card.dueAt,
        ),
      );
      if (result.length >= safeLimit) break;
    }
    return List<CommuteReviewItem<T>>.unmodifiable(result);
  }

  static bool _supportedFacet(ReviewFacetType facet) =>
      facet == ReviewFacetType.meaningRecall ||
      facet == ReviewFacetType.listening;

  static bool _hasCompleteAudioSequence(LearningContent item) =>
      item.sourceText.trim().isNotEmpty &&
      item.translationText.trim().isNotEmpty &&
      item.exampleText.trim().isNotEmpty;
}
