class VocalTractGeometry {
  final double tongueHeight;
  final double velumOpening;
  final double lipRounding;
  const VocalTractGeometry({required this.tongueHeight, required this.velumOpening, required this.lipRounding});
}

class VocalTractVisualizer {
  VocalTractGeometry mapFormantsToTract({required double f1, required double f2}) {
    final height = (1.0 - (f1 / 1000.0)).clamp(0.0, 1.0);
    final frontness = (f2 / 2500.0).clamp(0.0, 1.0);
    return VocalTractGeometry(tongueHeight: height, velumOpening: 0.0, lipRounding: 1.0 - frontness);
  }
}
