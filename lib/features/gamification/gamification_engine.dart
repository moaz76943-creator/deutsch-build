import 'domain/gamification_models.dart';

final class _StreakResult {
  const _StreakResult(this.value, {this.freezeUsed = false});

  final int value;
  final bool freezeUsed;
}

abstract final class GamificationEngine {
  static const Duration _backwardClockTolerance = Duration(minutes: 5);
  static const Duration _monotonicClockDriftTolerance = Duration(minutes: 10);

  static GamificationTransition apply(
    GamificationProfile current,
    GamificationReviewEvent event, {
    List<MilestoneBadge> badges = GamificationMilestones.defaults,
    Set<String> alreadyUnlocked = const <String>{},
  }) {
    final eventUtc = event.occurredAtUtc.toUtc();
    final safeOffset = event.timezoneOffsetMinutes.clamp(-840, 840).toInt();
    final malformedOffset = safeOffset != event.timezoneOffsetMinutes;
    final backwardClock = current.lastReviewAtUtc != null &&
        eventUtc.isBefore(
          current.lastReviewAtUtc!.toUtc().subtract(_backwardClockTolerance),
        );
    final localDay = _dayKey(eventUtc, safeOffset);
    final localDayRegression = _isDayBefore(localDay, current.lastLocalDay);
    final stamp = event.clockIntegrityStamp;
    final malformedStamp = stamp != null && !stamp.isValid;
    final previousBootCount = current.lastBootCount;
    final previousElapsed = current.lastMonotonicElapsedMilliseconds;
    final bootCountRegression = stamp != null &&
        previousBootCount != null &&
        stamp.bootCount < previousBootCount;
    final sameBoot = stamp != null &&
        previousBootCount != null &&
        previousElapsed != null &&
        stamp.bootCount == previousBootCount;
    final monotonicRegression = sameBoot
        ? stamp.elapsedRealtimeMilliseconds < previousElapsed
        : false;
    final monotonicClockDrift = sameBoot &&
        !monotonicRegression &&
        current.lastReviewAtUtc != null &&
        _hasMonotonicClockDrift(
          previousUtc: current.lastReviewAtUtc!.toUtc(),
          currentUtc: eventUtc,
          previousElapsedMilliseconds: previousElapsed,
          currentElapsedMilliseconds: stamp.elapsedRealtimeMilliseconds,
        );

    if (malformedOffset ||
        malformedStamp ||
        backwardClock ||
        localDayRegression ||
        bootCountRegression ||
        monotonicRegression ||
        monotonicClockDrift) {
      return GamificationTransition(
        profile: GamificationProfile(
          totalXp: current.totalXp,
          currentStreak: current.currentStreak,
          longestStreak: current.longestStreak,
          lastReviewAtUtc: current.lastReviewAtUtc,
          lastLocalDay: current.lastLocalDay,
          lastTimezoneOffsetMinutes: current.lastTimezoneOffsetMinutes,
          lastMonotonicElapsedMilliseconds:
              current.lastMonotonicElapsedMilliseconds,
          lastBootCount: current.lastBootCount,
          clockAnomalyDetected: true,
          streakFreezeAvailable: current.streakFreezeAvailable,
        ),
        awardedXp: 0,
        clockAnomaly: true,
        newlyUnlocked: const <MilestoneBadge>[],
      );
    }

    final streakResult = _nextStreak(
      current.currentStreak,
      current.lastLocalDay,
      localDay,
      useFreeze: event.useStreakFreeze && current.streakFreezeAvailable,
    );
    final awardedXp = event.requestedXp.clamp(0, 100).toInt();
    final nextProfile = GamificationProfile(
      totalXp: (current.totalXp + awardedXp).clamp(0, 100000000).toInt(),
      currentStreak: streakResult.value,
      longestStreak: streakResult.value > current.longestStreak
          ? streakResult.value
          : current.longestStreak,
      lastReviewAtUtc: eventUtc,
      lastLocalDay: localDay,
      lastTimezoneOffsetMinutes: safeOffset,
      lastMonotonicElapsedMilliseconds:
          stamp != null && stamp.isValid
              ? stamp.elapsedRealtimeMilliseconds
              : current.lastMonotonicElapsedMilliseconds,
      lastBootCount:
          stamp != null && stamp.isValid
              ? stamp.bootCount
              : current.lastBootCount,
      clockAnomalyDetected: current.clockAnomalyDetected,
      streakFreezeAvailable:
          current.streakFreezeAvailable && !streakResult.freezeUsed,
    );
    final newlyUnlocked = <MilestoneBadge>[
      for (final badge in badges)
        if (!alreadyUnlocked.contains(badge.id) && badge.isReached(nextProfile))
          badge,
    ];

    return GamificationTransition(
      profile: nextProfile,
      awardedXp: awardedXp,
      clockAnomaly: false,
      newlyUnlocked: List<MilestoneBadge>.unmodifiable(newlyUnlocked),
      streakFreezeUsed: streakResult.freezeUsed,
    );
  }

  static bool _hasMonotonicClockDrift({
    required DateTime previousUtc,
    required DateTime currentUtc,
    required int previousElapsedMilliseconds,
    required int currentElapsedMilliseconds,
  }) {
    final elapsedDelta =
        currentElapsedMilliseconds - previousElapsedMilliseconds;
    if (elapsedDelta < 0) return true;

    final wallDelta =
        currentUtc.difference(previousUtc).inMilliseconds;
    final drift = (wallDelta - elapsedDelta).abs();
    return drift > _monotonicClockDriftTolerance.inMilliseconds;
  }

  static _StreakResult _nextStreak(
    int current,
    String? previousDay,
    String localDay, {
    required bool useFreeze,
  }) {
    if (previousDay == null || previousDay.isEmpty) {
      return const _StreakResult(1);
    }
    if (previousDay == localDay) {
      return _StreakResult(current <= 0 ? 1 : current);
    }

    final previous = _parseDay(previousDay);
    final next = _parseDay(localDay);
    if (previous == null || next == null) {
      return const _StreakResult(1);
    }

    final delta = next.difference(previous).inDays;
    if (delta == 1) {
      return _StreakResult(
        (current <= 0 ? 1 : current + 1).clamp(1, 10000).toInt(),
      );
    }
    if (delta == 2 && useFreeze) {
      return _StreakResult(
        (current <= 0 ? 1 : current + 1).clamp(1, 10000).toInt(),
        freezeUsed: true,
      );
    }
    if (delta <= 0) {
      return _StreakResult(current.clamp(0, 10000).toInt());
    }
    return const _StreakResult(1);
  }

  static bool _isDayBefore(String day, String? reference) {
    if (reference == null || reference.isEmpty) return false;
    final current = _parseDay(day);
    final previous = _parseDay(reference);
    if (current == null || previous == null) return false;
    return current.isBefore(previous);
  }

  static DateTime? _parseDay(String value) =>
      DateTime.tryParse('${value}T00:00:00Z');

  static String _dayKey(DateTime utc, int offsetMinutes) {
    final local = utc.add(Duration(minutes: offsetMinutes));
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
