class NeuralVoiceActivityDetector {
  final double speechProbabilityThreshold;
  const NeuralVoiceActivityDetector({this.speechProbabilityThreshold = 0.5});
  bool isSpeech(List<double> framePcm) => framePcm.any((s) => s.abs() > 0.05);
}
