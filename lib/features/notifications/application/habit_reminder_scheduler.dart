import '../domain/notification_contracts.dart';
import '../domain/notification_models.dart';

final class HabitReminderPlan {
  const HabitReminderPlan({
    required this.effectiveReminderMinutes,
    required this.items,
  });

  final int effectiveReminderMinutes;
  final List<ScheduledNotificationItem> items;
}

final class HabitReminderScheduler {
  HabitReminderScheduler(this._scheduler);

  static const int quietStartMinutes = 22 * 60;
  static const int quietEndMinutes = 7 * 60;
  static const int fallbackDaytimeMinutes = 8 * 60;

  final NotificationSchedulerFacade _scheduler;

  Future<HabitReminderPlan> reschedule({
    required NotificationPreference preference,
    required Iterable<DateTime> activityTimesUtc,
    required DateTime nowUtc,
    required int timezoneOffsetMinutes,
    int currentStreak = 0,
  }) async {
    if (!nowUtc.isUtc) {
      throw ArgumentError('nowUtc must be UTC');
    }
    await _scheduler.initialize();
    final safeOffset =
        timezoneOffsetMinutes.clamp(-840, 840).toInt();
    final activities = activityTimesUtc
        .where((value) => value.isUtc)
        .toList(growable: false);

    final effectiveMinutes = _effectiveReminderMinutes(
      preference,
      activities,
      safeOffset,
    );

    final items = <ScheduledNotificationItem>[];
    if (preference.dailyReminderEnabled) {
      items.add(
        ScheduledNotificationItem(
          id: 41001,
          title: 'وقت الألمانية',
          body: 'جلسة قصيرة اليوم تحافظ على تقدمك.',
          scheduledAtLocal: _nextLocalOccurrence(
            nowUtc,
            safeOffset,
            effectiveMinutes,
          ),
          tone: preference.tone,
          repeatDaily: true,
          payload: 'habit_daily',
        ),
      );
    }

    if (preference.streakAlertEnabled && currentStreak > 0) {
      final streakMinutes = _safeStreakMinutes(effectiveMinutes);
      items.add(
        ScheduledNotificationItem(
          id: 41002,
          title: 'حافظ على سلسلتك',
          body: 'سلسلتك الحالية $currentStreak يوم. مراجعة قصيرة تكفي.',
          scheduledAtLocal: _nextLocalOccurrence(
            nowUtc,
            safeOffset,
            streakMinutes,
          ),
          tone: preference.tone,
          repeatDaily: true,
          payload: 'streak_guard',
        ),
      );
    }

    if (items.isEmpty) {
      await _scheduler.cancelAll();
    } else {
      await _scheduler.replaceSchedule(items);
    }

    return HabitReminderPlan(
      effectiveReminderMinutes: effectiveMinutes,
      items: List<ScheduledNotificationItem>.unmodifiable(items),
    );
  }

  int _effectiveReminderMinutes(
    NotificationPreference preference,
    List<DateTime> activitiesUtc,
    int offsetMinutes,
  ) {
    if (activitiesUtc.length < 3) {
      return _avoidQuietHours(preference.preferredReminderMinutes);
    }

    final counts = <int, int>{};
    for (final utc in activitiesUtc) {
      final local = utc.add(Duration(minutes: offsetMinutes));
      final minute = local.hour * 60 + local.minute;
      final bucket = (minute ~/ 30) * 30;
      counts[bucket] = (counts[bucket] ?? 0) + 1;
    }

    final ranked = counts.entries.toList()
      ..sort((a, b) {
        final countOrder = b.value.compareTo(a.value);
        if (countOrder != 0) return countOrder;
        final aDistance =
            _circularDistance(a.key, preference.preferredReminderMinutes);
        final bDistance =
            _circularDistance(b.key, preference.preferredReminderMinutes);
        return aDistance.compareTo(bDistance);
      });

    return _avoidQuietHours(ranked.first.key);
  }

  static int _circularDistance(int a, int b) {
    final distance = (a - b).abs();
    return distance > 12 * 60 ? (24 * 60) - distance : distance;
  }

  static int _avoidQuietHours(int minutes) {
    final normalized = minutes.clamp(0, (24 * 60) - 1).toInt();
    if (normalized >= quietStartMinutes ||
        normalized < quietEndMinutes) {
      return fallbackDaytimeMinutes;
    }
    return normalized;
  }

  static int _safeStreakMinutes(int habitMinutes) {
    final candidate = habitMinutes < 18 * 60
        ? 18 * 60
        : habitMinutes + 90;
    return candidate.clamp(18 * 60, (21 * 60) + 30).toInt();
  }

  static DateTime _nextLocalOccurrence(
    DateTime nowUtc,
    int offsetMinutes,
    int minutesSinceMidnight,
  ) {
    final localNow = nowUtc.add(Duration(minutes: offsetMinutes));
    var scheduled = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
      minutesSinceMidnight ~/ 60,
      minutesSinceMidnight % 60,
    );
    if (!scheduled.isAfter(localNow)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
