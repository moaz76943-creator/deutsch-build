import 'package:test/test.dart';
import '../../lib/src/platform/battery_drain_profiler_engine.dart';

void main() {
  group('BatteryDrainProfilerEngine Unit Tests (N090)', () {
    final engine = BatteryDrainProfilerEngine();

    test('High battery and low temperature maintains full 48kHz audio quality', () {
      final state = engine.evaluatePowerState(batteryLevel: 85.0, drainMa: 220.0, tempCelsius: 32.0);
      expect(state.activeMode, equals(PowerSaveMode.normalPerformance));
      expect(state.audioSampleRateHz, equals(48000));
    });

    test('Critically low battery (<=15%) triggers ultra power saver and 22kHz downsampling', () {
      final state = engine.evaluatePowerState(batteryLevel: 12.0, drainMa: 400.0, tempCelsius: 35.0);
      expect(state.activeMode, equals(PowerSaveMode.ultraPowerSaver));
      expect(state.audioSampleRateHz, equals(22050));
    });

    test('Estimates remaining runtime hours accurately', () {
      final hours = engine.estimateRemainingHours(5000.0, 50.0, 250.0); // 2500 mAh / 250 mA = 10 hrs
      expect(hours, closeTo(10.0, 0.1));
    });
  });
}
