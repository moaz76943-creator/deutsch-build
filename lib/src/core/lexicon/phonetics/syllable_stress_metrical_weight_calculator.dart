class SyllableStressMetricalWeightCalculator {
  int findStressIndex(List<String> syllables) => syllables.length > 1 ? syllables.length - 2 : 0;
}
