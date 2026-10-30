/// Current resource pressure status during continuous voice dialogue.
enum PerformanceTier { optimal, moderateLoad, criticalThrottle }

/// Dynamic resource Governor ensuring RAM stays < 140MB and battery drain is contained.
class DialogueBatteryRamGuard {
  final int maxRamThresholdMb;
  final double thermalThrottleTempCelsius;

  const DialogueBatteryRamGuard({
    this.maxRamThresholdMb = 140,
    this.thermalThrottleTempCelsius = 42.0,
  });

  /// Evaluates device telemetry and prescribes load-shedding actions.
  Map<String, dynamic> evaluateHealth({
    required int currentRamUsageMb,
    required double batteryTemperatureCelsius,
    required int activeAudioStreams,
  }) {
    PerformanceTier tier;
    final actions = <String>[];

    if (currentRamUsageMb > maxRamThresholdMb || batteryTemperatureCelsius >= thermalThrottleTempCelsius) {
      tier = PerformanceTier.criticalThrottle;
      actions.add('Disable 3D facial blendshape rendering');
      actions.add('Throttle TTS audio synthesis sample rate to 16kHz');
      actions.add('Force immediate garbage collection of audio ring buffers');
    } else if (currentRamUsageMb > (maxRamThresholdMb * 0.75)) {
      tier = PerformanceTier.moderateLoad;
      actions.add('Prune oldest dialogue history turns');
    } else {
      tier = PerformanceTier.optimal;
      actions.add('All multimodal features active');
    }

    return {
      'tier': tier.name,
      'isHealthy': tier != PerformanceTier.criticalThrottle,
      'currentRamMb': currentRamUsageMb,
      'prescribedActions': actions,
    };
  }
}
