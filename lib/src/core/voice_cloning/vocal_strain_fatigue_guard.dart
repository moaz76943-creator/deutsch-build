class VocalHealthMetrics {
  final double acousticJitterPercent;    // Target < 1.04%
  final double acousticShimmerPercent;   // Target < 3.8%
  final double harmonicsToNoiseRatioDb;  // Target > 15 dB
  final int continuousSpeakingMinutes;
  final double vocalFatigueIndex;        // 0.0 (fresh) to 1.0 (exhausted)
  final bool requiresRestBreak;
  final String healthAdvisoryNotice;

  const VocalHealthMetrics({
    required this.acousticJitterPercent,
    required this.acousticShimmerPercent,
    required this.harmonicsToNoiseRatioDb,
    required this.continuousSpeakingMinutes,
    required this.vocalFatigueIndex,
    required this.requiresRestBreak,
    required this.healthAdvisoryNotice,
  });

  Map<String, dynamic> toJson() => {
    'acousticJitterPercent': acousticJitterPercent,
    'acousticShimmerPercent': acousticShimmerPercent,
    'harmonicsToNoiseRatioDb': harmonicsToNoiseRatioDb,
    'continuousSpeakingMinutes': continuousSpeakingMinutes,
    'vocalFatigueIndex': vocalFatigueIndex,
    'requiresRestBreak': requiresRestBreak,
    'healthAdvisoryNotice': healthAdvisoryNotice,
  };
}

class VocalStrainFatigueGuard {
  const VocalStrainFatigueGuard();

  /// Evaluates micro-perturbation acoustics to safeguard learner vocal cords against strain.
  VocalHealthMetrics assessVocalStrain({
    required double jitterPercent,
    required double shimmerPercent,
    required double hnrDb,
    required int sessionMinutes,
  }) {
    // Acoustic indicators of vocal fold fatigue: elevated jitter/shimmer and declining HNR
    double fatigueScore = 0.0;
    if (jitterPercent > 1.04) fatigueScore += 0.35;
    if (shimmerPercent > 3.80) fatigueScore += 0.35;
    if (hnrDb < 15.0) fatigueScore += 0.20;
    if (sessionMinutes > 30) fatigueScore += 0.20;

    final double normalizedIndex = fatigueScore.clamp(0.0, 1.0);
    final bool restNeeded = normalizedIndex >= 0.70 || sessionMinutes >= 45;

    String advice;
    if (restNeeded) {
      advice = 'Deine Stimme zeigt Anzeichen von Ermüdung. Trinke einen Schluck warmes Wasser und mache 3 Minuten Stimmpause.';
    } else if (normalizedIndex >= 0.40) {
      advice = 'Stimme leicht beansprucht. Achte auf entspannte Bauchatmung und lockere Kiefermuskulatur.';
    } else {
      advice = 'Stimmbänder klingen klar, entspannt und vital. Weiter so!';
    }

    return VocalHealthMetrics(
      acousticJitterPercent: jitterPercent,
      acousticShimmerPercent: shimmerPercent,
      harmonicsToNoiseRatioDb: hnrDb,
      continuousSpeakingMinutes: sessionMinutes,
      vocalFatigueIndex: double.parse(normalizedIndex.toStringAsFixed(2)),
      requiresRestBreak: restNeeded,
      healthAdvisoryNotice: advice,
    );
  }
}
