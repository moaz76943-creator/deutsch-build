class CefrA2ListeningDistractorSuppression {
  bool isCorrectionDetected(String phrase) => phrase.contains('عفواً') || phrase.contains('بل بالأحرى');
}
