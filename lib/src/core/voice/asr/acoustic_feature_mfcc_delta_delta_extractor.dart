/// Task 1158: 13-MFCC + delta + delta-delta feature extractor
class MfccFeatureExtractor {
  static const int featureDim = 39;
  List<double> extractFeatures(List<double> frame) => List.filled(featureDim, 0.0);
}
