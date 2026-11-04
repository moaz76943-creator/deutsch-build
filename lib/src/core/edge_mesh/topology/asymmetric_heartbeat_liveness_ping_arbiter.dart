/// Task 2006: Asymmetric heartbeat ping monitor pruning disconnected peers
class HeartbeatLivenessPingArbiter {
  bool isPeerAlive(int lastSeenEpochMs, int nowEpochMs) => (nowEpochMs - lastSeenEpochMs) < 15000;
}
