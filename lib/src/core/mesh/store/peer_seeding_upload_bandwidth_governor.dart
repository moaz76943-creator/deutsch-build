/// Task 1594: Adaptive upload rate limiter preventing app UI frame drops
class PeerSeedingBandwidthGovernor {
  double maxUploadKbps = 256.0;
  void throttleIfBusy(bool isLessonActive) => maxUploadKbps = isLessonActive ? 64.0 : 256.0;
}
