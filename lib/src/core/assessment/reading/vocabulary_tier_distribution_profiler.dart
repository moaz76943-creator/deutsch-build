/// Task 1473: Tier 1 vs Tier 2 academic vs Tier 3 domain vocabulary profiler
class VocabTierProfiler {
  Map<String, double> getTierRatios(int t1, int t2, int t3, int total) => total > 0 ? {'T1': t1 / total, 'T2': t2 / total, 'T3': t3 / total} : {};
}
