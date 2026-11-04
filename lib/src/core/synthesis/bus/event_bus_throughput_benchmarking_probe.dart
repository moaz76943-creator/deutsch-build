/// Task 1828: Real-time throughput probe measuring million-events-per-second bus overhead
class EventBusThroughputProbe {
  double computeEventsPerSec(int count, int elapsedMs) => elapsedMs > 0 ? (count / (elapsedMs / 1000.0)) : 0.0;
}
