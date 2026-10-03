import '../../../core/infrastructure/storage/local_storage_repository.dart';
import '../domain/notification_contracts.dart';
import '../domain/notification_models.dart';

final class LocalNotificationRepository implements NotificationRepository {
  LocalNotificationRepository(this._storage);

  final LocalStorageRepository _storage;

  @override
  Future<NotificationPreference> loadPreference() async {
    final payload =
        await _storage.load(StorageBucket.notificationPreferences);
    if (payload == null) return const NotificationPreference();

    final rawMinutes = payload['preferred_reminder_minutes'];
    final minutes = rawMinutes is num
        ? rawMinutes.toInt()
        : int.tryParse(rawMinutes?.toString() ?? '');

    return NotificationPreference.normalized(
      preferredReminderMinutes: minutes,
      dailyReminderEnabled: payload['daily_reminder_enabled'] is bool
          ? payload['daily_reminder_enabled'] as bool
          : null,
      streakAlertEnabled: payload['streak_alert_enabled'] is bool
          ? payload['streak_alert_enabled'] as bool
          : null,
      tone: NotificationTone.fromWireName(
        payload['tone']?.toString(),
      ),
    );
  }

  @override
  Future<void> savePreference(NotificationPreference preference) {
    return _storage.save(
      StorageBucket.notificationPreferences,
      <String, Object?>{
        'schema_version': 1,
        'preferred_reminder_minutes':
            preference.preferredReminderMinutes,
        'daily_reminder_enabled': preference.dailyReminderEnabled,
        'streak_alert_enabled': preference.streakAlertEnabled,
        'tone': preference.tone.wireName,
      },
    );
  }
}
