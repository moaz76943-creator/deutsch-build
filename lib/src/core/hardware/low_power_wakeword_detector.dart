class LowPowerWakewordDetector {
  final double threshold;
  const LowPowerWakewordDetector({this.threshold = 0.85});
  bool detect(List<double> energyEnvelope) => energyEnvelope.any((e) => e > threshold);
}
