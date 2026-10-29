import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/notifications/habit_reminder_scheduler.dart';
import 'package:deutsch_bilarabi/core/notifications/reminder_preferences.dart';
import 'package:deutsch_bilarabi/core/notifications/reminder_storage.dart';

void main() {
  late InMemoryReminderStorage storage;

  setUp(() {
    storage = InMemoryReminderStorage();
    HabitReminderScheduler.initialize(
      storage: storage,
      preferences: const ReminderPreferences(isOptedIn: true),
    );
  });

  test('Does not schedule if opted out', () async {
    HabitReminderScheduler.instance.updatePreferences(const ReminderPreferences(isOptedIn: false));
    final now = DateTime(2023, 10, 20, 15, 0); // 3 PM
    await HabitReminderScheduler.scheduleDailyReminder(now: now);
    final next = await storage.getNextReminder();
    expect(next, isNull);
  });

  test('Schedules for preferred hour if no SRS due date', () async {
    final now = DateTime(2023, 10, 20, 15, 0); // 3 PM
    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    final next = await storage.getNextReminder();
    expect(next, isNotNull);
    expect(next!.hour, 18); // Default preferred hour is 18
    expect(next.day, 20);
  });

  test('Schedules for next day if preferred hour passed', () async {
    final now = DateTime(2023, 10, 20, 19, 0); // 7 PM
    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    final next = await storage.getNextReminder();
    expect(next, isNotNull);
    expect(next!.hour, 18);
    expect(next.day, 21); // Next day
  });

  test('Adjusts for quiet hours (night span)', () async {
    HabitReminderScheduler.instance.updatePreferences(const ReminderPreferences(
      isOptedIn: true,
      preferredHour: 23, // 11 PM
      quietHourStart: 22,
      quietHourEnd: 8,
    ));

    final now = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    final next = await storage.getNextReminder();
    expect(next, isNotNull);
    // Should be moved to end of quiet hours (next day 8 AM)
    expect(next!.hour, 8);
    expect(next.day, 21);
  });

  test('Adjusts for quiet hours (morning span)', () async {
    HabitReminderScheduler.instance.updatePreferences(const ReminderPreferences(
      isOptedIn: true,
      preferredHour: 3, // 3 AM
      quietHourStart: 1,
      quietHourEnd: 6,
    ));

    final now = DateTime(2023, 10, 20, 0, 0); // Midnight
    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    final next = await storage.getNextReminder();
    expect(next, isNotNull);
    // Should be moved to end of quiet hours (same day 6 AM)
    expect(next!.hour, 6);
    expect(next.day, 20);
  });

  test('Idempotency: does not duplicate for the same logical window', () async {
    final now = DateTime(2023, 10, 20, 15, 0);

    await HabitReminderScheduler.scheduleDailyReminder(now: now);
    final firstNext = await storage.getNextReminder();

    // Attempt to schedule again at 16:00
    final later = DateTime(2023, 10, 20, 16, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: later);
    final secondNext = await storage.getNextReminder();

    // Should remain the exact same scheduled time
    expect(firstNext, equals(secondNext));
  });

  test('Cancellation clears state', () async {
    final now = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: now);
    expect(await storage.getNextReminder(), isNotNull);

    await HabitReminderScheduler.instance.cancelReminder();
    expect(await storage.getNextReminder(), isNull);
  });

  test('Foreground evaluation is true when passed recently', () async {
    final now = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    // Target is 18:00
    final evaluateNow = DateTime(2023, 10, 20, 19, 0); // 1 hour past target

    final isEligible = await HabitReminderScheduler.instance.evaluateForegroundEligibility(now: evaluateNow);
    expect(isEligible, isTrue);
  });

  test('Foreground evaluation is false when not passed', () async {
    final now = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    // Target is 18:00
    final evaluateNow = DateTime(2023, 10, 20, 17, 0); // Before target

    final isEligible = await HabitReminderScheduler.instance.evaluateForegroundEligibility(now: evaluateNow);
    expect(isEligible, isFalse);
  });

  test('Foreground evaluation is false when expired (too old)', () async {
    final now = DateTime(2023, 10, 20, 15, 0);
    await HabitReminderScheduler.scheduleDailyReminder(now: now);

    // Target is 18:00
    final evaluateNow = DateTime(2023, 10, 20, 23, 0); // 5 hours past target (limit is 4)

    final isEligible = await HabitReminderScheduler.instance.evaluateForegroundEligibility(now: evaluateNow);
    expect(isEligible, isFalse);
  });

  test('Uses SRS due date if available', () async {
    final now = DateTime(2023, 10, 20, 15, 0);
    final srsDue = DateTime(2023, 10, 20, 17, 30);

    await HabitReminderScheduler.scheduleDailyReminder(now: now, srsDueDate: srsDue);

    final next = await storage.getNextReminder();
    expect(next, isNotNull);
    expect(next, equals(srsDue));
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
    final isEligible = await HabitReminderScheduler.instance.evaluateForegroundEligibility(now: evaluateNow);

    expect(isEligible, isTrue);
  });
}
