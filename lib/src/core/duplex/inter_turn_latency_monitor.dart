class InterTurnLatencyMonitor {
  int lastTurnSwitchEpochMs = 0;
  void recordSwitch(int nowMs) => lastTurnSwitchEpochMs = nowMs;
}
