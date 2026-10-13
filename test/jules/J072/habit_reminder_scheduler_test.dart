import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/notifications/habit_reminder_scheduler.dart';

void main() {
  group('HabitReminderScheduler Eligibility Tests', () {
    test('Should return false if reminders are disabled', () {
      final now = DateTime(2023, 10, 10, 20, 30);
      final eligible = HabitReminderScheduler.isEligibleForReminder(
        now,
        false, // remindersEnabled
        20, // preferredHour
        0, // preferredMinute
        true, // hasDueReviews
        false, // alreadyRemindedToday
      );
      expect(eligible, isFalse);
    });

    test('Should return false if already reminded today (idempotency)', () {
      final now = DateTime(2023, 10, 10, 20, 30);
      final eligible = HabitReminderScheduler.isEligibleForReminder(
        now,
        true,
        20,
        0,
        true,
        true, // alreadyRemindedToday
      );
      expect(eligible, isFalse);
    });

    test('Should return false if no due reviews', () {
      final now = DateTime(2023, 10, 10, 20, 30);
      final eligible = HabitReminderScheduler.isEligibleForReminder(
        now,
        true,
        20,
        0,
        false, // hasDueReviews
        false,
      );
      expect(eligible, isFalse);
    });

    test('Should return false if within quiet hours (10 PM)', () {
      final now = DateTime(2023, 10, 10, 22, 10);
      final eligible = HabitReminderScheduler.isEligibleForReminder(
        now,
        true,
        20,
        0,
        true,
        false,
      );
      expect(eligible, isFalse);
    });

    test('Should return false if within quiet hours (2 AM)', () {
      final now = DateTime(2023, 10, 10, 2, 10);
      final eligible = HabitReminderScheduler.isEligibleForReminder(
        now,
        true,
        1,
        0,
        true,
        false,
      );
      expect(eligible, isFalse);
    });

    test('Should return false if before preferred time', () {
      final now = DateTime(2023, 10, 10, 19, 30);
      final eligible = HabitReminderScheduler.isEligibleForReminder(
        now,
        true,
        20, // preferred 8 PM
        0,
        true,
        false,
      );
      expect(eligible, isFalse);
    });

    test('Should return true if all conditions are met (after preferred time, not quiet hours)', () {
      final now = DateTime(2023, 10, 10, 20, 30);
      final eligible = HabitReminderScheduler.isEligibleForReminder(
        now,
        true,
        20, // preferred 8 PM
        0,
        true, // has due reviews
        false, // not already reminded today
      );
      expect(eligible, isTrue);
    });
  });

  group('HabitReminderScheduler SharedPreferences State', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('cancelAllReminders updates preferences correctly', () async {
      await HabitReminderScheduler.savePreferences(enabled: true, hour: 19, minute: 30);
      expect(await HabitReminderScheduler.areRemindersEnabled(), isTrue);

      await HabitReminderScheduler.cancelAllReminders();
      expect(await HabitReminderScheduler.areRemindersEnabled(), isFalse);

      final prefs = await HabitReminderScheduler.getPreferredTime();
      // Default overridden to 20:00 as per implementation
      expect(prefs['hour'], 19);
      expect(prefs['minute'], 30);
    });

    test('markReminderSentToday properly persists same-day logic', () async {
      final now = DateTime(2023, 10, 10, 15, 0);

      var already = await HabitReminderScheduler.alreadyRemindedToday(now);
      expect(already, isFalse);

      await HabitReminderScheduler.markReminderSentToday(now);
      already = await HabitReminderScheduler.alreadyRemindedToday(now);
      expect(already, isTrue);

      // Next day
      final tomorrow = DateTime(2023, 10, 11, 15, 0);
      already = await HabitReminderScheduler.alreadyRemindedToday(tomorrow);
      expect(already, isFalse);
    });

    test('Timezone change simulation (day boundary)', () async {
      // simulating what happens if a user flies to a timezone and local day changes.
      // alreadyRemindedToday strictly checks local year, month, day.
      final localNow = DateTime(2023, 10, 10, 23, 0); // 11 PM
      await HabitReminderScheduler.markReminderSentToday(localNow);

      final timezoneChangeNow = DateTime(2023, 10, 11, 1, 0); // User traveled, local time is now 1 AM next day

      final already = await HabitReminderScheduler.alreadyRemindedToday(timezoneChangeNow);
      // Since it's a new local calendar day, it should not consider reminder sent "today"
      expect(already, isFalse);
    });
  });
}
