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
  final double curriculumProgress;
  final int masteredWords;
  final int currentStreakDays;
  final int trackedItems;
  final String progressBand;
  final List<AdaptiveReviewItem> dailyReview;

  const LearnerDashboardAnalytics({
    required this.retentionRate,
    required this.masteryIndex,
    required this.curriculumProgress,
    required this.masteredWords,
    required this.currentStreakDays,
    required this.trackedItems,
    required this.progressBand,
    required this.dailyReview,
  });

  double get a1ToB1Progress => curriculumProgress;
}

/// Read-only adaptive policy over canonical SRS, attempts, and mistake evidence.
///
/// Persistence remains owned by the established learner repositories. The agent
/// derives analytics and a deterministic due-only daily review queue.
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
    required int totalAttempts,
    required int correctAttempts,
    required Map<String, String> curriculumLevelByItem,
    required Set<String> masteredItemIds,
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
    if (totalAttempts < 0 || correctAttempts < 0) {
      throw ArgumentError('attempt counts must be non-negative');
    }
    if (correctAttempts > totalAttempts) {
      throw ArgumentError('correctAttempts cannot exceed totalAttempts');
    }

    final mistakeList = List<MistakeRecord>.unmodifiable(mistakes);
    final mastery = _masteryIndex(states, mistakeList, nowUtc);
    final dueMistakes = <MistakeRecord>[
      for (final mistake in mistakeList)
        if (_isDue(states[mistake.itemId], nowUtc)) mistake,
    ];
    final signals = errorBank.prioritize(
      dueMistakes,
      states,
      reviewedAtUtc: nowUtc,
      skillByItem: skillByItem,
    );
    final curriculum =
        _curriculumProgress(curriculumLevelByItem, masteredItemIds);

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
      retentionRate:
          totalAttempts == 0 ? 0.0 : correctAttempts / totalAttempts,
      masteryIndex: mastery,
      curriculumProgress: curriculum.progress,
      masteredWords: masteredItemIds.length,
      currentStreakDays: streakEngine.currentStreak(
        activityTimesUtc,
        nowUtc: nowUtc,
        timezoneOffsetMinutes: timezoneOffsetMinutes,
      ),
      trackedItems: states.length,
      progressBand: curriculum.band,
      dailyReview: List<AdaptiveReviewItem>.unmodifiable(queue),
    );
  }

  bool _isDue(SrsItemState? state, DateTime nowUtc) =>
      state != null && !state.dueDate.toUtc().isAfter(nowUtc);

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

  _CurriculumProgress _curriculumProgress(
    Map<String, String> levelByItem,
    Set<String> masteredItemIds,
  ) {
    final eligible = levelByItem.entries.where(
      (entry) => const {'A1', 'A2', 'B1'}.contains(entry.value),
    );
    final totals = <String, int>{'A1': 0, 'A2': 0, 'B1': 0};
    final mastered = <String, int>{'A1': 0, 'A2': 0, 'B1': 0};
    var total = 0;
    var masteredTotal = 0;

    for (final entry in eligible) {
      totals[entry.value] = (totals[entry.value] ?? 0) + 1;
      total++;
      if (masteredItemIds.contains(entry.key)) {
        mastered[entry.value] = (mastered[entry.value] ?? 0) + 1;
        masteredTotal++;
      }
    }

    if (total == 0) {
      return const _CurriculumProgress(progress: 0, band: 'A1');
    }

    double coverage(String level) {
      final denominator = totals[level] ?? 0;
      if (denominator == 0) return 0;
      return (mastered[level] ?? 0) / denominator;
    }

    final band = coverage('A1') < .80
        ? 'A1'
        : coverage('A2') < .80
            ? 'A2'
            : 'B1';
    return _CurriculumProgress(
      progress: (masteredTotal / total).clamp(0.0, 1.0).toDouble(),
      band: band,
    );
  }
}

final class _CurriculumProgress {
  final double progress;
  final String band;

  const _CurriculumProgress({
    required this.progress,
    required this.band,
  });
}
