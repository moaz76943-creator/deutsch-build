/// A discrete growth area highlighted from conversational dialogue.
class GrowthCard {
  final String originalLearnerUtterance;
  final String nativeRecastCorrection;
  final String linguisticDomain; // grammar, vocabulary, pronunciation
  final String explanatoryTip;

  const GrowthCard({
    required this.originalLearnerUtterance,
    required this.nativeRecastCorrection,
    required this.linguisticDomain,
    required this.explanatoryTip,
  });
}

/// Post-session dialogue debrief report summarizing strengths and actionable flashcards.
class SessionDebriefReport {
  final int totalTurns;
  final double fluencyScore;
  final List<String> celebratedStrengths;
  final List<GrowthCard> extractedFlashcards;

  const SessionDebriefReport({
    required this.totalTurns,
    required this.fluencyScore,
    required this.celebratedStrengths,
    required this.extractedFlashcards,
  });
}

/// Generates pedagogical post-dialogue debriefs without lowering affective filter during live flow.
class DialogueFeedbackHighlighter {
  /// Compiles a post-session debrief highlighting up to 3 high-leverage growth cards.
  SessionDebriefReport compileDebrief({
    required int sessionTurns,
    required double accuracyRatio,
    required List<GrowthCard> loggedSlips,
  }) {
    final strengths = <String>[];
    if (sessionTurns >= 8) {
      strengths.add('Hervorragende Ausdauer: Langes, ununterbrochenes Gespräch geführt.');
    }
    if (accuracyRatio >= 0.70) {
      strengths.add('Gute Verständlichkeit: Der rote Faden blieb stets klar.');
    } else {
      strengths.add('Mutiger Sprecheinsatz: Neue Satzstrukturen ausprobiert.');
    }

    // Keep only top 3 high-impact growth cards to prevent cognitive overload
    final selectedCards = loggedSlips.take(3).toList();

    return SessionDebriefReport(
      totalTurns: sessionTurns,
      fluencyScore: double.parse((accuracyRatio * 100.0).toStringAsFixed(1)),
      celebratedStrengths: strengths,
      extractedFlashcards: selectedCards,
    );
  }
}
