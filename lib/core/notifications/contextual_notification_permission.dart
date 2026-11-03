// ignore_for_file: uri_does_not_exist, undefined_class, undefined_method, non_type_as_type_argument, depend_on_referenced_packages
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationPermissionStatus {
  notRequired,
  granted,
  denied,
  unavailable,
}

final class NotificationOptInContext {
  const NotificationOptInContext({
    required this.userInitiated,
    required this.remindersEnabled,
    required this.rationalePresented,
    required this.reason,
  });

  final bool userInitiated;
  final bool remindersEnabled;
  final bool rationalePresented;
  final String reason;

  bool get mayPrompt =>
      userInitiated &&
      remindersEnabled &&
      rationalePresented &&
      reason.trim().isNotEmpty;
}

abstract interface class NotificationPermissionGateway {
  Future<NotificationPermissionStatus> status();

  Future<NotificationPermissionStatus> request(
    NotificationOptInContext context,
  );
}

final class ContextualNotificationPermissionGateway
    implements NotificationPermissionGateway {
  ContextualNotificationPermissionGateway({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<NotificationPermissionStatus> status() async {
    if (!_isAndroid) {
      return NotificationPermissionStatus.notRequired;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return NotificationPermissionStatus.unavailable;
    }

    final enabled = await android.areNotificationsEnabled();
    if (enabled == true) {
      return NotificationPermissionStatus.granted;
    }
    return NotificationPermissionStatus.denied;
  }

  @override
  Future<NotificationPermissionStatus> request(
    NotificationOptInContext context,
  ) async {
    final current = await status();
    if (current == NotificationPermissionStatus.granted ||
        current == NotificationPermissionStatus.notRequired) {
      return current;
    }

    if (!context.mayPrompt) {
      return current;
    }

    if (!_isAndroid) {
      return NotificationPermissionStatus.notRequired;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return NotificationPermissionStatus.unavailable;
    }

    final granted = await android.requestNotificationsPermission();
    return granted == true
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
  }

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
