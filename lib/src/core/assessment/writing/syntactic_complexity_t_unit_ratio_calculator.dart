/// Task 1441: Mean Length of T-Unit (MLT) and Clauses per T-Unit (C/T)
class TUnitComplexityCalculator {
  double calculateMlt(int totalWords, int totalTUnits) => totalTUnits > 0 ? totalWords / totalTUnits : 0.0;
}
