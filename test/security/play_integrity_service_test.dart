import 'dart:io';

import 'package:deutsch_bilarabi/services/play_integrity_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.deutschbilarabi.app/play_integrity');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('Dart channel is the one MainActivity registers', () {
    final kotlin = File(
      'android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidPlayIntegrityManager.kt',
    ).readAsStringSync();
    final activity = File(
      'android/app/src/main/kotlin/com/deutschbilarabi/app/MainActivity.kt',
    ).readAsStringSync();
    expect(
      kotlin.contains(
        'const val CHANNEL_NAME = "com.deutschbilarabi.app/play_integrity"',
      ),
      isTrue,
    );
    expect(activity.contains('AndroidPlayIntegrityManager.CHANNEL_NAME'), isTrue);
    expect(activity.contains('AndroidPlayIntegrityManager(this)'), isTrue);
    // Project number is injected via BuildConfig; release builds fail if unset.
    expect(kotlin.contains('BuildConfig.CLOUD_PROJECT_NUMBER'), isTrue);
    expect(kotlin.contains('CLOUD_PROJECT_NUMBER == 0L'), isTrue);
  });

  test('forwards the server nonce and returns the token', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'requestIntegrityToken');
      expect(call.arguments, <String, Object?>{'nonce': 'server-nonce'});
      return 'integrity-token';
    });

    expect(
      await PlayIntegrityService.requestIntegrityToken(nonce: 'server-nonce'),
      'integrity-token',
    );
  });

  test('not_configured and integrity_failed return null', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(
        code: 'not_configured',
        message: 'Cloud project number not set',
      );
    });
    expect(await PlayIntegrityService.requestIntegrityToken(), isNull);

    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'integrity_failed', message: 'denied');
    });
    expect(
      await PlayIntegrityService.requestIntegrityToken(nonce: 'n'),
      isNull,
    );
  });

  test('unexpected channel errors fail closed', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw StateError('binder died');
    });
    expect(await PlayIntegrityService.requestIntegrityToken(), isNull);
  });

  test('missing plugin does not throw to the caller', () async {
    expect(await PlayIntegrityService.requestIntegrityToken(nonce: 'n'), isNull);
  });
}
