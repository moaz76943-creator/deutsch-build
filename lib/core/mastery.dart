import 'dart:math' as math;

import '../models/learner.dart';

class MasteryEvidence {
  final Map<String, double> skillScores;
  final double retention;
  final double retrievability;

  /// Confidence reflects how much evidence supports the skill scores.
  /// It is deliberately a heuristic, not a calibrated probability.
  final double confidence;
  const MasteryEvidence(
    this.skillScores,
    this.retention,
    this.retrievability, {
    this.confidence = 0,
  });
  double get overall => skillScores.isEmpty
      ? 0
      : skillScores.values.reduce((a, b) => a + b) / skillScores.length;
  bool get isMastered =>
      skillScores.length >= 4 &&
      overall >= .80 &&
      confidence >= .55 &&
      retention >= .70 &&
      retrievability >= .70;
  int get nextReviewDays {
    if (retrievability <= 0 || skillScores.isEmpty) return 0;
    if (retrievability < .45) return 0;
    if (retrievability < .60) return 1;
    if (retrievability < .75) return 2;
    if (retrievability < .85) return 4;
    return 7;
  }

  String get nextAction {
    if (retrievability < .45) return 'review';
    if (skillScores.isEmpty) return 'learn';
    final weakest =
        skillScores.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
    if ((skillScores[weakest] ?? 0) < .65) return weakest;
    if (retention < .65) return 'review';
    return 'consolidate';
  }
}

class Mastery {
  static MasteryEvidence forItem(
    String itemId,
    List<Attempt> attempts, {
    ReviewCard? reviewCard,
    DateTime? now,
  }) {
    return forItemRows(
      itemId,
      attempts.where((a) => a.itemId == itemId).toList(growable: false),
      reviewCard: reviewCard,
      now: now,
    );
  }

  /// Same mastery calculation when the caller already grouped attempts by item.
  /// This avoids an O(content × attempts) scan in dashboards and batch reports.
  static MasteryEvidence forItemRows(
    String itemId,
    List<Attempt> itemAttempts, {
    ReviewCard? reviewCard,
    DateTime? now,
  }) {
    const skills = ['recall', 'listening', 'production', 'transfer'];
    final scores = <String, double>{};
    final attemptsBySkill = <String, List<Attempt>>{};
    for (final a in itemAttempts) {
      (attemptsBySkill[a.skill] ??= <Attempt>[]).add(a);
    }
    for (final skill in skills) {
      final rows = attemptsBySkill[skill];
      if (rows == null || rows.isEmpty) continue;
      final recent = rows.length > 8 ? rows.sublist(rows.length - 8) : rows;
      var weight = 1.0;
      var total = 0.0;
      var score = 0.0;
      for (final a in recent.reversed) {
        score += (a.correct ? 1 : 0) * weight * (a.hinted ? .85 : 1);
        total += weight;
        weight *= .94;
      }
      const priorWeight = 2.0;
      scores[skill] =
          total == 0 ? 0 : (score + priorWeight * .50) / (total + priorWeight);
    }
    final at = now ?? DateTime.now();
    final retention = _retention(reviewCard);
    final retrievability = _retrievability(reviewCard, at);
    final evidenceCount = itemAttempts.length.clamp(0, 40).toDouble();
    final confidence = evidenceCount <= 0
        ? 0.0
        : (1 - math.exp(-evidenceCount / 8)).clamp(0.0, 1.0).toDouble();
    return MasteryEvidence(
      scores,
      retention,
      retrievability,
      confidence: confidence,
    );
  }

  static double retentionForCard(ReviewCard? card) => _retention(card);

  static double _retention(ReviewCard? card) {
    if (card == null) return 0;
    final attempts = card.successes + card.failures;
    final observed = attempts <= 0 ? .50 : card.successRate;
    // Small samples are pulled gently toward a neutral prior instead of
    // allowing one or two successes to masquerade as durable retention.
    const priorWeight = 2.0;
    final evidenceWeight = attempts.toDouble();
    final smoothed = ((observed * evidenceWeight) + (.50 * priorWeight)) /
        (evidenceWeight + priorWeight);
    final intervalDurability = (card.intervalDays.clamp(0, 30) / 30).toDouble();
    final stabilityDurability =
        (card.stabilityDays.clamp(0, 30) / 30).toDouble();
    final durability = intervalDurability * .40 + stabilityDurability * .60;
    final lapseRecovery =
        math.exp(-card.lapses.clamp(0, 12) / 4).clamp(0.0, 1.0).toDouble();
    return (smoothed * .55 + durability * .35 + lapseRecovery * .10)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static double _retrievability(ReviewCard? card, DateTime now) {
    if (card == null || card.lastReviewedAt == null || card.stabilityDays <= 0)
      return 0;
    final elapsed =
        math.max(0, now.difference(card.lastReviewedAt!).inMinutes) / (60 * 24);
    return math.exp(-elapsed / card.stabilityDays).clamp(0.0, 1.0).toDouble();
  }
}
