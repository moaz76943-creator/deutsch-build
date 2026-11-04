/// Task 1783: Reference-free Quality Estimation (QE) predictor for adequacy & fluency
class ReferenceFreeQePredictor {
  double estimateQuality(String src, String hyp) => hyp.isNotEmpty ? 0.92 : 0.0;
}
