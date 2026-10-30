/// Strategy for repairing a communicative breakdown in live dialogue.
enum RepairStrategy {
  repetitionRequest, // "Wie bitte?", "Könnten Sie das wiederholen?"
  confirmationCheck, // "Meinen Sie...?", "Verstehe ich richtig, dass...?"
  recastCorrection, // Seamless implicit corrective feedback without breaking flow
  simplification, // Paraphrasing complex phrasing into high-frequency A1/A2 words
}

/// Generated conversational repair action.
class RepairAction {
  final RepairStrategy strategy;
  final String repairPrompt;
  final String underlyingIssue;

  const RepairAction({
    required this.strategy,
    required this.repairPrompt,
    required this.underlyingIssue,
  });
}

/// Scaffolds and recovers from conversational misunderstandings smoothly.
class ConversationalRepairEngine {
  /// Diagnoses utterance flaws and produces a pedagogical repair response.
  RepairAction generateRepair({
    required String learnerUtterance,
    required double acousticClarityScore, // 0.0 to 1.0
    required bool hasSyntaxError,
  }) {
    if (acousticClarityScore < 0.40) {
      return const RepairAction(
        strategy: RepairStrategy.repetitionRequest,
        repairPrompt: 'Entschuldigung, die Verbindung war undeutlich. Könntest du das bitte noch einmal sagen?',
        underlyingIssue: 'Low acoustic clarity / microphone muffled',
      );
    }

    if (hasSyntaxError) {
      // Recast correction: model the correct sentence gently
      return RepairAction(
        strategy: RepairStrategy.recastCorrection,
        repairPrompt: 'Ah, du möchtest sagen: "Ich gehe heute ins Kino." Sehr schön! Welchen Film schaust du?',
        underlyingIssue: 'Grammar word order / case mismatch',
      );
    }

    if (learnerUtterance.split(' ').length < 2) {
      return const RepairAction(
        strategy: RepairStrategy.confirmationCheck,
        repairPrompt: 'Meinst du das im Sinne von "Ja, gerne"? Erzähl mir etwas mehr dazu.',
        underlyingIssue: 'Extreme ellipsis / single-word fragment',
      );
    }

    return const RepairAction(
      strategy: RepairStrategy.simplification,
      repairPrompt: 'Lass es uns ganz einfach ausdrücken. Wie fühlst du dich heute?',
      underlyingIssue: 'Topic drift or hesitation',
    );
  }
}
