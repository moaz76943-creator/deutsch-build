import 'package:test/test.dart';
import 'package:deutsch_build/src/core/dialogue/hardware_acceleration_pipeline.dart';

void main() {
  group('HardwareAccelerationPipeline Tests', () {
    const pipeline = HardwareAccelerationPipeline(hasVulkanDriver: true, hasNpuUnit: true);

    test('Selects NPU/Vulkan high-speed backend under normal thermal conditions', () {
      const normalState = DeviceThermalState(
        temperatureCelsius: 32.5,
        batteryLevelPercent: 85,
        isThermalThrottling: false,
      );

      final config = pipeline.configurePipeline(normalState);

      expect(config.activeBackend, isIn([AccelerationBackend.npuNnapi, AccelerationBackend.gpuVulkan]));
      expect(config.targetTokensPerSecond, greaterThan(20.0));
      expect(config.isPowerSavingActive, isFalse);
    });

    test('Switches to low-power CPU fallback when temperature exceeds 42C', () {
      const overheatingState = DeviceThermalState(
        temperatureCelsius: 43.5,
        batteryLevelPercent: 60,
        isThermalThrottling: true,
      );

      final config = pipeline.configurePipeline(overheatingState);

      expect(config.activeBackend, equals(AccelerationBackend.cpuLowPowerFallback));
      expect(config.threadCount, equals(2));
      expect(config.isPowerSavingActive, isTrue);
    });

    test('Enforces battery preservation when level drops below 15%', () {
      const lowBatteryState = DeviceThermalState(
        temperatureCelsius: 30.0,
        batteryLevelPercent: 12,
        isThermalThrottling: false,
      );

      final config = pipeline.configurePipeline(lowBatteryState);

      expect(config.isPowerSavingActive, isTrue);
      expect(config.activeBackend, equals(AccelerationBackend.cpuLowPowerFallback));
    });
  });
}
