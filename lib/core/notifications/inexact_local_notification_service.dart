// ignore_for_file: uri_does_not_exist, undefined_class, undefined_method, non_type_as_type_argument, const_initialized_with_non_constant_value, undefined_identifier, depend_on_referenced_packages

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../features/notifications/domain/notification_contracts.dart';
import '../../features/notifications/domain/notification_models.dart';
import '../time/device_time_zone_provider.dart';
import 'contextual_notification_permission.dart';
import 'habit_reminder_scheduler.dart';

final class FlexibleNotificationWindow {
  FlexibleNotificationWindow({
    required DateTime preferredLocal,
    this.before = const Duration(minutes: 20),
    this.after = const Duration(minutes: 40),
  }) : preferredLocal = _requireLocal(preferredLocal) {
    if (before.isNegative ||
        after.isNegative ||
        before > const Duration(hours: 2) ||
        after > const Duration(hours: 2)) {
      throw ArgumentError(
        'Notification flexibility must remain within a two-hour window.',
      );
    }
  }

  final DateTime preferredLocal;
  final Duration before;
  final Duration after;

  DateTime get earliestLocal => preferredLocal.subtract(before);
  DateTime get latestLocal => preferredLocal.add(after);

  static DateTime _requireLocal(DateTime value) {
    if (value.isUtc) {
      throw ArgumentError.value(
        value,
        'preferredLocal',
        'must be a local wall-clock value',
      );
    }
    return value;
  }
}

final class InexactNotificationPolicy {
  const InexactNotificationPolicy({
    this.before = const Duration(minutes: 20),
    this.after = const Duration(minutes: 40),
  });

  final Duration before;
  final Duration after;

  FlexibleNotificationWindow windowFor(DateTime preferredLocal) =>
      FlexibleNotificationWindow(
        preferredLocal: preferredLocal,
        before: before,
        after: after,
      );
}

final class InexactLocalNotificationService
    implements NotificationServiceContract {
  factory InexactLocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    DeviceTimeZoneProvider? timeZoneProvider,
    NotificationPermissionGateway? permissionGateway,
    InexactNotificationPolicy policy = const InexactNotificationPolicy(),
  }) {
    final resolvedPlugin = plugin ?? FlutterLocalNotificationsPlugin();
    return InexactLocalNotificationService._(
      plugin: resolvedPlugin,
      timeZoneProvider:
          timeZoneProvider ?? SystemDeviceTimeZoneProvider(),
      permissionGateway: permissionGateway ??
          ContextualNotificationPermissionGateway(
            plugin: resolvedPlugin,
          ),
      policy: policy,
    );
  }

  InexactLocalNotificationService._({
    required FlutterLocalNotificationsPlugin plugin,
    required DeviceTimeZoneProvider timeZoneProvider,
    required NotificationPermissionGateway permissionGateway,
    required InexactNotificationPolicy policy,
  })  : _plugin = plugin,
        _timeZoneProvider = timeZoneProvider,
        _permissionGateway = permissionGateway,
        _policy = policy;

  final FlutterLocalNotificationsPlugin _plugin;
  final DeviceTimeZoneProvider _timeZoneProvider;
  final NotificationPermissionGateway _permissionGateway;
  final InexactNotificationPolicy _policy;

  bool _initialized = false;

  Future<NotificationPermissionStatus> permissionStatus() =>
      _permissionGateway.status();

  Future<NotificationPermissionStatus> requestPermission(
    NotificationOptInContext context,
  ) =>
      _permissionGateway.request(context);

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    await _timeZoneProvider.resolve(forceRefresh: true);

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
  Future<void> replaceAll(
    List<ScheduledNotificationItem> items,
  ) async {
    await initialize();

    if (HabitReminderScheduler.osIntegrationStatus ==
        OSIntegrationStatus.blockedIntegration) {
      for (final item in items) {
        await HabitReminderScheduler.scheduleDailyReminder(
          srsDueDate: item.scheduledAtLocal,
        );
      }
      return;
    }

    final permission = await _permissionGateway.status();
    if (permission == NotificationPermissionStatus.denied ||
        permission == NotificationPermissionStatus.unavailable) {
      throw StateError('notification_permission_required');
    }

    await _plugin.cancelAll();
    for (final item in items) {
      await _schedule(item);
    }
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    if (HabitReminderScheduler.osIntegrationStatus ==
        OSIntegrationStatus.blockedIntegration) {
      await HabitReminderScheduler.instance.cancelReminder();
      return;
    }
    await _plugin.cancelAll();
  }

  Future<void> _schedule(ScheduledNotificationItem item) async {
    final snapshot = await _timeZoneProvider.resolve();
    final preferred = item.scheduledAtLocal.isUtc
        ? await _timeZoneProvider.toLocal(item.scheduledAtLocal)
        : item.scheduledAtLocal;
    final window = _policy.windowFor(preferred);

    final scheduled = tz.TZDateTime(
      snapshot.location,
      window.preferredLocal.year,
      window.preferredLocal.month,
      window.preferredLocal.day,
      window.preferredLocal.hour,
      window.preferredLocal.minute,
      window.preferredLocal.second,
      window.preferredLocal.millisecond,
      window.preferredLocal.microsecond,
    );

    final silent = item.tone == NotificationTone.silent;
    final gentle = item.tone == NotificationTone.gentle;

    final android = AndroidNotificationDetails(
      'adaptive_habit_reminders',
      'Adaptive Habit Reminders',
      channelDescription:
          'Local reminders delivered in battery-friendly flexible windows.',
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
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      payload: item.payload,
      matchDateTimeComponents:
          item.repeatDaily ? DateTimeComponents.time : null,
    );
  }
}
