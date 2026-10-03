import 'dart:math' as math;

import '../../core/srs/srs_models.dart';
import '../../features/learning/domain/adaptive_error_bank.dart';
import '../../models/mistake.dart';
import 'daily_streak_engine.dart';

final class AdaptiveReviewItem {
  final String itemId;
  final String displayLabel;
  final AdaptiveErrorType type;
  final double priority;
  final int reviewIntervalDays;
  final DateTime nextReviewAt;

  const AdaptiveReviewItem({
    required this.itemId,
    required this.displayLabel,
    required this.type,
    required this.priority,
    required this.reviewIntervalDays,
    required this.nextReviewAt,
  });
}

final class LearnerDashboardAnalytics {
  final double retentionRate;
  final double masteryIndex;
  final int masteredWords;
  final int currentStreakDays;
  final int trackedItems;
  final String progressBand;
  final List<AdaptiveReviewItem> dailyReview;

  const LearnerDashboardAnalytics({
    required this.retentionRate,
    required this.masteryIndex,
    required this.masteredWords,
    required this.currentStreakDays,
    required this.trackedItems,
    required this.progressBand,
    required this.dailyReview,
  });

  double get a1ToB1Progress => masteryIndex;
}

/// Read-only adaptive policy that projects canonical SRS and mistake-bank data.
///
/// Persistence remains owned by the established learning repositories. This
/// agent only derives analytics and a deterministic daily review queue.
final class AdaptiveSrsAgent {
  final AdaptiveErrorBank errorBank;
  final DailyStreakEngine streakEngine;

  const AdaptiveSrsAgent({
    this.errorBank = const AdaptiveErrorBank(),
    this.streakEngine = const DailyStreakEngine(),
  });

  LearnerDashboardAnalytics analyze({
    required Iterable<DateTime> activityTimesUtc,
    required Iterable<MistakeRecord> mistakes,
    required Map<String, SrsItemState> states,
    required DateTime nowUtc,
    int timezoneOffsetMinutes = 0,
    int reviewLimit = 10,
    Map<String, String> skillByItem = const <String, String>{},
    Map<String, String> displayLabelByItem = const <String, String>{},
  }) {
    if (!nowUtc.isUtc) {
      throw ArgumentError('nowUtc must be in UTC');
    }
    if (reviewLimit < 0) {
      throw ArgumentError.value(reviewLimit, 'reviewLimit', 'must be >= 0');
    }

    final mistakeList = List<MistakeRecord>.unmodifiable(mistakes);
    final retention = _retentionRate(mistakeList);
    final mastery = _masteryIndex(states, mistakeList, nowUtc);
    final signals = errorBank.prioritize(
      mistakeList,
      states,
      reviewedAtUtc: nowUtc,
      skillByItem: skillByItem,
    );

    final queue = <AdaptiveReviewItem>[
      for (final signal in signals.take(reviewLimit))
        AdaptiveReviewItem(
          itemId: signal.itemId,
          displayLabel: displayLabelByItem[signal.itemId] ?? signal.itemId,
          type: signal.type,
          priority: signal.priority,
          reviewIntervalDays: signal.reviewIntervalDays,
          nextReviewAt: signal.nextReviewAt,
        ),
    ];

    return LearnerDashboardAnalytics(
      retentionRate: retention,
      masteryIndex: mastery,
      masteredWords:
          states.values.where((state) => state.state == CardState.mastered).length,
      currentStreakDays: streakEngine.currentStreak(
        activityTimesUtc,
        nowUtc: nowUtc,
        timezoneOffsetMinutes: timezoneOffsetMinutes,
      ),
      trackedItems: states.length,
      progressBand: _progressBand(mastery),
      dailyReview: List<AdaptiveReviewItem>.unmodifiable(queue),
    );
  }

  double _retentionRate(List<MistakeRecord> mistakes) {
    var attempts = 0;
    var errors = 0;
    for (final mistake in mistakes) {
      attempts += math.max(0, mistake.attemptCount);
      errors += math.max(0, mistake.errorCount);
    }
    if (attempts == 0) return 1.0;
    final retained = (attempts - math.min(errors, attempts)) / attempts;
    return retained.clamp(0.0, 1.0).toDouble();
  }

  double _masteryIndex(
    Map<String, SrsItemState> states,
    List<MistakeRecord> mistakes,
    DateTime nowUtc,
  ) {
    if (states.isEmpty) return 0.0;

    double total = 0;
    for (final entry in states.entries) {
      final stateWeight = switch (entry.value.state) {
        CardState.newCard => 0.0,
        CardState.learning => 0.35,
        CardState.reviewing => 0.70,
        CardState.mastered => 1.0,
      };
      final matching = mistakes.where((m) => m.itemId == entry.key);
      final highestPenalty = matching.isEmpty
          ? 0.0
          : matching
                  .map((m) => errorBank.priorityScore(m, now: nowUtc))
                  .reduce((a, b) => math.max(a, b).toDouble()) /
              100.0;
      total += (stateWeight * (1.0 - highestPenalty * 0.35))
          .clamp(0.0, 1.0)
          .toDouble();
    }
    return (total / states.length).clamp(0.0, 1.0).toDouble();
  }

  String _progressBand(double mastery) {
    if (mastery < 1 / 3) return 'A1';
    if (mastery < 2 / 3) return 'A2';
    return 'B1';
  }
}
