/// Speech fluency and cadence metrics report.
class SpeechFluencyMetrics {
  final double wordsPerMinute; // WPM
  final double articulationRate; // Syllables per second
  final double pauseRatio; // Percentage of time spent in silence/hesitation
  final String estimatedCefrFluency;
  final double recommendedAiSpeedMultiplier;

  const SpeechFluencyMetrics({
    required this.wordsPerMinute,
    required this.articulationRate,
    required this.pauseRatio,
    required this.estimatedCefrFluency,
    required this.recommendedAiSpeedMultiplier,
  });
}

/// Dynamically paces AI persona speech rate to match learner CEFR comprehension bandwidth.
class SpeechRatePacer {
  /// Evaluates learner speech metrics and prescribes adaptive bot tempo.
  SpeechFluencyMetrics evaluateFluency({
    required int totalWords,
    required double totalDurationSeconds,
    required double silenceDurationSeconds,
  }) {
    if (totalDurationSeconds <= 0 || totalWords <= 0) {
      return const SpeechFluencyMetrics(
        wordsPerMinute: 0.0,
        articulationRate: 0.0,
        pauseRatio: 1.0,
        estimatedCefrFluency: 'A1',
        recommendedAiSpeedMultiplier: 0.85,
      );
    }

    final wpm = (totalWords / totalDurationSeconds) * 60.0;
    final speakingDuration = math.max(0.1, totalDurationSeconds - silenceDurationSeconds);
    // Approximation: 1.5 syllables per word
    final articulationRate = (totalWords * 1.5) / speakingDuration;
    final pauseRatio = (silenceDurationSeconds / totalDurationSeconds).clamp(0.0, 1.0);

    String cefr;
    double speedMultiplier;

    if (wpm < 85 || pauseRatio > 0.45) {
      cefr = 'A1';
      speedMultiplier = 0.80; // Slow down model speech for clear comprehension
    } else if (wpm < 115 || pauseRatio > 0.35) {
      cefr = 'A2';
      speedMultiplier = 0.90;
    } else if (wpm < 145) {
      cefr = 'B1';
      speedMultiplier = 1.00; // Normal tempo
    } else if (wpm < 175) {
      cefr = 'B2';
      speedMultiplier = 1.05;
    } else {
      cefr = 'C1/C2';
      speedMultiplier = 1.15; // Natural fast native cadence
    }

    return SpeechFluencyMetrics(
      wordsPerMinute: double.parse(wpm.toStringAsFixed(1)),
      articulationRate: double.parse(articulationRate.toStringAsFixed(2)),
      pauseRatio: double.parse(pauseRatio.toStringAsFixed(2)),
      estimatedCefrFluency: cefr,
      recommendedAiSpeedMultiplier: speedMultiplier,
    );
  }
}
