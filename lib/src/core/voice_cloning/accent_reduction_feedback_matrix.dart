class AccentReductionFeedbackMatrix {
  String getArticulatoryCorrection(String detectedPhoneme, String targetPhoneme) {
    if (detectedPhoneme == targetPhoneme) return 'Korrekt!';
    return 'Ziel: $targetPhoneme anstelle von $detectedPhoneme.';
  }
}
