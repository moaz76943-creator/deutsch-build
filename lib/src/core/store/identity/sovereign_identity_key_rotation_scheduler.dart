class SovereignIdentityKeyRotationScheduler {
  bool shouldRotate(int lastRotationEpochMs, int maxAgeMs) =>
      DateTime.now().millisecondsSinceEpoch - lastRotationEpochMs > maxAgeMs;
}
