/// Power management profile during prolonged offline study sessions.
enum PowerSaveMode { normalPerformance, balancedEco, ultraPowerSaver }

/// Telemetry metrics for battery current draw and thermal impact.
class PowerTelemetry {
  final double batteryLevelPercent; // 0.0 to 100.0
  final double currentDrainMilliAmps;
  final double deviceTemperatureCelsius;
  final PowerSaveMode activeMode;
  final int audioSampleRateHz;

  const PowerTelemetry({
    required this.batteryLevelPercent,
    required this.currentDrainMilliAmps,
    required this.deviceTemperatureCelsius,
    required this.activeMode,
    required this.audioSampleRateHz,
  });
}

/// Dynamically downsamples audio synthesis and background tasks to prolong battery life.
class BatteryDrainProfilerEngine {
  /// Evaluates telemetry and adapts audio sample rate and power profile.
  PowerTelemetry evaluatePowerState({
    required double batteryLevel,
    required double drainMa,
    required double tempCelsius,
  }) {
    PowerSaveMode mode;
    int sampleRate;

    if (batteryLevel <= 15.0 || tempCelsius >= 41.0) {
      mode = PowerSaveMode.ultraPowerSaver;
      sampleRate = 22050; // Cut processing in half
    } else if (batteryLevel <= 35.0 || tempCelsius >= 38.0) {
      mode = PowerSaveMode.balancedEco;
      sampleRate = 32000;
    } else {
      mode = PowerSaveMode.normalPerformance;
      sampleRate = 48000; // Studio audio quality
    }

    return PowerTelemetry(
      batteryLevelPercent: batteryLevel,
      currentDrainMilliAmps: drainMa,
      deviceTemperatureCelsius: tempCelsius,
      activeMode: mode,
      audioSampleRateHz: sampleRate,
    );
  }

  /// Calculates battery runtime hours left based on current consumption.
  double estimateRemainingHours(double batteryCapacityMah, double batteryPercent, double currentDrainMa) {
    if (currentDrainMa <= 0) return 999.0;
    final remainingMah = (batteryCapacityMah * (batteryPercent / 100.0));
    return (remainingMah / currentDrainMa).clamp(0.0, 999.0);
  }
}
