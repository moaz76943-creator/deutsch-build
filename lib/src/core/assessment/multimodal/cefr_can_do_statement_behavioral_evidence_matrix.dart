/// Task 1488: CEFR 'Can-Do' behavioral competency evidence accumulator
class CefrCanDoEvidenceMatrix {
  final Map<String, int> _evidence = {};
  void recordEvidence(String canDoCode) => _evidence[canDoCode] = (_evidence[canDoCode] ?? 0) + 1;
  bool isCompetencyVerified(String canDoCode) => (_evidence[canDoCode] ?? 0) >= 3;
}
