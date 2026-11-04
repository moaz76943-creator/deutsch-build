/// Task 1796: Translation throughput (tokens/sec) and first-token latency profiler
class TranslationThroughputProfiler {
  double computeTokensPerSec(int tokens, int elapsedMs) => elapsedMs > 0 ? (tokens / (elapsedMs / 1000.0)) : 0.0;
}
