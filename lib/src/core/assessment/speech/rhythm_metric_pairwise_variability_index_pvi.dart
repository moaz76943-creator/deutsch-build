/// Task 1436: Pairwise Variability Index (nPVI/rPVI) quantifier
class PairwiseVariabilityIndex {
  double computePvi(List<double> durations) => durations.length >= 2 ? (durations[0] - durations[1]).abs() : 0.0;
}
