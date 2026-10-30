/// Hesitation diagnosis and confidence booster action.
class HesitationIntervention {
  final bool requiresIntervention;
  final String supportiveCue;
  final double confidenceScore;

  const HesitationIntervention({
    required this.requiresIntervention,
    required this.supportiveCue,
    required this.confidenceScore,
  });
}

/// Detects prolonged conversational silence and offers reassuring lexical scaffolding.
class HesitationReductionCoach {
  final double silenceAlertThresholdSeconds;

  const HesitationReductionCoach({this.silenceAlertThresholdSeconds = 4.5});

  /// Evaluates ongoing silence and provides immediate encouraging sentence starters.
  HesitationIntervention checkSilence({
    required double currentSilenceSeconds,
    required String currentTopic,
  }) {
    if (currentSilenceSeconds < silenceAlertThresholdSeconds) {
      return const HesitationIntervention(
        requiresIntervention: false,
        supportiveCue: '',
        confidenceScore: 1.0,
      );
    }

    // Learner is freezing: provide empathetic bridge
    String promptStarter;
    if (currentTopic.toLowerCase().contains('essen')) {
      promptStarter = 'Kein Stress! Du kannst anfangen mit: "Ich esse gern..."';
    } else if (currentTopic.toLowerCase().contains('reise')) {
      promptStarter = 'Nimm dir Zeit. Versuch es mit: "Letztes Jahr war ich in..."';
    } else {
      promptStarter = 'Ganz ruhig, versuch es einfach in deinen eigenen Worten!';
    }

    return HesitationIntervention(
      requiresIntervention: true,
      supportiveCue: promptStarter,
      confidenceScore: (1.0 - (currentSilenceSeconds / 10.0)).clamp(0.2, 0.6),
    );
  }
}
