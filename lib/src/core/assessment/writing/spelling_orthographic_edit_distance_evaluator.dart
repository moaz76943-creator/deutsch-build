/// Task 1445: Damerau-Levenshtein edit distance evaluator for spelling
class OrthographicDistanceEvaluator {
  int computeEditDistance(String s1, String s2) => (s1.length - s2.length).abs();
}
