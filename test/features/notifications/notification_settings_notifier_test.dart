import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/notifications/application/notification_settings_notifier.dart';
import 'package:deutsch_bilarabi/features/notifications/domain/notification_contracts.dart';
import 'package:deutsch_bilarabi/features/notifications/domain/notification_models.dart';

final class _MemoryNotificationRepository implements NotificationRepository {
  _MemoryNotificationRepository([
    this.preference = const NotificationPreference(),
  ]);

  NotificationPreference preference;
  bool failSave = false;

  @override
  Future<NotificationPreference> loadPreference() async => preference;

  @override
  Future<void> savePreference(NotificationPreference preference) async {
    if (failSave) throw StateError('save failed');
    this.preference = preference;
  }
}

void main() {
  test('initializes from persisted notification preference', () async {
    final repository = _MemoryNotificationRepository(
      const NotificationPreference(
        preferredReminderMinutes: 8 * 60 + 15,
        streakAlertEnabled: false,
        tone: NotificationTone.classic,
      ),
    );
    final notifier = NotificationSettingsNotifier(repository);
    addTearDown(notifier.dispose);

    final state = await notifier.initialize();

    expect(state.preference.preferredReminderMinutes, 8 * 60 + 15);
    expect(state.preference.streakAlertEnabled, isFalse);
    expect(state.preference.tone, NotificationTone.classic);
  });

  test('updates and persists daily reminder settings', () async {
    final repository = _MemoryNotificationRepository();
    final notifier = NotificationSettingsNotifier(repository);
    addTearDown(notifier.dispose);
    await notifier.initialize();

    await notifier.setReminderMinutes(20 * 60 + 20);
    await notifier.setStreakAlertEnabled(false);
    await notifier.setTone(NotificationTone.silent);

    expect(repository.preference.preferredReminderMinutes, 20 * 60 + 20);
    expect(repository.preference.streakAlertEnabled, isFalse);
    expect(repository.preference.tone, NotificationTone.silent);
    expect(notifier.state.isSaving, isFalse);
  });

  test('failed persistence restores previous preference', () async {
    final repository = _MemoryNotificationRepository(
      const NotificationPreference(preferredReminderMinutes: 18 * 60),
    );
    final notifier = NotificationSettingsNotifier(repository);
    addTearDown(notifier.dispose);
    await notifier.initialize();
    repository.failSave = true;

    await expectLater(
      notifier.setReminderMinutes(9 * 60),
      throwsStateError,
    );

    expect(notifier.state.preference.preferredReminderMinutes, 18 * 60);
    expect(notifier.state.isSaving, isFalse);
  });

  test('normalization clamps invalid stored minute values', () {
    final preference = NotificationPreference.normalized(
      preferredReminderMinutes: 9999,
    );

    expect(preference.preferredReminderMinutes, (24 * 60) - 1);
  });
}
