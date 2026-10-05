import '../../models/learner.dart';
import '../memory.dart';
import 'quick_review_corpus_reader.dart';
import 'quick_review_models.dart';

/// Builds a small, due-only review working set from SRS state.
///
/// Memory remains O(K), where K is capped at [maxSessionItems]. A session
/// performs zero corpus queries when no card is due and exactly one bounded
/// indexed SQLite query when review work exists.
final class QuickReviewService {
  const QuickReviewService({
    required QuickReviewCorpusReader corpusReader,
  }) : _corpusReader = corpusReader;

  static const int defaultSessionItems = 12;
  static const int maxSessionItems = 20;

  final QuickReviewCorpusReader _corpusReader;

  Future<QuickReviewSession> buildSession({
    required Iterable<ReviewCard> reviewCards,
    DateTime? now,
    int limit = defaultSessionItems,
  }) async {
    final clock = now ?? DateTime.now();
    final safeLimit = limit.clamp(1, maxSessionItems).toInt();

    final ranked = MemoryQueue.rank(
      reviewCards.where((card) => card.facetKey.isLegacyMeaningKey),
      now: clock,
      limit: safeLimit,
    );

    if (ranked.isEmpty) {
      return QuickReviewSession(
        createdAt: clock,
        limit: safeLimit,
        cards: const <QuickReviewCard>[],
      );
    }

    final ids = ranked
        .map((card) => card.itemId.trim())
        .where((id) => id.isNotEmpty)
        .take(safeLimit)
        .toList(growable: false);

    if (ids.isEmpty) {
      return QuickReviewSession(
        createdAt: clock,
        limit: safeLimit,
        cards: const <QuickReviewCard>[],
      );
    }

    final corpusRows = await _corpusReader.fetchByIds(ids);
    final byId = <String, QuickReviewCorpusItem>{
      for (final item in corpusRows) item.id: item,
    };

    final cards = <QuickReviewCard>[];
    for (final review in ranked) {
      if (cards.length >= safeLimit) break;
      final item = byId[review.itemId.trim()];
      if (item == null) continue;

      cards.add(
        QuickReviewCard(
          contentId: item.id,
          sourceText: item.sourceText,
          translationText: item.translationText,
          exampleText: item.exampleText,
          exampleTranslationText: item.exampleTranslationText,
          grammaticalMarker: item.grammaticalMarker,
          pluralForm: item.pluralForm,
          topic: item.topic,
          skill: item.skill,
          acceptedForms: item.acceptedForms,
          dueAt: review.dueAt,
          memoryState: review.memoryState,
          reason: MemoryQueue.reason(review, now: clock),
          intervalDays: review.intervalDays,
          lapses: review.lapses,
        ),
      );
    }

    return QuickReviewSession(
      createdAt: clock,
      limit: safeLimit,
      cards: cards,
    );
  }
}
