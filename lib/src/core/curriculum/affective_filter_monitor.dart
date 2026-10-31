/// Current state of the learner's affective filter and stress level.
class AffectiveState {
  final double filterScore; // 0.0 (completely receptive/calm) to 1.0 (blocked/stressed)
  final bool isHighFilter;
  final String cognitivePacingAction;
  final double recommendedDifficultyMultiplier;

  const AffectiveState({
    required this.filterScore,
    required this.isHighFilter,
    required this.cognitivePacingAction,
    required this.recommendedDifficultyMultiplier,
  });
}

/// Dynamically monitors response latencies, corrections, and fatigue to lower affective filter.
class AffectiveFilterMonitor {
  final double highFilterThreshold;

  const AffectiveFilterMonitor({this.highFilterThreshold = 0.65});

  /// Evaluates session metrics to estimate subconscious barrier height.
  AffectiveState evaluateSession({
    required double averageLatencySeconds,
    required int backspaceCorrectionsCount,
    required int consecutiveMistakes,
    required int sessionDurationMinutes,
  }) {
    // Normal latency baseline: 1.5 - 3.5s. Anything > 6.0s indicates hesitation/stress
    final latencyStress = ((averageLatencySeconds - 2.5) / 5.0).clamp(0.0, 0.4);
    final errorStress = (consecutiveMistakes * 0.15).clamp(0.0, 0.35);
    final hesitationStress = (backspaceCorrectionsCount * 0.03).clamp(0.0, 0.15);
    final fatigueFactor = (sessionDurationMinutes > 30 ? 0.15 : 0.0);

    final totalScore = (latencyStress + errorStress + hesitationStress + fatigueFactor).clamp(0.0, 1.0);
    final isHigh = totalScore >= highFilterThreshold;

    String action;
    double diffMultiplier;

    if (totalScore >= 0.75) {
      action = 'Emergency De-escalation: Switch to passive story listening or enjoyable low-stakes chimes.';
      diffMultiplier = 0.60;
    } else if (isHigh) {
      action = 'Moderate Filter: Lower syntactic complexity, add glossing scaffolds, and offer encouragement.';
      diffMultiplier = 0.80;
    } else {
      action = 'Optimal Receptivity: Learner in flow state. Proceed with standard i+1 curriculum.';
      diffMultiplier = 1.0;
    }

    return AffectiveState(
      filterScore: double.parse(totalScore.toStringAsFixed(2)),
      isHighFilter: isHigh,
      cognitivePacingAction: action,
      recommendedDifficultyMultiplier: diffMultiplier,
    );
  }
}
