/// Conversational emotional valence.
enum ConversationalEmotion {
  encouraging, // High pitch warmth, gentle falling cadence
  curiousInquiry, // Rising intonation at sentence ending
  neutralClarity, // Balanced baseline
  celebratoryExcitement, // Elevated pitch variance and dynamic range
}

/// Prosodic modulation parameters for speech synthesizer.
class ProsodyParameters {
  final double pitchShiftSemitones;
  final double energyMultiplier;
  final double finalIntonationRiseHz;
  final double speechTempo;

  const ProsodyParameters({
    required this.pitchShiftSemitones,
    required this.energyMultiplier,
    required this.finalIntonationRiseHz,
    required this.speechTempo,
  });
}

/// Modulates pitch contour (F0) and prosodic contours according to emotional intent.
class ProsodyEmotionModulator {
  /// Computes speech synthesis prosody adjustments for a target emotion.
  ProsodyParameters computeParameters(ConversationalEmotion emotion) {
    switch (emotion) {
      case ConversationalEmotion.curiousInquiry:
        return const ProsodyParameters(
          pitchShiftSemitones: 0.5,
          energyMultiplier: 1.0,
          finalIntonationRiseHz: 25.0, // High final rise for questions
          speechTempo: 1.0,
        );
      case ConversationalEmotion.encouraging:
        return const ProsodyParameters(
          pitchShiftSemitones: 1.2,
          energyMultiplier: 1.05,
          finalIntonationRiseHz: -10.0, // Warm gentle settling
          speechTempo: 0.95,
        );
      case ConversationalEmotion.celebratoryExcitement:
        return const ProsodyParameters(
          pitchShiftSemitones: 2.5,
          energyMultiplier: 1.25,
          finalIntonationRiseHz: 15.0,
          speechTempo: 1.10,
        );
      case ConversationalEmotion.neutralClarity:
        return const ProsodyParameters(
          pitchShiftSemitones: 0.0,
          energyMultiplier: 1.0,
          finalIntonationRiseHz: 0.0,
          speechTempo: 1.0,
        );
    }
  }
}
