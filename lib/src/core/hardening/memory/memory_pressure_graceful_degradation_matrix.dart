/// Task 1018: Adaptive UI cache sizing based on system memory pressure
enum MemoryTier { normal, moderate, critical }
class MemoryDegradationMatrix {
  MemoryTier currentTier = MemoryTier.normal;
  int get maxCachedLessons => currentTier == MemoryTier.critical ? 5 : (currentTier == MemoryTier.moderate ? 20 : 50);
}
