import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/notifications/habit_reminder_scheduler.dart';
import 'package:deutsch_bilarabi/core/notifications/reminder_preferences.dart';
import 'package:deutsch_bilarabi/core/notifications/reminder_storage.dart';

void main() {
  late HabitReminderScheduler scheduler;
  late InMemoryReminderStorage storage;

  setUp(() {
    storage = InMemoryReminderStorage();
    HabitReminderScheduler.initialize(
      storage: storage,
      preferences: const ReminderPreferences(isOptedIn: true),
    );
    scheduler = HabitReminderScheduler.instance;
  });

  test('Opt-in is required to schedule a reminder', () async {
    scheduler.updatePreferences(const ReminderPreferences(isOptedIn: false));
    await HabitReminderScheduler.scheduleDailyReminder();
    final nextReminder = await storage.getNextReminder();
    expect(nextReminder, isNull);
  });

  test('Reminder falls within preferred hour if no SRS due date', () async {
    final now = DateTime(2023, 10, 15, 10, 0); // 10 AM
    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    final nextReminder = await storage.getNextReminder();
    expect(nextReminder, isNotNull);

    // Default preferred hour is 18 (6 PM)
    expect(nextReminder!.hour, 18);
    expect(nextReminder.day, 15);
  });

  test('Reminder prefers SRS due date if available and valid', () async {
    final now = DateTime(2023, 10, 15, 10, 0);
    final srsDueDate = DateTime(2023, 10, 15, 14, 0); // 2 PM

    await HabitReminderScheduler.scheduleDailyReminder(
        srsDueDate: srsDueDate, now: now);

    final nextReminder = await storage.getNextReminder();
    expect(nextReminder, isNotNull);
    expect(nextReminder, srsDueDate);
  });

  test('Reminder is deferred to tomorrow if preferred hour has passed',
      () async {
    final now = DateTime(2023, 10, 15, 20, 0); // 8 PM

    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    final nextReminder = await storage.getNextReminder();
    expect(nextReminder, isNotNull);
    expect(nextReminder!.day, 16);
    expect(nextReminder.hour, 18); // Default preferred hour
  });

  test('Reminder adjusts for quiet hours', () async {
    // preferred hour is 18 (6 PM), quiet hours are 22 to 8. We set preferred to 23
    scheduler.updatePreferences(const ReminderPreferences(
        isOptedIn: true,
        preferredHour: 23,
        quietHourStart: 22,
        quietHourEnd: 8));
    final now = DateTime(2023, 10, 15, 10, 0);

    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    final nextReminder = await storage.getNextReminder();
    expect(nextReminder, isNotNull);

    // It should be moved to quietHourEnd (8 AM next day)
    expect(nextReminder!.hour, 8);
    expect(nextReminder.day, 16);
  });

  test('Idempotency prevents duplicate reminders on the same day', () async {
    final now = DateTime(2023, 10, 15, 10, 0);

    // Schedule first time
    await HabitReminderScheduler.scheduleDailyReminder(now: now);
    final firstReminder = await storage.getNextReminder();

    // Try to schedule again
    await HabitReminderScheduler.scheduleDailyReminder(now: now);
    final secondReminder = await storage.getNextReminder();

    expect(firstReminder, secondReminder);
  });

  test('cancelReminder removes the next reminder', () async {
    final now = DateTime(2023, 10, 15, 10, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: now);
    expect(await storage.getNextReminder(), isNotNull);

    await scheduler.cancelReminder();
    expect(await storage.getNextReminder(), isNull);
  });

  test(
      'evaluateForegroundEligibility returns true if reminder is due and within 4 hours',
      () async {
    final scheduledTime = DateTime(2023, 10, 15, 18, 0);
    await storage.saveNextReminder(scheduledTime);

    final nowEligible = DateTime(2023, 10, 15, 19, 0); // 1 hour after scheduled
    expect(await scheduler.evaluateForegroundEligibility(now: nowEligible),
        isTrue);

    final nowIneligibleEarly =
        DateTime(2023, 10, 15, 17, 0); // Before scheduled
    expect(
        await scheduler.evaluateForegroundEligibility(now: nowIneligibleEarly),
        isFalse);

    final nowIneligibleLate =
        DateTime(2023, 10, 15, 23, 0); // 5 hours after scheduled
    expect(
        await scheduler.evaluateForegroundEligibility(now: nowIneligibleLate),
        isFalse);
  });

  test('App restart: recovers state using FileReminderStorage', () async {
    final file = File('test_reminder_storage.json');
    if (file.existsSync()) file.deleteSync();

    final fileStorage = FileReminderStorage('test_reminder_storage.json');
    HabitReminderScheduler.initialize(
      storage: fileStorage,
      preferences: const ReminderPreferences(isOptedIn: true),
    );

    final now = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    // Re-initialize (simulate app restart)
    final newFileStorage = FileReminderStorage('test_reminder_storage.json');
    HabitReminderScheduler.initialize(
      storage: newFileStorage,
      preferences: const ReminderPreferences(isOptedIn: true),
    );
    final recoveredNext = await newFileStorage.getNextReminder();
    expect(recoveredNext, isNotNull);
    expect(recoveredNext!.hour, 18);
    expect(recoveredNext.day, 20);

    if (file.existsSync()) file.deleteSync();
  });

  test('Timezone shift logic evaluation', () async {
    // Tests that an absolute target time evaluates correctly even if user travels (mocked by time shift)
    final now = DateTime.utc(2023, 10, 20, 15, 0); // 15:00 UTC

    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    // Reminder targeted for 18:00 local representation (we'll just use the explicit DateTime object logic)
    final evaluateNow = DateTime.utc(2023, 10, 20, 19, 0);
    final isEligible = await HabitReminderScheduler.instance
        .evaluateForegroundEligibility(now: evaluateNow);

    expect(isEligible, isTrue);
  });
}
