import 'reminder_preferences.dart';
import 'reminder_storage.dart';

enum OSIntegrationStatus { active, blockedIntegration }

class HabitReminderScheduler {
  HabitReminderScheduler._internal(this._reminderStorage, this._userPreferences);

  final ReminderStorage _reminderStorage;
  ReminderPreferences _userPreferences;

  static HabitReminderScheduler? _singletonInstance;

  static void initialize({
    required ReminderStorage storage,
    ReminderPreferences preferences = const ReminderPreferences(),
  }) {
    _singletonInstance = HabitReminderScheduler._internal(storage, preferences);
  }

  static HabitReminderScheduler get instance {
    _singletonInstance ??= HabitReminderScheduler._internal(
      InMemoryReminderStorage(),
      const ReminderPreferences(),
    );
    return _singletonInstance!;
  }

  static OSIntegrationStatus get osIntegrationStatus {
    return OSIntegrationStatus.blockedIntegration;
  }

  void updatePreferences(ReminderPreferences newPreferences) {
    _userPreferences = newPreferences;
  }

  Future<void> cancelReminder() async {
    await _reminderStorage.saveNextReminder(null);
  }

  static Future<void> scheduleDailyReminder({DateTime? srsDueDate, DateTime? now}) async {
    return instance._executeSchedulingLogic(srsDueDate: srsDueDate, now: now);
  }

  Future<void> _executeSchedulingLogic({DateTime? srsDueDate, DateTime? now}) async {
    if (!_userPreferences.isOptedIn) {
      await cancelReminder();
      return;
    }

    final currentDateTime = now ?? DateTime.now();
    DateTime targetDateTime;

    if (srsDueDate != null && srsDueDate.isAfter(currentDateTime)) {
      targetDateTime = srsDueDate;
    } else {
      targetDateTime = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        _userPreferences.preferredHour,
      );
      if (targetDateTime.isBefore(currentDateTime)) {
        targetDateTime = targetDateTime.add(const Duration(days: 1));
      }
    }

    targetDateTime = _applyQuietHours(targetDateTime);

    final currentlyScheduled = await _reminderStorage.getNextReminder();
    if (currentlyScheduled != null) {
      final isSameLogicalWindow = currentlyScheduled.year == targetDateTime.year &&
          currentlyScheduled.month == targetDateTime.month &&
          currentlyScheduled.day == targetDateTime.day;
      if (isSameLogicalWindow) {
        return;
      }
    }

    if (osIntegrationStatus == OSIntegrationStatus.blockedIntegration) {
      await _reminderStorage.saveNextReminder(targetDateTime);
    }
  }

  DateTime _applyQuietHours(DateTime scheduledTime) {
    final int h = scheduledTime.hour;
    final int startQ = _userPreferences.quietHourStart;
    final int endQ = _userPreferences.quietHourEnd;

    if (startQ > endQ) {
      if (h >= startQ || h < endQ) {
        if (h >= startQ) {
          return DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day + 1, endQ);
        } else {
          return DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day, endQ);
        }
      }
    } else {
      if (h >= startQ && h < endQ) {
        return DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day, endQ);
      }
    }
    return scheduledTime;
  }

  Future<bool> evaluateForegroundEligibility({DateTime? now}) async {
    if (!_userPreferences.isOptedIn) {
      return false;
    }

    final scheduledReminder = await _reminderStorage.getNextReminder();
    if (scheduledReminder == null) {
      return false;
    }

    final currentDateTime = now ?? DateTime.now();

    final hasPassed = currentDateTime.isAfter(scheduledReminder);
    final hoursSince = currentDateTime.difference(scheduledReminder).inHours;

    if (hasPassed && hoursSince < 4) {
      return true;
    }
    return false;
  }
}
