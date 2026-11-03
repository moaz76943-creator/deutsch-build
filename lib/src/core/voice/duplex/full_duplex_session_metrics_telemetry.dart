/// Task 1136: Latency, interruption counts, and packet loss metrics
class DuplexSessionMetrics {
  int interruptionCount = 0;
  int avgLatencyMs = 65;
  void recordInterruption() => interruptionCount++;
}
