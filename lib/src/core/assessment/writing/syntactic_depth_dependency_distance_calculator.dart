/// Task 1452: Mean Dependency Distance (MDD) calculator for sentences
class MeanDependencyDistanceCalculator {
  double calculateMdd(List<int> headDistances) => headDistances.isNotEmpty ? headDistances.reduce((a, b) => a + b) / headDistances.length : 0.0;
}
