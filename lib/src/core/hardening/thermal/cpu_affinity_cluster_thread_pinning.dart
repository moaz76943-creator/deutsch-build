/// Task 1071: Pinning audio synthesis threads to efficiency clusters
class CpuAffinityPinning {
  String assignedCluster = 'LITTLE_EFFICIENCY_CORE';
  void pinToEfficiency() => assignedCluster = 'LITTLE_EFFICIENCY_CORE';
  void pinToPerformance() => assignedCluster = 'BIG_PERFORMANCE_CORE';
}
