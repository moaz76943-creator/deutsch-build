/// Task 1717: Cognate pair detector identifying borrowed and related words
class CognatePairDetector {
  bool isCognate(String w1, String w2, double threshold) => (w1.length - w2.length).abs() <= 2;
}
