import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/performance/adaptive_thermal_battery_manager.dart';

class MockTelemetrySource implements DeviceTelemetrySource {
  int battery = 80;
  bool charging = false;
  DeviceThermalStatus thermal = DeviceThermalStatus.normal;

  @override
  Future<int> getBatteryLevelPercentage() async => battery;

  @override
  Future<bool> isCharging() async => charging;

  @override
  Future<DeviceThermalStatus> getThermalStatus() async => thermal;
}

void main() {
  group('AdaptiveThermalBatteryManager Tests', () {
    late MockTelemetrySource telemetry;
    late AdaptiveThermalBatteryManager manager;

    setUp(() {
      telemetry = MockTelemetrySource();
      manager = AdaptiveThermalBatteryManager(telemetry: telemetry);
    });

    tearDown(() {
      manager.dispose();
    });

    test('Assigns fullFidelity tier under healthy battery and normal thermal status', () async {
      final tier = await manager.evaluateAndApplyPolicy();
      expect(tier, equals(OperationalQualityTier.fullFidelity));
      expect(manager.canRunBackgroundMaintenance(batteryLevel: 80, isCharging: false), isTrue);
    });

    test('Enforces ecoSaver tier on critical thermal status or critically low battery', () async {
      telemetry.thermal = DeviceThermalStatus.critical;
      final tier = await manager.evaluateAndApplyPolicy();
      expect(tier, equals(OperationalQualityTier.ecoSaver));

      expect(manager.canRunBackgroundMaintenance(batteryLevel: 10, isCharging: false), isFalse);
    });

    test('Transitions to balanced tier under moderate heat', () async {
      telemetry.thermal = DeviceThermalStatus.moderate;
      final tier = await manager.evaluateAndApplyPolicy();
      expect(tier, equals(OperationalQualityTier.balanced));
    });
  });
}
