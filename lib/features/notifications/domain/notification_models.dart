enum NotificationTone {
  gentle('gentle'),
  classic('classic'),
  silent('silent');

  const NotificationTone(this.wireName);

  final String wireName;

  static NotificationTone fromWireName(String? value) {
    return NotificationTone.values.firstWhere(
      (tone) => tone.wireName == value,
      orElse: () => NotificationTone.gentle,
    );
  }
}

final class ScheduledNotificationItem {
  const ScheduledNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAtLocal,
    required this.tone,
    this.repeatDaily = false,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAtLocal;
  final NotificationTone tone;
  final bool repeatDaily;
  final String? payload;
}

final class NotificationPreference {
  const NotificationPreference({
    this.preferredReminderMinutes = 19 * 60,
    this.dailyReminderEnabled = true,
    this.streakAlertEnabled = true,
    this.tone = NotificationTone.gentle,
  }) : assert(preferredReminderMinutes >= 0),
       assert(preferredReminderMinutes < 24 * 60);

  final int preferredReminderMinutes;
  final bool dailyReminderEnabled;
  final bool streakAlertEnabled;
  final NotificationTone tone;

  int get preferredHour => preferredReminderMinutes ~/ 60;
  int get preferredMinute => preferredReminderMinutes % 60;

  NotificationPreference copyWith({
    int? preferredReminderMinutes,
    bool? dailyReminderEnabled,
    bool? streakAlertEnabled,
    NotificationTone? tone,
  }) {
    return NotificationPreference(
      preferredReminderMinutes:
          (preferredReminderMinutes ?? this.preferredReminderMinutes)
              .clamp(0, (24 * 60) - 1)
              .toInt(),
      dailyReminderEnabled:
          dailyReminderEnabled ?? this.dailyReminderEnabled,
      streakAlertEnabled: streakAlertEnabled ?? this.streakAlertEnabled,
      tone: tone ?? this.tone,
    );
  }

  factory NotificationPreference.normalized({
    int? preferredReminderMinutes,
    bool? dailyReminderEnabled,
    bool? streakAlertEnabled,
    NotificationTone? tone,
  }) {
    return NotificationPreference(
      preferredReminderMinutes:
          (preferredReminderMinutes ?? 19 * 60)
              .clamp(0, (24 * 60) - 1)
              .toInt(),
      dailyReminderEnabled: dailyReminderEnabled ?? true,
      streakAlertEnabled: streakAlertEnabled ?? true,
      tone: tone ?? NotificationTone.gentle,
    );
  }
}
