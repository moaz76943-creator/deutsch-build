import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/notifications/domain/notification_contracts.dart';
import 'package:deutsch_bilarabi/features/notifications/domain/notification_models.dart';
import 'package:deutsch_bilarabi/features/notifications/domain/offline_notification_scheduler.dart';

final class _FakeNotificationService implements NotificationServiceContract {
  int initializeCalls = 0;
  int cancelCalls = 0;
  List<ScheduledNotificationItem> scheduled = <ScheduledNotificationItem>[];

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<void> replaceAll(List<ScheduledNotificationItem> items) async {
    scheduled = List<ScheduledNotificationItem>.from(items);
  }

  @override
  Future<void> cancelAll() async {
    cancelCalls += 1;
  }
}

void main() {
  group('OfflineNotificationScheduler', () {
    test('delegates initialization through domain service contract', () async {
      final service = _FakeNotificationService();
      final scheduler = OfflineNotificationScheduler(service);

      await scheduler.initialize();

      expect(service.initializeCalls, 1);
    });

    test('replaces schedule without platform dependency in domain', () async {
      final service = _FakeNotificationService();
      final scheduler = OfflineNotificationScheduler(service);
      final item = ScheduledNotificationItem(
        id: 1,
        title: 'وقت الدراسة',
        body: 'راجع الألمانية اليوم.',
        scheduledAtLocal: DateTime(2026, 10, 4, 19),
        tone: NotificationTone.gentle,
        repeatDaily: true,
      );

      await scheduler.replaceSchedule(<ScheduledNotificationItem>[item]);

      expect(service.scheduled, hasLength(1));
      expect(service.scheduled.single.id, 1);
      expect(service.scheduled.single.repeatDaily, isTrue);
    });

    test('delegates cancellation through facade', () async {
      final service = _FakeNotificationService();
      final scheduler = OfflineNotificationScheduler(service);

      await scheduler.cancelAll();

      expect(service.cancelCalls, 1);
    });
  });
}
