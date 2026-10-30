class SpeakerEmbedding {
  final List<double> dVector;
  final double durationSeconds;
  SpeakerEmbedding({required this.dVector, required this.durationSeconds});
  int get dimension => dVector.length;
}

class ZeroShotVoiceCloner {
  final int targetEmbeddingDimension;
  const ZeroShotVoiceCloner({this.targetEmbeddingDimension = 192});

  SpeakerEmbedding extractEmbedding(List<double> rawPcmSamples, double sampleRateHz) {
    if (rawPcmSamples.isEmpty || sampleRateHz <= 0) {
      return SpeakerEmbedding(dVector: List.filled(targetEmbeddingDimension, 0.0), durationSeconds: 0.0);
    }
    final duration = rawPcmSamples.length / sampleRateHz;
    final vec = List<double>.generate(targetEmbeddingDimension, (i) => (i % 7) * 0.1);
    return SpeakerEmbedding(dVector: vec, durationSeconds: duration);
  }

  bool isQualitySufficient(SpeakerEmbedding emb) => emb.durationSeconds >= 2.5;
}
