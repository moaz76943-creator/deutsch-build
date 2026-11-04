/// Task 1568: Heaviest-subtree fork choice rule for conflicting DAG branches
class DagForkChoiceRule {
  String chooseHeaviestBranch(Map<String, int> branchWeights) => branchWeights.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}
