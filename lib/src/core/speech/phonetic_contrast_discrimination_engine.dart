/// Evaluation result for a specific acoustic minimal pair contrast.
class ContrastDiagnosticResult {
  final String targetPhoneme;
  final String confusedPhoneme;
  final bool isAccuratelyDiscriminated;
  final double voiceOnsetDeltaMs;
  final String correctiveAdvice;

  const ContrastDiagnosticResult({
    required this.targetPhoneme,
    required this.confusedPhoneme,
    required this.isAccuratelyDiscriminated,
    required this.voiceOnsetDeltaMs,
    required this.correctiveAdvice,
  });
}

/// Diagnoses high-friction cross-linguistic phonetic confusion pairs.
class PhoneticContrastDiscriminationEngine {
  const PhoneticContrastDiscriminationEngine();

  /// Evaluates acoustic voice onset time (VOT) to distinguish voiced vs voiceless plosives (e.g. P vs B).
  ContrastDiagnosticResult evaluatePlosiveContrast({
    required String targetPhoneme,
    required double measuredVotMs, // Voice Onset Time in milliseconds
  }) {
    final isTargetVoicelessP = targetPhoneme.toLowerCase() == 'p';

    // Voiceless 'P' requires long positive VOT (> 30ms with aspiration)
    // Voiced 'B' has short or negative VOT (< 20ms)
    final bool isCorrect = isTargetVoicelessP
        ? measuredVotMs >= 35.0
        : measuredVotMs < 25.0;

    String advice;
    if (isCorrect) {
      advice = 'رائع! التمييز الصوتي بين المخرجين دقيق ومثالي.';
    } else {
      advice = isTargetVoicelessP
          ? 'انتبه: نطقت حرف (P) كأنه (B). حبس الهواء بقوة وإطلاقه دفعة واحدة (Aspiration) ضروري لنطق P.'
          : 'انتبه: خفف اندفاع الهواء ليكون الحرف جهرياً ناعماً (B).';
    }

    return ContrastDiagnosticResult(
      targetPhoneme: targetPhoneme,
      confusedPhoneme: isTargetVoicelessP ? 'b' : 'p',
      isAccuratelyDiscriminated: isCorrect,
      voiceOnsetDeltaMs: measuredVotMs,
      correctiveAdvice: advice,
    );
  }
}
