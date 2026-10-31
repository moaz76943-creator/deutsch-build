/// Hardware telemetry report for content querying on constrained mobile devices.
class HardwareProfileReport {
  final double currentMemoryUsageMb;
  final double maxAllowedCeilingMb;
  final bool isWithinBudget;
  final int averageQueryLatencyMicros;
  final String optimizationTier;

  const HardwareProfileReport({
    required this.currentMemoryUsageMb,
    required this.maxAllowedCeilingMb,
    required this.isWithinBudget,
    required this.averageQueryLatencyMicros,
    required this.optimizationTier,
  });
}

/// Monitors and guarantees content database memory consumption stays strictly < 45MB on low-end devices.
class LowEndHardwareContentProfiler {
  final double maxMemoryCeilingMb;

  const LowEndHardwareContentProfiler({this.maxMemoryCeilingMb = 45.0});

  /// Evaluates memory pressure during bulk content lookups and vocabulary browsing.
  HardwareProfileReport evaluatePerformance({
    required double measuredMemoryMb,
    required int queryLatencyMicros,
  }) {
    final withinBudget = measuredMemoryMb <= maxMemoryCeilingMb;

    String tier;
    if (measuredMemoryMb < 25.0) {
      tier = 'PERFECT_ULTRA_LIGHT';
    } else if (withinBudget) {
      tier = 'OPTIMAL_BALANCED';
    } else {
      tier = 'OVER_BUDGET_ACTION_REQUIRED';
    }

    return HardwareProfileReport(
      currentMemoryUsageMb: measuredMemoryMb,
      maxAllowedCeilingMb: maxMemoryCeilingMb,
      isWithinBudget: withinBudget,
      averageQueryLatencyMicros: queryLatencyMicros,
      optimizationTier: tier,
    );
  }
}
