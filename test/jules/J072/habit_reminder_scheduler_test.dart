import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/notifications/habit_reminder_scheduler.dart';
import 'package:deutsch_bilarabi/core/notifications/reminder_preferences.dart';
import 'package:deutsch_bilarabi/core/notifications/reminder_storage.dart';

void main() {
  late InMemoryReminderStorage memStorage;

  setUp(() {
    memStorage = InMemoryReminderStorage();
    HabitReminderScheduler.initialize(
      storage: memStorage,
      preferences: const ReminderPreferences(isOptedIn: true),
    );
  });

  test('Should not schedule anything if the user has opted out of reminders', () async {
    HabitReminderScheduler.instance.updatePreferences(const ReminderPreferences(isOptedIn: false));
    final current = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: current);
    final nextReminder = await memStorage.getNextReminder();
    expect(nextReminder, isNull);
  });

  test('Should schedule using the preferred hour if SRS due date is absent', () async {
    final current = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: current);

    final nextReminder = await memStorage.getNextReminder();
    expect(nextReminder, isNotNull);
    expect(nextReminder!.hour, 18);
    expect(nextReminder.day, 20);
  });

  test('Should push scheduling to the next day if the preferred hour has already passed', () async {
    final current = DateTime(2023, 10, 20, 19, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: current);

    final nextReminder = await memStorage.getNextReminder();
    expect(nextReminder, isNotNull);
    expect(nextReminder!.hour, 18);
    expect(nextReminder.day, 21);
  });

  test('Properly shifts the time if it falls within night span quiet hours', () async {
    HabitReminderScheduler.instance.updatePreferences(const ReminderPreferences(
      isOptedIn: true,
      preferredHour: 23,
      quietHourStart: 22,
      quietHourEnd: 8,
    ));

    final current = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: current);

    final nextReminder = await memStorage.getNextReminder();
    expect(nextReminder, isNotNull);
    expect(nextReminder!.hour, 8);
    expect(nextReminder.day, 21);
  });

  test('Properly shifts the time if it falls within morning span quiet hours', () async {
    HabitReminderScheduler.instance.updatePreferences(const ReminderPreferences(
      isOptedIn: true,
      preferredHour: 3,
      quietHourStart: 1,
      quietHourEnd: 6,
    ));

    final current = DateTime(2023, 10, 20, 0, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: current);

    final nextReminder = await memStorage.getNextReminder();
    expect(nextReminder, isNotNull);
    expect(nextReminder!.hour, 6);
    expect(nextReminder.day, 20);
  });

  test('Schedules idempotently preventing duplicates for the same logical window', () async {
    final current = DateTime(2023, 10, 20, 15, 0);

    await HabitReminderScheduler.scheduleDailyReminder(now: current);
    final firstScheduled = await memStorage.getNextReminder();

    final nextHour = DateTime(2023, 10, 20, 16, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: nextHour);
    final secondScheduled = await memStorage.getNextReminder();

    expect(firstScheduled, equals(secondScheduled));
  });

  test('Cancellation fully clears the stored reminder state', () async {
    final current = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: current);
    expect(await memStorage.getNextReminder(), isNotNull);

    await HabitReminderScheduler.instance.cancelReminder();
    expect(await memStorage.getNextReminder(), isNull);
  });

  test('Returns true for foreground evaluation when the reminder time just passed', () async {
    final current = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: current);

    final checkTime = DateTime(2023, 10, 20, 19, 0);
    final isEligible = await HabitReminderScheduler.instance.evaluateForegroundEligibility(now: checkTime);
    expect(isEligible, isTrue);
  });

  test('Returns false for foreground evaluation if the reminder time is in the future', () async {
    final current = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: current);

    final checkTime = DateTime(2023, 10, 20, 17, 0);
    final isEligible = await HabitReminderScheduler.instance.evaluateForegroundEligibility(now: checkTime);
    expect(isEligible, isFalse);
  });

  test('Returns false for foreground evaluation if the reminder time has long expired', () async {
    final current = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: current);

    final checkTime = DateTime(2023, 10, 20, 23, 0);
    final isEligible = await HabitReminderScheduler.instance.evaluateForegroundEligibility(now: checkTime);
    expect(isEligible, isFalse);
  });

  test('Uses the actual SRS due-review metadata when available instead of preferred hour', () async {
    final current = DateTime(2023, 10, 20, 15, 0);
    final actualSrsDue = DateTime(2023, 10, 20, 17, 30);

    await HabitReminderScheduler.scheduleDailyReminder(now: current, srsDueDate: actualSrsDue);

    final nextReminder = await memStorage.getNextReminder();
    expect(nextReminder, isNotNull);
    expect(nextReminder, equals(actualSrsDue));
  });

  test('Safely recovers persistent reminder state using FileReminderStorage across app restarts', () async {
    final testStorageFile = File('test_persistent_storage.json');
    if (testStorageFile.existsSync()) testStorageFile.deleteSync();

    final fileStorageEngine = FileReminderStorage('test_persistent_storage.json');
    HabitReminderScheduler.initialize(
      storage: fileStorageEngine,
      preferences: const ReminderPreferences(isOptedIn: true),
    );

    final current = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: current);

    final restoredStorageEngine = FileReminderStorage('test_persistent_storage.json');
    HabitReminderScheduler.initialize(
      storage: restoredStorageEngine,
      preferences: const ReminderPreferences(isOptedIn: true),
    );
    final restoredReminder = await restoredStorageEngine.getNextReminder();
    expect(restoredReminder, isNotNull);
    expect(restoredReminder!.hour, 18);
    expect(restoredReminder.day, 20);

    if (testStorageFile.existsSync()) testStorageFile.deleteSync();
  });

  test('Correctly evaluates time boundaries even under simulated timezone changes', () async {
    final currentUtc = DateTime.utc(2023, 10, 20, 15, 0);

    await HabitReminderScheduler.scheduleDailyReminder(now: currentUtc);

    final checkTimeUtc = DateTime.utc(2023, 10, 20, 19, 0);
    final isEligible = await HabitReminderScheduler.instance.evaluateForegroundEligibility(now: checkTimeUtc);

    expect(isEligible, isTrue);
  });
}
