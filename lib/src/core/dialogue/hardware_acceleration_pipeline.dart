enum AccelerationBackend {
  gpuVulkan,
  npuNnapi,
  cpuArmNeon,
  cpuLowPowerFallback,
}

class DeviceThermalState {
  final double temperatureCelsius;
  final int batteryLevelPercent;
  final bool isThermalThrottling;

  const DeviceThermalState({
    required this.temperatureCelsius,
    required this.batteryLevelPercent,
    required this.isThermalThrottling,
  });
}

class AccelerationConfig {
  final AccelerationBackend activeBackend;
  final int threadCount;
  final double targetTokensPerSecond;
  final bool isPowerSavingActive;

  const AccelerationConfig({
    required this.activeBackend,
    required this.threadCount,
    required this.targetTokensPerSecond,
    required this.isPowerSavingActive,
  });

  Map<String, dynamic> toJson() => {
    'activeBackend': activeBackend.name,
    'threadCount': threadCount,
    'targetTokensPerSecond': targetTokensPerSecond,
    'isPowerSavingActive': isPowerSavingActive,
  };
}

class HardwareAccelerationPipeline {
  final bool hasVulkanDriver;
  final bool hasNpuUnit;
  final int totalCpuCores;

  const HardwareAccelerationPipeline({
    this.hasVulkanDriver = true,
    this.hasNpuUnit = true,
    this.totalCpuCores = 8,
  });

  /// Evaluates device thermal state and selects optimal execution backend.
  AccelerationConfig configurePipeline(DeviceThermalState thermal) {
    // 1. Critical Thermal Throttling (> 42°C) or Low Battery (< 15%)
    if (thermal.temperatureCelsius >= 42.0 || thermal.batteryLevelPercent <= 15 || thermal.isThermalThrottling) {
      return const AccelerationConfig(
        activeBackend: AccelerationBackend.cpuLowPowerFallback,
        threadCount: 2,
        targetTokensPerSecond: 8.5,
        isPowerSavingActive: true,
      );
    }

    // 2. High Performance: NPU or Vulkan GPU Acceleration
    if (hasNpuUnit && thermal.temperatureCelsius < 38.0) {
      return const AccelerationConfig(
        activeBackend: AccelerationBackend.npuNnapi,
        threadCount: 4,
        targetTokensPerSecond: 28.0,
        isPowerSavingActive: false,
      );
    }

    if (hasVulkanDriver) {
      return const AccelerationConfig(
        activeBackend: AccelerationBackend.gpuVulkan,
        threadCount: 4,
        targetTokensPerSecond: 22.5,
        isPowerSavingActive: false,
      );
    }

    // 3. Standard Multithreaded CPU ARM NEON
    return AccelerationConfig(
      activeBackend: AccelerationBackend.cpuArmNeon,
      threadCount: totalCpuCores >= 8 ? 4 : 2,
      targetTokensPerSecond: 14.0,
      isPowerSavingActive: false,
    );
  }
}
