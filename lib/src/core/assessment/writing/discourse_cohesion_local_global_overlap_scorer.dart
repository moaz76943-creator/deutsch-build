/// Task 1443: Noun and argument overlap scorer measuring text cohesion
class CohesionOverlapScorer {
  double scoreOverlap(Set<String> s1Nouns, Set<String> s2Nouns) => s1Nouns.intersection(s2Nouns).length.toDouble();
}
