class AccentReductionFeedback {
  final String phoneme;
  final double accuracyPercentage;
  final String diagnosedMotherTongueTransfer;
  final String targetMotorTip;

  const AccentReductionFeedback({
    required this.phoneme,
    required this.accuracyPercentage,
    required this.diagnosedMotherTongueTransfer,
    required this.targetMotorTip,
  });
}

class AccentReductionMatrix {
  const AccentReductionMatrix();

  AccentReductionFeedback evaluatePronunciationError(String targetPhoneme, String detectedNativeSubstitute) {
    if (targetPhoneme == 'p' && detectedNativeSubstitute == 'b') {
      return const AccentReductionFeedback(
        phoneme: 'p',
        accuracyPercentage: 45.0,
        diagnosedMotherTongueTransfer: 'Arabic lack of unvoiced bilabial plosive /p/ (aspirated).',
        targetMotorTip: 'Build air pressure behind both lips and release with a burst of air (puff a candle).',
      );
    }
    return AccentReductionFeedback(
      phoneme: targetPhoneme,
      accuracyPercentage: 85.0,
      diagnosedMotherTongueTransfer: 'Minor acoustic variance.',
      targetMotorTip: 'Articulate cleanly with consistent breath support.',
    );
  }
}
