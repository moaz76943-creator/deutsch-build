class NeuralAudioSynthesizerV2 {
  final int sampleRate;
  const NeuralAudioSynthesizerV2({this.sampleRate = 24000});
  List<double> synthesizePhoneme(String ipa, int durationMs) {
    final samples = (sampleRate * durationMs) ~/ 1000;
    return List.filled(samples, 0.0);
  }
}
