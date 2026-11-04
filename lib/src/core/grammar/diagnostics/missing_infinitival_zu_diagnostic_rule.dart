/// Task 1347: Flags missing 'zu' before infinitive after perception verbs
class MissingZuDiagnosticRule {
  bool requiresZu(String matrixVerb) => matrixVerb == 'versuchen' || matrixVerb == 'hoffen';
}
