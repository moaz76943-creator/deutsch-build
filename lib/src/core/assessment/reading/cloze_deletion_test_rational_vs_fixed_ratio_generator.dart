/// Task 1462: Rational cloze vs fixed-ratio (every nth word) generator
class ClozeTestGenerator {
  List<String> generateFixedRatio(List<String> words, int n) => [for (int i = 0; i < words.length; i++) (i + 1) % n == 0 ? '___' : words[i]];
}
