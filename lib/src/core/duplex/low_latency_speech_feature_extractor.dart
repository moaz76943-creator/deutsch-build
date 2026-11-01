class LowLatencySpeechFeatureExtractor {
  final int frameSize;
  const LowLatencySpeechFeatureExtractor({this.frameSize = 512});
  List<double> extractMfcc(List<double> pcm) => List.filled(13, 0.0);
}
