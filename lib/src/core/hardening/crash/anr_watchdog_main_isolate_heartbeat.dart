/// Task 1086: ANR Watchdog monitoring UI isolate responsiveness
class AnrWatchdogHeartbeat {
  int lastHeartbeatTick = 0;
  void tick(int now) => lastHeartbeatTick = now;
  bool isBlocked(int now) => (now - lastHeartbeatTick) > 5000;
}
