/// Task 1877: Deterministic random seed generator reproducing edge-case test failures
class DeterministicSeedGenerator {
  int getSeed(int iteration) => (iteration * 1664525 + 1013904223) & 0xFFFFFFFF;
}
