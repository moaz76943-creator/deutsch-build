import 'package:test/test.dart';
import 'package:deutsch_build/src/core/audio/headset_latency_compensator.dart';

void main() {
  group('HeadsetLatencyCompensator Tests', () {
    late HeadsetLatencyCompensator compensator;

    setUp(() {
      compensator = HeadsetLatencyCompensator();
    });

    test('Applies minimal offset for built-in speaker and wired headset', () {
      compensator.updateRoute(AudioRouteType.builtInSpeaker);
      expect(compensator.getCompensationOffset().inMilliseconds, equals(15));

      compensator.updateRoute(AudioRouteType.wiredHeadset);
      expect(compensator.getCompensationOffset().inMilliseconds, equals(20));
    });

    test('Compensates Bluetooth A2DP latency offset accurately', () {
      compensator.updateRoute(AudioRouteType.bluetoothA2dp);
      expect(compensator.getCompensationOffset().inMilliseconds, equals(180));

      final raw = const Duration(milliseconds: 500);
      final calibrated = compensator.calibrateRecordingTimestamp(raw);
      expect(calibrated.inMilliseconds, equals(320));
    });
  });
}
