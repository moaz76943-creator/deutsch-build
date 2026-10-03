import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/notifications/application/habit_reminder_scheduler.dart';
import 'package:deutsch_bilarabi/features/notifications/domain/notification_contracts.dart';
import 'package:deutsch_bilarabi/features/notifications/domain/notification_models.dart';

final class _FakeSchedulerFacade implements NotificationSchedulerFacade {
  int initializeCalls = 0;
  int cancelCalls = 0;
  List<ScheduledNotificationItem> items = <ScheduledNotificationItem>[];

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<void> replaceSchedule(List<ScheduledNotificationItem> items) async {
    this.items = List<ScheduledNotificationItem>.from(items);
  }

  @override
  Future<void> cancelAll() async {
    cancelCalls += 1;
    items = <ScheduledNotificationItem>[];
  }
}

void main() {
  test('uses learner most active half-hour bucket for daily reminder', () async {
    final facade = _FakeSchedulerFacade();
    final scheduler = HabitReminderScheduler(facade);

    final plan = await scheduler.reschedule(
      preference: const NotificationPreference(
        preferredReminderMinutes: 19 * 60,
      ),
      activityTimesUtc: <DateTime>[
        DateTime.utc(2026, 9, 28, 15, 32),
        DateTime.utc(2026, 9, 29, 15, 41),
        DateTime.utc(2026, 9, 30, 15, 35),
        DateTime.utc(2026, 10, 1, 16, 5),
      ],
      nowUtc: DateTime.utc(2026, 10, 3, 12),
      timezoneOffsetMinutes: 180,
    );

    expect(plan.effectiveReminderMinutes, 18 * 60 + 30);
    expect(plan.items.single.id, 41001);
    expect(plan.items.single.scheduledAtLocal.hour, 18);
    expect(plan.items.single.scheduledAtLocal.minute, 30);
  });

  test('moves habit reminder out of night quiet hours', () async {
    final facade = _FakeSchedulerFacade();
    final scheduler = HabitReminderScheduler(facade);

    final plan = await scheduler.reschedule(
      preference: const NotificationPreference(
        preferredReminderMinutes: 23 * 60 + 30,
      ),
      activityTimesUtc: const <DateTime>[],
      nowUtc: DateTime.utc(2026, 10, 3, 2),
      timezoneOffsetMinutes: 180,
    );

    expect(
      plan.effectiveReminderMinutes,
      HabitReminderScheduler.fallbackDaytimeMinutes,
    );
    expect(plan.items.single.scheduledAtLocal.hour, 8);
  });

  test('streak alert remains inside evening safety window', () async {
    final facade = _FakeSchedulerFacade();
    final scheduler = HabitReminderScheduler(facade);

    final plan = await scheduler.reschedule(
      preference: const NotificationPreference(
        preferredReminderMinutes: 21 * 60,
      ),
      activityTimesUtc: const <DateTime>[],
      nowUtc: DateTime.utc(2026, 10, 3, 8),
      timezoneOffsetMinutes: 180,
      currentStreak: 7,
    );

    expect(plan.items, hasLength(2));
    final streak = plan.items.singleWhere((item) => item.id == 41002);
    expect(streak.scheduledAtLocal.hour, 21);
    expect(streak.scheduledAtLocal.minute, 30);
  });

  test('disabling all reminders cancels existing schedule', () async {
    final facade = _FakeSchedulerFacade();
    final scheduler = HabitReminderScheduler(facade);

    final plan = await scheduler.reschedule(
      preference: const NotificationPreference(
        dailyReminderEnabled: false,
        streakAlertEnabled: false,
      ),
      activityTimesUtc: const <DateTime>[],
      nowUtc: DateTime.utc(2026, 10, 3, 12),
      timezoneOffsetMinutes: 180,
      currentStreak: 9,
    );

    expect(plan.items, isEmpty);
    expect(facade.cancelCalls, 1);
  });

  test('next habit occurrence moves to tomorrow after local reminder time',
      () async {
    final facade = _FakeSchedulerFacade();
    final scheduler = HabitReminderScheduler(facade);

    final plan = await scheduler.reschedule(
      preference: const NotificationPreference(
        preferredReminderMinutes: 19 * 60,
      ),
      activityTimesUtc: const <DateTime>[],
      nowUtc: DateTime.utc(2026, 10, 3, 18),
      timezoneOffsetMinutes: 180,
    );

    final scheduled = plan.items.single.scheduledAtLocal;
    expect(scheduled.year, 2026);
    expect(scheduled.month, 10);
    expect(scheduled.day, 4);
    expect(scheduled.hour, 19);
  });
}
