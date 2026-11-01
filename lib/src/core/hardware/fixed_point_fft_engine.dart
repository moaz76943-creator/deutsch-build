class FixedPointFftEngine {
  const FixedPointFftEngine();
  List<int> computeFixedPointMagnitude(List<int> integerPcm) {
    return integerPcm.map((s) => s.abs()).toList();
  }
}
