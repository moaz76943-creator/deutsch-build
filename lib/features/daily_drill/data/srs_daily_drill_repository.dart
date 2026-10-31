import '../../../core/content_contract.dart';
import '../../../core/memory.dart';
import '../../../models/learner.dart';
import '../domain/daily_drill_models.dart';
import '../domain/daily_drill_repository.dart';

final class SrsDailyDrillRepository implements DailyDrillRepository {
  const SrsDailyDrillRepository();

  @override
  List<FlashcardReviewItem> dueReviews({
    required LearnerState state,
    required Iterable<LearningContent> corpus,
    required DateTime now,
    int limit = 10,
  }) {
    final safeLimit = limit.clamp(1, 20).toInt();
    final contentById = <String, LearningContent>{
      for (final item in corpus) item.id: item,
    };

    final ranked = MemoryQueue.rank(
      state.meaningReviewCards,
      now: now,
      limit: safeLimit,
    );

    final result = <FlashcardReviewItem>[];
    for (final card in ranked) {
      final item = contentById[card.itemId];
      if (item == null) continue;
      result.add(
        FlashcardReviewItem(
          item: item,
          dueAt: card.dueAt,
          memoryState: card.memoryState,
          successRate: card.successRate,
          reviewReason: MemoryQueue.reason(card, now: now),
        ),
      );
    }
    return List<FlashcardReviewItem>.unmodifiable(result);
  }
}
