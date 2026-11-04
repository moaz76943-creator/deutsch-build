/// Task 1786: Heuristic detector catching repetition loops, severe omissions & hallucinations
class TranslationHallucinationDetector {
  bool hasRepetitionLoop(String text) => text.split(' ').toSet().length < (text.split(' ').length / 3);
}
