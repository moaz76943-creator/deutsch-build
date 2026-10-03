import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/infrastructure/storage/local_storage_repository.dart';
import 'package:deutsch_bilarabi/features/notifications/data/local_notification_repository.dart';
import 'package:deutsch_bilarabi/features/notifications/domain/notification_models.dart';

final class _MemoryLocalStorage implements LocalStorageRepository {
  final Map<StorageBucket, Map<String, Object?>> values =
      <StorageBucket, Map<String, Object?>>{};

  @override
  Future<void> save(
    StorageBucket bucket,
    Map<String, Object?> payload,
  ) async {
    values[bucket] = Map<String, Object?>.from(payload);
  }

  @override
  Future<Map<String, Object?>?> load(StorageBucket bucket) async {
    final value = values[bucket];
    return value == null ? null : Map<String, Object?>.from(value);
  }

  @override
  Future<void> delete(StorageBucket bucket) async {
    values.remove(bucket);
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  test('saves notification preference in local resilient storage bucket',
      () async {
    final storage = _MemoryLocalStorage();
    final repository = LocalNotificationRepository(storage);
    const preference = NotificationPreference(
      preferredReminderMinutes: 7 * 60 + 45,
      dailyReminderEnabled: true,
      streakAlertEnabled: false,
      tone: NotificationTone.classic,
    );

    await repository.savePreference(preference);
    final restored = await repository.loadPreference();

    expect(
      storage.values,
      contains(StorageBucket.notificationPreferences),
    );
    expect(restored.preferredReminderMinutes, 7 * 60 + 45);
    expect(restored.streakAlertEnabled, isFalse);
    expect(restored.tone, NotificationTone.classic);
  });

  test('malformed persisted values are normalized fail-safe', () async {
    final storage = _MemoryLocalStorage();
    storage.values[StorageBucket.notificationPreferences] =
        <String, Object?>{
      'preferred_reminder_minutes': 5000,
      'daily_reminder_enabled': true,
      'streak_alert_enabled': true,
      'tone': 'unknown',
    };
    final repository = LocalNotificationRepository(storage);

    final restored = await repository.loadPreference();

    expect(restored.preferredReminderMinutes, (24 * 60) - 1);
    expect(restored.tone, NotificationTone.gentle);
  });
}
