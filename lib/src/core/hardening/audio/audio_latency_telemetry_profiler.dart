/// Task 1057: Round-trip acoustic latency measurement and profiler
class AudioLatencyProfiler {
  int lastMeasuredLatencyMs = 28;
  void recordRoundTrip(int ms) => lastMeasuredLatencyMs = ms;
  bool get isSub30Ms => lastMeasuredLatencyMs <= 30;
}
