/// Task 2071: Separable prefix relocator placing prefixes at sentence end in main clauses
class SeparablePrefixSyntaxReorderEngine {
  List<String> reorderMainClause(String prefix, List<String> clauseTokens) => [...clauseTokens, prefix];
}
