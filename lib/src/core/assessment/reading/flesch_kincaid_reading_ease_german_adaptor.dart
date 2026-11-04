/// Task 1461: Amstad/Flesch German Reading Ease (FRE) scoring engine
class GermanReadingEaseCalculator {
  double calculateFre(double wordsPerSentence, double syllablesPerWord) => 180.0 - wordsPerSentence - (58.5 * syllablesPerWord);
}
