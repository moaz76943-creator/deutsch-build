import 'notification_models.dart';

abstract interface class NotificationRepository {
  Future<NotificationPreference> loadPreference();
  Future<void> savePreference(NotificationPreference preference);
}

abstract interface class NotificationServiceContract {
  Future<void> initialize();
  Future<void> replaceAll(List<ScheduledNotificationItem> items);
  Future<void> cancelAll();
}

abstract interface class NotificationSchedulerFacade {
  Future<void> initialize();
  Future<void> replaceSchedule(List<ScheduledNotificationItem> items);
  Future<void> cancelAll();
}
