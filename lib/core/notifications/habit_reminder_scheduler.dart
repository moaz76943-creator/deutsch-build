import 'reminder_preferences.dart';
import 'reminder_storage.dart';

enum OSIntegrationStatus {
  active,
  blockedIntegration, // When OS-level alarms/scheduling are out of scope or unauthorized
}

class HabitReminderScheduler {
  final ReminderStorage _storage;
  ReminderPreferences _preferences;

  /// Singleton approach or inject dependencies to replace the old static methods
  static HabitReminderScheduler? _instance;

  HabitReminderScheduler._internal(this._storage, this._preferences);

  static void initialize({
    required ReminderStorage storage,
    ReminderPreferences preferences = const ReminderPreferences(),
  }) {
    _instance = HabitReminderScheduler._internal(storage, preferences);
  }

  static HabitReminderScheduler get instance {
    _instance ??= HabitReminderScheduler._internal(
        InMemoryReminderStorage(), const ReminderPreferences());
    return _instance!;
  }

  /// The integration status of the actual OS level notifications.
  static OSIntegrationStatus get osIntegrationStatus =>
      OSIntegrationStatus.blockedIntegration;

  /// Update preferences (e.g. opt in/out, quiet hours)
  void updatePreferences(ReminderPreferences newPrefs) {
    _preferences = newPrefs;
  }

  /// Cancels the scheduled reminder
  Future<void> cancelReminder() async {
    await _storage.saveNextReminder(null);
  }

  /// Schedule a daily reminder idempotently based on preferences.
  /// Rejects duplicates for the same logical window.
  /// Uses a provided `now` to make testing deterministic.
  /// Changed back to static to keep original contract, delegating to instance.
  static Future<void> scheduleDailyReminder(
      {DateTime? srsDueDate, DateTime? now}) async {
    return instance._scheduleDailyReminderImpl(
        srsDueDate: srsDueDate, now: now);
  }

  Future<void> _scheduleDailyReminderImpl(
      {DateTime? srsDueDate, DateTime? now}) async {
    if (!_preferences.isOptedIn) {
      await cancelReminder();
      return;
    }

    final currentTime = now ?? DateTime.now();

    DateTime targetTime;
    if (srsDueDate != null && srsDueDate.isAfter(currentTime)) {
      targetTime = srsDueDate;
    } else {
      targetTime = DateTime(currentTime.year, currentTime.month,
          currentTime.day, _preferences.preferredHour);
      if (targetTime.isBefore(currentTime)) {
        targetTime = targetTime.add(const Duration(days: 1));
      }
    }

    targetTime = _adjustForQuietHours(targetTime);

    final existing = await _storage.getNextReminder();
    if (existing != null) {
      if (existing.year == targetTime.year &&
          existing.month == targetTime.month &&
          existing.day == targetTime.day) {
        return; // Idempotent
      }
    }

    if (osIntegrationStatus == OSIntegrationStatus.blockedIntegration) {
      await _storage.saveNextReminder(targetTime);
    }
  }

  DateTime _adjustForQuietHours(DateTime time) {
    int hour = time.hour;
    if (_preferences.quietHourStart > _preferences.quietHourEnd) {
      if (hour >= _preferences.quietHourStart ||
          hour < _preferences.quietHourEnd) {
        if (hour >= _preferences.quietHourStart) {
          return DateTime(
              time.year, time.month, time.day + 1, _preferences.quietHourEnd);
        } else {
          return DateTime(
              time.year, time.month, time.day, _preferences.quietHourEnd);
        }
      }
    } else {
      if (hour >= _preferences.quietHourStart &&
          hour < _preferences.quietHourEnd) {
        return DateTime(
            time.year, time.month, time.day, _preferences.quietHourEnd);
      }
    }
    return time;
  }

  Future<bool> evaluateForegroundEligibility({DateTime? now}) async {
    if (!_preferences.isOptedIn) return false;
    final existing = await _storage.getNextReminder();
    if (existing == null) return false;

    final currentTime = now ?? DateTime.now();

    if (currentTime.isAfter(existing) &&
        currentTime.difference(existing).inHours < 4) {
      return true;
    }
    return false;
  }
}
