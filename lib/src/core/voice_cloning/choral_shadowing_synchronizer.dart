class ShadowingSyncReport {
  final int lagLatencyMs; // Time difference between native guide and learner
  final double synchronyScorePercent; // 0.0% to 100.0%
  final bool isPacingAcceptable;
  final String rhythmGuidance;

  const ShadowingSyncReport({
    required this.lagLatencyMs,
    required this.synchronyScorePercent,
    required this.isPacingAcceptable,
    required this.rhythmGuidance,
  });

  Map<String, dynamic> toJson() => {
    'lagLatencyMs': lagLatencyMs,
    'synchronyScorePercent': synchronyScorePercent,
    'isPacingAcceptable': isPacingAcceptable,
    'rhythmGuidance': rhythmGuidance,
  };
}

class ChoralShadowingSynchronizer {
  static const int maxPermittedLagMs = 350;

  const ChoralShadowingSynchronizer();

  /// Compares syllable onset timestamps between native audio guide and learner shadowing attempt.
  ShadowingSyncReport evaluateShadowingSynchrony({
    required int nativeGuideOnsetMs,
    required int learnerSpeechOnsetMs,
  }) {
    final int lag = (learnerSpeechOnsetMs - nativeGuideOnsetMs).abs();
    final double rawScore = (1.0 - (lag / 500.0)).clamp(0.0, 1.0) * 100.0;
    final bool isAcceptable = lag <= maxPermittedLagMs;

    String advice;
    if (lag <= 120) {
      advice = 'Perfektes Choral-Timing! Du sprichst synchron wie im Chor mit dem Muttersprachler.';
    } else if (learnerSpeechOnsetMs > nativeGuideOnsetMs) {
      advice = 'Du bist etwas zu spät (${lag}ms Verzug). Versuche, den Silbenrhythmus flüssiger mitzuziehen.';
    } else {
      advice = 'Du antizipierst zu früh. Höre genau auf das Satzmelodie-Signal.';
    }

    return ShadowingSyncReport(
      lagLatencyMs: lag,
      synchronyScorePercent: double.parse(rawScore.toStringAsFixed(1)),
      isPacingAcceptable: isAcceptable,
      rhythmGuidance: advice,
    );
  }
}
