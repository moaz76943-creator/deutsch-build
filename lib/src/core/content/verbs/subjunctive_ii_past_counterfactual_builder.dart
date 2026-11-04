/// Task 2064: Konjunktiv II counterfactual condition generator (hätte/wäre + Partizip II)
class SubjunctiveCounterfactualBuilder {
  String buildCondition(String subject, String verbStem, bool usesSein) => usesSein ? '$subject wäre gereist' : '$subject hätte gelernt';
}
