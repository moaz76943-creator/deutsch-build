/// Task 1713: Applies Zipf's law frequency thresholds to prune subwords
class ZipfCutoffFilter {
  bool shouldRetainSubword(int count, int minThreshold) => count >= minThreshold;
}
