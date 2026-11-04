/// Task 1723: Beam search decoder with Wu et al. length normalization
class BeamSearchDecoder {
  double computeLengthPenalty(int length, double alpha) => ((5.0 + length) / 6.0);
}
