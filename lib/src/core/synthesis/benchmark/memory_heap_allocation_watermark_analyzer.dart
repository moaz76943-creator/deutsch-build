/// Task 1862: Peak heap watermark monitor preventing OOM runaway allocations
class HeapWatermarkAnalyzer {
  bool isWithinThreshold(int usedMb, int limitMb) => usedMb < (limitMb * 0.85);
}
