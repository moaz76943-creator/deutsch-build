import 'dart:math' as math;

import '../../../core/srs/srs_models.dart';
import '../../../models/mistake.dart';

/// Compact learning-oriented classification used by the adaptive review policy.
enum AdaptiveErrorType { vocabulary, grammar, conjugation }

/// Immutable scheduling projection derived from the canonical mistake bank.
///
/// This value does not own persistence. The existing learner/mistake pipeline
/// remains the single source of truth for recorded attempts and mistakes.
final class AdaptiveErrorSignal {
  final String itemId;
  final AdaptiveErrorType type;
  final double priority;
  final int reviewIntervalDays;
  final DateTime nextReviewAt;

  const AdaptiveErrorSignal({
    required this.itemId,
    required this.type,
    required this.priority,
    required this.reviewIntervalDays,
    required this.nextReviewAt,
  });
}

/// Pure policy layer over the canonical [MistakeRecord] bank and SRS state.
///
/// It deliberately owns no storage and creates no second mistake repository.
/// Its only responsibility is to classify canonical errors, calculate an
/// urgency score, and shorten the next interval for struggling material.
final class AdaptiveErrorBank {
  static const double _maxPriority = 100;
  static const double _maxIntervalReduction = 0.70;

  const AdaptiveErrorBank();

  AdaptiveErrorType classify(
    MistakeRecord mistake, {
    String? skill,
  }) {
    final normalizedSkill = (skill ?? '').trim().toLowerCase();
    if (_isConjugationSkill(normalizedSkill)) {
      return AdaptiveErrorType.conjugation;
    }

    switch (mistake.category) {
      case MistakeCategory.grammar:
      case MistakeCategory.wordOrder:
      case MistakeCategory.article:
        return AdaptiveErrorType.grammar;
      case MistakeCategory.vocabulary:
      case MistakeCategory.translation:
      case MistakeCategory.writing:
      case MistakeCategory.production:
      case MistakeCategory.listening:
        return AdaptiveErrorType.vocabulary;
    }
  }

  /// Returns a deterministic 0..100 urgency score.
  ///
  /// Recurrent failures dominate, recent failures increase urgency, and an
  /// older last-seen timestamp decays the recency contribution instead of
  /// making stale records permanently outrank active problems.
  double priorityScore(
    MistakeRecord mistake, {
    DateTime? now,
  }) {
    final at = (now ?? DateTime.now()).toUtc();
    final severity = mistake.severity.clamp(0, 100).toDouble();
    final failureRate = mistake.failureRate.clamp(0.0, 1.0).toDouble();
    final recentFailureRate =
        mistake.recentFailureRate.clamp(0.0, 1.0).toDouble();
    final unresolvedErrors =
        math.max(0, mistake.errorCount - mistake.correctiveStreak);

    final daysSinceSeen = mistake.lastSeenAt == null
        ? 30
        : math.max(0, at.difference(mistake.lastSeenAt!.toUtc()).inDays);
    final recency = (1.0 - math.min(daysSinceSeen, 30) / 30.0) * 10.0;

    final raw = severity * 0.45 +
        failureRate * 20.0 +
        recentFailureRate * 15.0 +
        math.min(unresolvedErrors, 5) * 2.0 +
        recency;
    return raw.clamp(0.0, _maxPriority).toDouble();
  }

  /// Shortens the canonical SRS interval in proportion to error urgency.
  ///
  /// The result is always at least one day and never longer than the canonical
  /// interval. A priority of 100 may reduce the interval by up to 70%.
  int acceleratedIntervalDays(
    SrsItemState state,
    MistakeRecord mistake, {
    DateTime? now,
  }) {
    final canonicalInterval = math.max(1, state.intervalDays);
    final urgency = priorityScore(mistake, now: now) / _maxPriority;
    final factor = 1.0 - urgency * _maxIntervalReduction;
    final accelerated = (canonicalInterval * factor).round();
    return accelerated.clamp(1, canonicalInterval).toInt();
  }

  AdaptiveErrorSignal signalFor(
    MistakeRecord mistake,
    SrsItemState state, {
    required DateTime reviewedAtUtc,
    String? skill,
  }) {
    if (!reviewedAtUtc.isUtc) {
      throw ArgumentError('reviewedAtUtc must be in UTC');
    }

    final priority = priorityScore(mistake, now: reviewedAtUtc);
    final interval = acceleratedIntervalDays(
      state,
      mistake,
      now: reviewedAtUtc,
    );
    return AdaptiveErrorSignal(
      itemId: mistake.itemId,
      type: classify(mistake, skill: skill),
      priority: priority,
      reviewIntervalDays: interval,
      nextReviewAt: reviewedAtUtc.add(Duration(days: interval)),
    );
  }

  List<AdaptiveErrorSignal> prioritize(
    Iterable<MistakeRecord> mistakes,
    Map<String, SrsItemState> states, {
    required DateTime reviewedAtUtc,
    Map<String, String> skillByItem = const <String, String>{},
  }) {
    if (!reviewedAtUtc.isUtc) {
      throw ArgumentError('reviewedAtUtc must be in UTC');
    }

    final signals = <AdaptiveErrorSignal>[];
    for (final mistake in mistakes) {
      final state = states[mistake.itemId];
      if (state == null) continue;
      signals.add(
        signalFor(
          mistake,
          state,
          reviewedAtUtc: reviewedAtUtc,
          skill: skillByItem[mistake.itemId],
        ),
      );
    }
    signals.sort((a, b) {
      final byPriority = b.priority.compareTo(a.priority);
      if (byPriority != 0) return byPriority;
      return a.itemId.compareTo(b.itemId);
    });
    return List<AdaptiveErrorSignal>.unmodifiable(signals);
  }

  static bool _isConjugationSkill(String value) =>
      value == 'conjugation' ||
      value == 'verb_conjugation' ||
      value == 'verb-conjugation' ||
      value == 'konjugation';
}
