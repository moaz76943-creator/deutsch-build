import 'dart:math';

/// Recommendation for targeted pronunciation drill.
enum RemedialDrillType {
  minimalPairDiscrimination,
  slowMotionShadowing,
  syllableStressFocus,
  none,
}

/// Dynamic adjustment recommendation for FSRS memory parameters.
class FsrsPronunciationAdjustment {
  final String itemId;
  final double stabilityMultiplier; // e.g. 0.7 (downgrade on poor pronunciation)
  final double difficultyDelta;      // e.g. +0.8 (increase difficulty)
  final RemedialDrillType recommendedDrill;

  const FsrsPronunciationAdjustment({
    required this.itemId,
    required this.stabilityMultiplier,
    required this.difficultyDelta,
    required this.recommendedDrill,
  });
}

/// Links pronunciation evaluation directly to FSRS cognitive scheduling parameters.
class PronunciationRemediationFsrsEngine {
  const PronunciationRemediationFsrsEngine();

  /// Computes FSRS adjustments based on overall pronunciation accuracy and mispronounced phonemes.
  FsrsPronunciationAdjustment calculateAdjustment({
    required String itemId,
    required double pronunciationScore,
    required bool hasMisplacedStress,
    required bool hasVowelErrors,
  }) {
    if (pronunciationScore >= 85.0 && !hasMisplacedStress) {
      // Flawless pronunciation: Reward memory retention
      return FsrsPronunciationAdjustment(
        itemId: itemId,
        stabilityMultiplier: 1.15,
        difficultyDelta: -0.2,
        recommendedDrill: RemedialDrillType.none,
      );
    } else if (pronunciationScore >= 65.0) {
      // Minor errors: Slight stability hold
      return FsrsPronunciationAdjustment(
        itemId: itemId,
        stabilityMultiplier: 0.90,
        difficultyDelta: 0.1,
        recommendedDrill: hasMisplacedStress ? RemedialDrillType.syllableStressFocus : RemedialDrillType.none,
      );
    } else {
      // Severe acoustic errors: Aggressive memory downgrade to force earlier review
      final drill = hasVowelErrors
          ? RemedialDrillType.minimalPairDiscrimination
          : RemedialDrillType.slowMotionShadowing;

      return FsrsPronunciationAdjustment(
        itemId: itemId,
        stabilityMultiplier: 0.65, // Force review sooner
        difficultyDelta: 0.60,      // Increase FSRS difficulty
        recommendedDrill: drill,
      );
    }
  }
}
