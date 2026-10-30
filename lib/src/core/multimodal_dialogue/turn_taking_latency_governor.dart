/// Detects micro-interruptions and controls natural conversational pacing under 120ms latency.
class TurnTakingLatencyGovernor {
  final int maxAllowedTurnDelayMs;
  final double voiceActivityThreshold;

  const TurnTakingLatencyGovernor({
    this.maxAllowedTurnDelayMs = 120,
    this.voiceActivityThreshold = 0.45,
  });

  /// Evaluates incoming audio energy to detect instantaneous user speech barge-in.
  bool detectBargeIn({
    required double currentMicrophoneEnergy,
    required bool isBotCurrentlySpeaking,
  }) {
    if (!isBotCurrentlySpeaking) return false;
    return currentMicrophoneEnergy >= voiceActivityThreshold;
  }

  /// Calculates turn-taking fluidity score based on response latency.
  double evaluateTurnPacing(int actualLatencyMs) {
    if (actualLatencyMs <= maxAllowedTurnDelayMs) {
      return 100.0;
    }
    // Exponential decay as latency approaches uncomfortable awkward pause (> 800ms)
    final penalty = (actualLatencyMs - maxAllowedTurnDelayMs) * 0.12;
    return (100.0 - penalty).clamp(0.0, 100.0);
  }
}
