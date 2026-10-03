import '../../../core/content_contract.dart';
import '../../../core/memory.dart';
import '../../../models/learner.dart';

enum DailyDrillStatus { idle, active, completed }

final class FlashcardReviewItem {
  const FlashcardReviewItem({
    required this.item,
    required this.dueAt,
    required this.memoryState,
    required this.successRate,
    required this.reviewReason,
  });

  final LearningContent item;
  final DateTime dueAt;
  final MemoryState memoryState;
  final double successRate;
  final MemoryReviewReason reviewReason;
}

final class DailyDrillSession {
  DailyDrillSession({
    required this.id,
    required this.startedAt,
    required Iterable<FlashcardReviewItem> items,
    this.targetCount = 10,
  }) : items = List<FlashcardReviewItem>.unmodifiable(items) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (targetCount < 1 || targetCount > 20) {
      throw ArgumentError.value(targetCount, 'targetCount', 'must be 1..20');
    }
    if (this.items.length > targetCount) {
      throw ArgumentError('items cannot exceed targetCount');
    }
  }

  final String id;
  final DateTime startedAt;
  final List<FlashcardReviewItem> items;
  final int targetCount;

  bool get isEmpty => items.isEmpty;
}

final class DrillResultSummary {
  const DrillResultSummary({
    required this.reviewedCards,
    required this.correctCards,
    required this.totalSeconds,
    required this.currentStreak,
    required this.sessionXp,
  });

  final int reviewedCards;
  final int correctCards;
  final int totalSeconds;
  final int currentStreak;
  final int sessionXp;

  double get accuracy =>
      reviewedCards == 0 ? 0 : correctCards / reviewedCards;

  double get averageSecondsPerCard =>
      reviewedCards == 0 ? 0 : totalSeconds / reviewedCards;
}

final class DailyDrillReviewReceipt {
  const DailyDrillReviewReceipt({
    required this.currentStreak,
    required this.sessionXp,
  });

  final int currentStreak;
  final int sessionXp;
}
