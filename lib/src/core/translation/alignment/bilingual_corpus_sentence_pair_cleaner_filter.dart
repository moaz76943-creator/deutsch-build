/// Task 1718: Length ratio filter cleaning noisy parallel sentence pairs
class ParallelCorpusCleaner {
  bool isValidPair(String src, String tgt) {
    double ratio = src.length > 0 ? tgt.length / src.length : 0.0;
    return ratio >= 0.3 && ratio <= 3.3;
  }
}
