/// Task 1671: WordNet synset hypercube conceptual distance calculator
class WordNetDistanceCalculator {
  double computeSynsetDistance(int shortestPath, int maxDepth) => maxDepth > 0 ? shortestPath / (2.0 * maxDepth) : 0.0;
}
