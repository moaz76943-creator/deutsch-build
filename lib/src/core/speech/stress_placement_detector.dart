/// Acoustic metrics for an isolated spoken syllable.
class SyllableAcousticEnergy {
  final String text;
  final double rmsEnergy; // Root-mean-square amplitude
  final int durationMs;
  final double peakPitchHz;

  const SyllableAcousticEnergy({
    required this.text,
    required this.rmsEnergy,
    required this.durationMs,
    required this.peakPitchHz,
  });

  /// Composite prominence score = Energy * 0.5 + Duration * 0.3 + Pitch * 0.2
  double get prominenceScore =>
      (rmsEnergy * 0.5) + (durationMs * 0.3) + (peakPitchHz * 0.05);
}

/// Result of evaluating lexical stress placement.
class StressEvaluationResult {
  final int detectedStressIndex;
  final int expectedStressIndex;
  final bool isStressCorrect;
  final String feedback;

  const StressEvaluationResult({
    required this.detectedStressIndex,
    required this.expectedStressIndex,
    required this.isStressCorrect,
    required this.feedback,
  });
}

/// Detects acoustic primary stress based on energy, duration, and pitch peaks.
class StressPlacementDetector {
  const StressPlacementDetector();

  /// Evaluates which syllable carries primary acoustic prominence.
  StressEvaluationResult evaluateStress({
    required List<SyllableAcousticEnergy> syllables,
    required int expectedStressIndex,
  }) {
    if (syllables.isEmpty) {
      return const StressEvaluationResult(
        detectedStressIndex: -1,
        expectedStressIndex: -1,
        isStressCorrect: false,
        feedback: 'لم يتم رصد أي مقاطع صوتية.',
      );
    }

    int maxIdx = 0;
    double maxProminence = -1.0;

    for (int i = 0; i < syllables.length; i++) {
      final score = syllables[i].prominenceScore;
      if (score > maxProminence) {
        maxProminence = score;
        maxIdx = i;
      }
    }

    final isCorrect = maxIdx == expectedStressIndex;
    final feedback = isCorrect
        ? 'رائع! موقع نبرة الصوت (Stress) دقيق تماماً على المقطع المطلوب.'
        : 'انتبه: نبرة الصوت وقعت على المقطع "${syllables[maxIdx].text}"، بينما الصحيح أن تكون على المقطع "${syllables[expectedStressIndex].text}".';

    return StressEvaluationResult(
      detectedStressIndex: maxIdx,
      expectedStressIndex: expectedStressIndex,
      isStressCorrect: isCorrect,
      feedback: feedback,
    );
  }
}
