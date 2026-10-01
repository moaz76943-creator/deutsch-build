import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:deutsch_bilarabi/features/notifications/domain/offline_notification_scheduler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'offline_notification_scheduler_test.mocks.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late OfflineNotificationScheduler scheduler;

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    scheduler = OfflineNotificationScheduler(plugin: mockPlugin);

    // Set a predictable local timezone for testing
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('OfflineNotificationScheduler', () {
    test('initialize calls plugin initialize', () async {
      when(
        mockPlugin.initialize(
          settings: anyNamed('settings'),
          onDidReceiveNotificationResponse: anyNamed(
            'onDidReceiveNotificationResponse',
          ),
          onDidReceiveBackgroundNotificationResponse: anyNamed(
            'onDidReceiveBackgroundNotificationResponse',
          ),
        ),
      ).thenAnswer((_) async => true);

      await scheduler.initialize();

      verify(
        mockPlugin.initialize(
          settings: anyNamed('settings'),
          onDidReceiveNotificationResponse: anyNamed(
            'onDidReceiveNotificationResponse',
          ),
          onDidReceiveBackgroundNotificationResponse: anyNamed(
            'onDidReceiveBackgroundNotificationResponse',
          ),
        ),
      ).called(1);
    });

    test(
      'scheduleDailyReminder calls zonedSchedule with correct parameters',
      () async {
        when(
          mockPlugin.zonedSchedule(
            id: anyNamed('id'),
            title: anyNamed('title'),
            body: anyNamed('body'),
            scheduledDate: anyNamed('scheduledDate'),
            notificationDetails: anyNamed('notificationDetails'),
            androidScheduleMode: anyNamed('androidScheduleMode'),
            matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          ),
        ).thenAnswer((_) async {});

        const timeOfDay = TimeOfDay(hour: 14, minute: 30);
        await scheduler.scheduleDailyReminder(timeOfDay);

        verify(
          mockPlugin.zonedSchedule(
            id: 0,
            title: 'وقت الدراسة',
            body: 'حان وقت مراجعة مفرداتك الألمانية!',
            scheduledDate: argThat(
              isA<tz.TZDateTime>(),
              named: 'scheduledDate',
            ),
            notificationDetails: anyNamed('notificationDetails'),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
          ),
        ).called(1);
      },
    );

    test('cancelAllReminders calls cancelAll', () async {
      when(mockPlugin.cancelAll()).thenAnswer((_) async {});

      await scheduler.cancelAllReminders();

      verify(mockPlugin.cancelAll()).called(1);
    });
  });
}
