import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/multimodal_dialogue/dialogue_battery_ram_guard.dart';

void main() {
  group('DialogueBatteryRamGuard Unit Tests (N079)', () {
    const guard = DialogueBatteryRamGuard(maxRamThresholdMb: 140, thermalThrottleTempCelsius: 42.0);

    test('Reports optimal tier under normal operating conditions', () {
      final report = guard.evaluateHealth(
        currentRamUsageMb: 85,
        batteryTemperatureCelsius: 32.5,
        activeAudioStreams: 1,
      );

      expect(report['isHealthy'], isTrue);
      expect(report['tier'], equals('optimal'));
    });

    test('Triggers critical throttle and load shedding when RAM or temperature spikes', () {
      final report = guard.evaluateHealth(
        currentRamUsageMb: 155, // Over 140MB threshold
        batteryTemperatureCelsius: 43.5,
        activeAudioStreams: 2,
      );

      expect(report['isHealthy'], isFalse);
      expect(report['tier'], equals('criticalThrottle'));
      final actions = report['prescribedActions'] as List<String>;
      expect(actions.any((a) => a.contains('Disable 3D facial blendshape')), isTrue);
    });
  });
}
