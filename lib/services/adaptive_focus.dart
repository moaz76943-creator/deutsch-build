import '../models/learner.dart';
import 'mastery.dart';
import '../core/date_utils.dart';

class AdaptiveFocus {
  static String dimensionForItem(
    String itemId,
    List<Attempt> attempts, {
    ReviewCard? reviewCard,
    DateTime? now,
  }) {
    final rows =
        attempts.where((a) => a.itemId == itemId).toList(growable: false);
    return dimensionForRows(itemId, rows, reviewCard: reviewCard, now: now);
  }

  /// Same decision when the caller already grouped attempts by item.
  static String dimensionForRows(
    String itemId,
    List<Attempt> rows, {
    ReviewCard? reviewCard,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final evidence = Mastery.forItemRows(
      itemId,
      rows,
      reviewCard: reviewCard,
      now: at,
    );
    final latestByDimension = <String, DateTime>{};
    for (final a in rows) {
      final dimension = _categoryDimension(a.skill);
      final latest = latestByDimension[dimension];
      if (latest == null || a.at.isAfter(latest))
        latestByDimension[dimension] = a.at;
    }
    final scores = <String, double>{
      for (final entry in evidence.skillScores.entries)
        entry.key: _recencyAdjusted(
          entry.key,
          entry.value,
          latestByDimension,
          at,
        ),
    };
    for (final a in rows.where((x) => !x.correct)) {
      final key = _categoryDimension(a.skill);
      scores[key] = (scores[key] ?? .50) - .12;
    }
    if (scores.isEmpty) return 'recall';
    return scores.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
  }

  static double _recencyAdjusted(
    String dimension,
    double score,
    Map<String, DateTime> latestByDimension,
    DateTime now,
  ) {
    final latest = latestByDimension[dimension];
    if (latest == null) return score;
    final days = now.toUtcMidnight
        .difference(latest.toUtcMidnight)
        .inDays
        .clamp(0, 60)
        .toDouble();
    final decay = (days / 60) * .12;
    return (score - decay).clamp(0.0, 1.0).toDouble();
  }

  static String _categoryDimension(String skill) {
    switch (skill.toLowerCase()) {
      case 'listening':
        return 'listening';
      case 'production':
      case 'writing':
        return 'production';
      case 'transfer':
      case 'grammar':
        return 'transfer';
      case 'recall':
      default:
        return 'recall';
    }
  }

  static String modeFor(
    String itemId,
    List<Attempt> attempts, {
    ReviewCard? reviewCard,
    DateTime? now,
  }) {
    return dimensionForItem(itemId, attempts, reviewCard: reviewCard, now: now);
  }

  static String modeForRows(
    String itemId,
    List<Attempt> rows, {
    ReviewCard? reviewCard,
    DateTime? now,
  }) {
    return dimensionForRows(itemId, rows, reviewCard: reviewCard, now: now);
  }
}
