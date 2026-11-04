/// Task 2044: Evaluates response latency distribution suggesting optimal break intervals
class CognitiveFatigueRestScheduler {
  bool shouldTakeBreak(int consecutiveMinutes, double averageLatencyMs) => consecutiveMinutes > 45 || averageLatencyMs > 3500;
}
