/// Task 1278: Cross-platform ascent, descent, and lineGap normalizer
class FontMetricsNormalizer {
  double calculateNormalizedLineHeight(double ascent, double descent, double lineGap) => (ascent.abs() + descent.abs() + lineGap);
}
