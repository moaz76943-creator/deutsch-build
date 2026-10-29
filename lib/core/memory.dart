import '../models/learner.dart';
import 'srs.dart';

class MemoryQueue {
  static List<ReviewCard> rank(
    Iterable<ReviewCard> cards, {
    DateTime? now,
    int limit = 30,
  }) {
    final at = now ?? DateTime.now();
    final unique = <String, ReviewCard>{for (final c in cards) c.itemId: c};
    final boundedLimit = limit < 1 ? 1 : (limit > 100 ? 100 : limit);
    final scored = <ReviewCard, double>{};
    final top = <ReviewCard>[];
    for (final card in unique.values) {
      if (card.dueAt.isAfter(at)) continue;
      scored[card] = priority(card, at);
      final score = scored[card]!;
      var insertAt = top.length;
      for (var i = 0; i < top.length; i++) {
        final existingScore = scored[top[i]]!;
        if (score > existingScore ||
            (score == existingScore &&
                card.itemId.compareTo(top[i].itemId) < 0)) {
          insertAt = i;
          break;
        }
      }
      if (insertAt < boundedLimit) {
        top.insert(insertAt, card);
        if (top.length > boundedLimit) top.removeLast();
      }
    }
    return top;
  }

  static double priority(ReviewCard card, DateTime now) {
    if (card.dueAt.isAfter(now)) return 0;
    final overdueHours = now.difference(card.dueAt).inMinutes / 60;
    return 100 +
        overdueHours * 2 +
        card.lapses * 14 +
        (card.difficulty - 1) * 20 +
        (card.failures * 2) +
        Srs.reviewPriority(card, now: now) * 45;
  }

  static MemoryReviewReason reason(ReviewCard card, {DateTime? now}) {
    final at = now ?? DateTime.now();
    if (Srs.retrievability(card, now: at) < .45 && card.lastReviewedAt != null)
      return MemoryReviewReason.overdue;
    if (card.lapses > 0 && card.repetitions == 0)
      return MemoryReviewReason.lapse;
    if (card.dueAt.isBefore(at.subtract(const Duration(days: 1))))
      return MemoryReviewReason.overdue;
    if (card.memoryState == MemoryState.mature)
      return MemoryReviewReason.consolidation;
    return MemoryReviewReason.due;
  }
}

enum MemoryReviewReason { overdue, lapse, due, consolidation }

class MemorySnapshot {
  final int total, dueNow, overdue, mature, learning, relearning;
  final double retentionEstimate;
  const MemorySnapshot({
    required this.total,
    required this.dueNow,
    required this.overdue,
    required this.mature,
    required this.learning,
    required this.relearning,
    required this.retentionEstimate,
  });

  factory MemorySnapshot.from(Iterable<ReviewCard> cards, {DateTime? now}) {
    final at = now ?? DateTime.now();
    var total = 0;
    var due = 0;
    var overdue = 0;
    var mature = 0;
    var learning = 0;
    var relearning = 0;
    var retentionSum = 0.0;
    final overdueCutoff = at.subtract(const Duration(days: 1));
    for (final c in cards) {
      total++;
      if (!c.dueAt.isAfter(at)) due++;
      if (c.dueAt.isBefore(overdueCutoff)) overdue++;
      if (c.memoryState == MemoryState.mature) mature++;
      if (c.memoryState == MemoryState.learning ||
          c.memoryState == MemoryState.young) learning++;
      if (c.memoryState == MemoryState.relearning) relearning++;
      final intervalRatio = c.intervalDays / 30;
      final interval =
          intervalRatio < 0 ? 0.0 : (intervalRatio > 1 ? 1.0 : intervalRatio);
      final history = c.successRate;
      final lapsePenalty = (c.lapses * .05) > .35 ? .35 : (c.lapses * .05);
      retentionSum += (history * .65 + interval * .35 - lapsePenalty)
          .clamp(0, 1)
          .toDouble();
    }
    final retention = total == 0 ? 0.0 : retentionSum / total;
    return MemorySnapshot(
      total: total,
      dueNow: due,
      overdue: overdue,
      mature: mature,
      learning: learning,
      relearning: relearning,
      retentionEstimate: retention,
    );
  }
}
