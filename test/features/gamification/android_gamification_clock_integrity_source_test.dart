import 'package:deutsch_bilarabi/features/gamification/data/android_gamification_clock_integrity_source.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test/gamification_clock_integrity');
  const source = AndroidGamificationClockIntegritySource(channel: channel);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('maps Android monotonic stamp without exposing wall-clock data', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'readStamp');
      return <String, Object?>{
        'elapsedRealtimeMilliseconds': 123456,
        'bootCount': 17,
      };
    });

    final stamp = await source.read();

    expect(stamp, isNotNull);
    expect(stamp!.elapsedRealtimeMilliseconds, 123456);
    expect(stamp.bootCount, 17);
  });

  test('fails soft when platform source is unavailable', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'unavailable');
    });

    expect(await source.read(), isNull);
  });
}
