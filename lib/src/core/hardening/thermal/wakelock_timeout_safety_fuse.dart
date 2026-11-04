/// Task 1064: Automatic hard fuse for runaway background wakelocks
class WakelockSafetyFuse {
  static const int maxWakelockSeconds = 180;
  bool isExpired(int activeSeconds) => activeSeconds >= maxWakelockSeconds;
}
