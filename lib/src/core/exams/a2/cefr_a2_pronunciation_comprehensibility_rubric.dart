class CefrA2PronunciationComprehensibilityRubric {
  const CefrA2PronunciationComprehensibilityRubric();
  bool passesA2(double comprehensibilityScore) => comprehensibilityScore >= 0.60;
}
