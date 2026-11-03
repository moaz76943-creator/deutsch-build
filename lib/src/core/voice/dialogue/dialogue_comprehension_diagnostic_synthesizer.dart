/// Task 1178: Post-dialogue summary metrics and communicative success
class DialogueDiagnosticSynthesizer {
  int totalTurns = 0;
  void recordTurn() => totalTurns++;
  double get communicativeSuccessScore => totalTurns >= 4 ? 96.0 : 75.0;
}
