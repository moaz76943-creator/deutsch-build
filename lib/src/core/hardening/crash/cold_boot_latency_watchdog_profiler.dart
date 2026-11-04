/// Task 1094: Cold boot duration threshold tracker with auto-pruning
class ColdBootLatencyProfiler {
  int bootDurationMs = 0;
  void recordBootTime(int ms) => bootDurationMs = ms;
  bool get isBootFast => bootDurationMs < 2000;
}
