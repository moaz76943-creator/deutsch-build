/// Task 1756: Fuzzy match repair through subword and term substitution
class FuzzyRepairInterpolator {
  String repairSegment(String fuzzyTarget, String oldWord, String newWord) => fuzzyTarget.replaceAll(oldWord, newWord);
}
