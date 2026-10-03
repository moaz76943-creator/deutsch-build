import 'notification_contracts.dart';
import 'notification_models.dart';

/// Domain-facing facade. Platform notification plugins stay behind
/// [NotificationServiceContract] implementations in Infrastructure.
final class OfflineNotificationScheduler
    implements NotificationSchedulerFacade {
  OfflineNotificationScheduler(this._service);

  final NotificationServiceContract _service;

  @override
  Future<void> initialize() => _service.initialize();

  @override
  Future<void> replaceSchedule(List<ScheduledNotificationItem> items) {
    return _service.replaceAll(
      List<ScheduledNotificationItem>.unmodifiable(items),
    );
  }

  @override
  Future<void> cancelAll() => _service.cancelAll();
}
