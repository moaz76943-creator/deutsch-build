/// Task 2093: Work contract clause educational analyzer (Arbeitsvertrag)
class WorkContractClauseAnalyzer {
  bool isValidClause(String clause) => clause.contains('Kündigungsfrist') || clause.contains('Probezeit');
}
