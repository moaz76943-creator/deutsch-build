class VocalFatigueGuard {
  bool isRestRequired({required double jitterPercent, required double shimmerPercent}) {
    return jitterPercent > 2.5 || shimmerPercent > 5.0;
  }
}
