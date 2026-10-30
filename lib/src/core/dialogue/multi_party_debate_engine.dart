enum DebateRole {
  moderator,
  proponent,
  opponent,
  learner,
}

enum DebateStage {
  introduction,
  proArgument,
  contraArgument,
  learnerInput,
  conclusion,
}

class DebateStatement {
  final DebateRole speakerRole;
  final String speakerName;
  final String text;

  const DebateStatement({
    required this.speakerRole,
    required this.speakerName,
    required this.text,
  });
}

class DebateRoundResult {
  final DebateStage nextStage;
  final List<DebateStatement> newStatements;
  final bool learnerTurnCompleted;
  final String? argumentationFeedback;

  const DebateRoundResult({
    required this.nextStage,
    required this.newStatements,
    required this.learnerTurnCompleted,
    this.argumentationFeedback,
  });
}

class MultiPartyDebateEngine {
  final String debateTopic;
  DebateStage currentStage;

  MultiPartyDebateEngine({
    this.debateTopic = 'Homeoffice vs. Präsenzpflicht im Büro',
    this.currentStage = DebateStage.introduction,
  });

  /// Starts the debate round by generating moderator intro and proponent/opponent perspectives.
  DebateRoundResult initiateDebate() {
    currentStage = DebateStage.learnerInput;

    final intro = [
      const DebateStatement(
        speakerRole: DebateRole.moderator,
        speakerName: 'Moderator Felix',
        text: 'Herzlich willkommen zu unserer Diskussionsrunde. Heute diskutieren wir über das Thema: Homeoffice oder Büro?',
      ),
      const DebateStatement(
        speakerRole: DebateRole.proponent,
        speakerName: 'Markus (Pro-Homeoffice)',
        text: 'Homeoffice spart enorm viel Pendelzeit und fördert eine bessere Work-Life-Balance für Beschäftigte.',
      ),
      const DebateStatement(
        speakerRole: DebateRole.opponent,
        speakerName: 'Sabine (Pro-Präsenz)',
        text: 'Dagegen spricht jedoch, dass der persönliche Austausch im Team und die Innovationskraft im Büro viel höher sind.',
      ),
      const DebateStatement(
        speakerRole: DebateRole.moderator,
        speakerName: 'Moderator Felix',
        text: 'Wie sehen Sie das? Welche Erfahrungen haben Sie gemacht?',
      ),
    ];

    return DebateRoundResult(
      nextStage: DebateStage.learnerInput,
      newStatements: intro,
      learnerTurnCompleted: false,
    );
  }

  /// Evaluates learner argumentation and wraps up the debate round.
  DebateRoundResult submitLearnerArgument(String argument) {
    final lower = argument.trim().toLowerCase();
    String feedback;

    // Check for advanced argumentation connectors
    if (lower.contains('einerseits') || lower.contains('andererseits') || lower.contains('meiner meinung') || lower.contains('stimme')) {
      feedback = 'Ausgezeichnete Argumentationsstruktur mit differenzierter Wortwahl!';
    } else {
      feedback = 'Guter Standpunkt! Tipp: Nutzen Sie Redemittel wie "Meiner Ansicht nach..." oder "Ich stimme Markus zu, weil...".';
    }

    currentStage = DebateStage.conclusion;

    final wrapUp = [
      DebateStatement(
        speakerRole: DebateRole.learner,
        speakerName: 'Learner',
        text: argument,
      ),
      const DebateStatement(
        speakerRole: DebateRole.moderator,
        speakerName: 'Moderator Felix',
        text: 'Vielen Dank für Ihren wertvollen Beitrag! Beide Seiten haben starke Argumente vorgebracht. Damit schließen wir diese Runde.',
      ),
    ];

    return DebateRoundResult(
      nextStage: DebateStage.conclusion,
      newStatements: wrapUp,
      learnerTurnCompleted: true,
      argumentationFeedback: feedback,
    );
  }
}
