import 'dart:math' as math;

/// Represents an overdue flashcard or vocabulary item.
class OverdueItem {
  final String id;
  final String term;
  final double stability;
  final double difficulty;
  final int daysOverdue;

  const OverdueItem({
    required this.id,
    required this.term,
    required this.stability,
    required this.difficulty,
    required this.daysOverdue,
  });
}

/// The personalized smooth recovery plan generated for a returning learner.
class ResumptionPlan {
  final int daysInactive;
  final int totalBacklog;
  final int immediateWarmupQuota;
  final int dailySmoothedQuota;
  final int recoveryPeriodDays;
  final List<OverdueItem> dayOneBatch;
  final Map<int, List<String>> deferredSchedule;
  final String encouragingMessage;
  final bool isGraceStreakAwarded;

  const ResumptionPlan({
    required this.daysInactive,
    required this.totalBacklog,
    required this.immediateWarmupQuota,
    required this.dailySmoothedQuota,
    required this.recoveryPeriodDays,
    required this.dayOneBatch,
    required this.deferredSchedule,
    required this.encouragingMessage,
    required this.isGraceStreakAwarded,
  });

  Map<String, dynamic> toJson() => {
    'daysInactive': daysInactive,
    'totalBacklog': totalBacklog,
    'immediateWarmupQuota': immediateWarmupQuota,
    'dailySmoothedQuota': dailySmoothedQuota,
    'recoveryPeriodDays': recoveryPeriodDays,
    'dayOneBatchCount': dayOneBatch.length,
    'deferredDaysCount': deferredSchedule.keys.length,
    'encouragingMessage': encouragingMessage,
    'isGraceStreakAwarded': isGraceStreakAwarded,
  };
}

/// Compassionate Resumption Engine ensures learners returning after an absence
/// never face demoralizing review backlogs or shaming mechanics.
class CompassionateResumptionEngine {
  final int maxImmediateDayOne;
  final int minWarmupItems;

  const CompassionateResumptionEngine({
    this.maxImmediateDayOne = 20,
    this.minWarmupItems = 5,
  });

  /// Evaluates learner absence and decomposes backlog into a compassionate resumption plan.
  ResumptionPlan generatePlan({
    required int daysInactive,
    required List<OverdueItem> backlog,
    required int previousStreak,
  }) {
    if (daysInactive <= 1 || backlog.isEmpty) {
      return ResumptionPlan(
        daysInactive: daysInactive,
        totalBacklog: backlog.length,
        immediateWarmupQuota: math.min(backlog.length, maxImmediateDayOne),
        dailySmoothedQuota: backlog.length,
        recoveryPeriodDays: 1,
        dayOneBatch: List.from(backlog),
        deferredSchedule: {},
        encouragingMessage: 'Welcome back! You are completely on track.',
        isGraceStreakAwarded: false,
      );
    }

    // Sort backlog: High stability (confidence anchors) first, then lower difficulty
    final sortedBacklog = List<OverdueItem>.from(backlog)
      ..sort((a, b) {
        final stabilityComp = b.stability.compareTo(a.stability);
        if (stabilityComp != 0) return stabilityComp;
        return a.difficulty.compareTo(b.difficulty);
      });

    // Determine recovery window based on absence length and backlog size
    final int recoveryDays = math.min(14, math.max(3, (daysInactive / 2).ceil()));
    final int targetDayOne = math.min(maxImmediateDayOne, math.max(minWarmupItems, (backlog.length / recoveryDays).ceil()));

    final dayOneItems = sortedBacklog.take(targetDayOne).toList();
    final remainingItems = sortedBacklog.skip(targetDayOne).toList();

    // Distribute remaining items across subsequent days
    final Map<int, List<String>> deferred = {};
    if (remainingItems.isNotEmpty) {
      final int remainingDays = recoveryDays - 1;
      final int perDay = (remainingItems.length / remainingDays).ceil();

      for (int i = 0; i < remainingItems.length; i++) {
        final dayIndex = 2 + (i ~/ perDay);
        deferred.putIfAbsent(dayIndex, () => []).add(remainingItems[i].id);
      }
    }

    // Streak protection: award grace resumption if streak was notable
    final bool graceStreak = previousStreak >= 3 && daysInactive >= 3;

    final message = _craftCompassionateMessage(daysInactive, backlog.length, targetDayOne);

    return ResumptionPlan(
      daysInactive: daysInactive,
      totalBacklog: backlog.length,
      immediateWarmupQuota: targetDayOne,
      dailySmoothedQuota: (backlog.length / recoveryDays).ceil(),
      recoveryPeriodDays: recoveryDays,
      dayOneBatch: dayOneItems,
      deferredSchedule: deferred,
      encouragingMessage: message,
      isGraceStreakAwarded: graceStreak,
    );
  }

  String _craftCompassionateMessage(int daysInactive, int totalBacklog, int dayOneTarget) {
    if (daysInactive >= 30) {
      return 'Long time no see! Memory does not vanish; it just rests. We have condensed your $totalBacklog cards into just $dayOneTarget warm-up items today.';
    } else if (daysInactive >= 7) {
      return 'Life happens, and learning bends to fit your life. Take $dayOneTarget easy steps today to rekindle your flow.';
    } else {
      return 'Welcome back! We smoothed your queue so you can ease right back in with zero stress.';
    }
  }
}
