class CefrA1PronunciationFluencyScorer {
  const CefrA1PronunciationFluencyScorer();
  bool isAcceptableForA1(double clarityRatio) => clarityRatio >= 0.55;
}
