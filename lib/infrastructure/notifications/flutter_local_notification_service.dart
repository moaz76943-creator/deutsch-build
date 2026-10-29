import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/notifications/domain/notification_contracts.dart';
import '../../features/notifications/domain/notification_models.dart';

final class FlutterLocalNotificationService
    implements NotificationServiceContract {
  FlutterLocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  @override
  Future<void> replaceAll(List<ScheduledNotificationItem> items) async {
    await initialize();
    await _plugin.cancelAll();
    for (final item in items) {
      await _schedule(item);
    }
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  Future<void> _schedule(ScheduledNotificationItem item) async {
    final scheduled = item.scheduledAtLocal;
    final zoned = tz.TZDateTime(
      tz.local,
      scheduled.year,
      scheduled.month,
      scheduled.day,
      scheduled.hour,
      scheduled.minute,
    );
    final silent = item.tone == NotificationTone.silent;
    final gentle = item.tone == NotificationTone.gentle;

    final android = AndroidNotificationDetails(
      'adaptive_habit_reminders',
      'Adaptive Habit Reminders',
      channelDescription:
          'Local reminders based on the learner study habit.',
      importance: gentle ? Importance.defaultImportance : Importance.high,
      priority: gentle ? Priority.defaultPriority : Priority.high,
      playSound: !silent,
    );
    final darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: !silent,
    );

    await _plugin.zonedSchedule(
      id: item.id,
      title: item.title,
      body: item.body,
      scheduledDate: zoned,
      notificationDetails: NotificationDetails(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: item.payload,
      matchDateTimeComponents:
          item.repeatDaily ? DateTimeComponents.time : null,
    );
  }
}
