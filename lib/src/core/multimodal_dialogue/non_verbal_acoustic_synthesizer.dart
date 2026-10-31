/// Non-verbal communicative acoustic tokens.
enum NonVerbalCueType {
  thoughtfulHum, // "Hmm...", "Ach so!"
  gentleChuckle, // Warm light laughter
  affirmativeAha, // "Aha!", "Genau."
  breathInhale, // Natural breathing intake before long explanation
}

/// A non-verbal acoustic cue injection.
class AcousticCue {
  final NonVerbalCueType type;
  final String textRepresentation;
  final double durationSeconds;
  final double energyScale;

  const AcousticCue({
    required this.type,
    required this.textRepresentation,
    required this.durationSeconds,
    required this.energyScale,
  });
}

/// Injects conversational human-like non-verbal cues into TTS output stream.
class NonVerbalAcousticSynthesizer {
  /// Injects appropriate communicative cue before the spoken response.
  AcousticCue? selectCueForContext({
    required bool isPonderingComplexGrammar,
    required bool isAmusedOrPlayful,
    required bool isConfirmingUnderstanding,
  }) {
    if (isAmusedOrPlayful) {
      return const AcousticCue(
        type: NonVerbalCueType.gentleChuckle,
        textRepresentation: '(leises Lachen)',
        durationSeconds: 0.8,
        energyScale: 0.75,
      );
    }

    if (isPonderingComplexGrammar) {
      return const AcousticCue(
        type: NonVerbalCueType.thoughtfulHum,
        textRepresentation: 'Hmm... lass mich überlegen.',
        durationSeconds: 1.2,
        energyScale: 0.60,
      );
    }

    if (isConfirmingUnderstanding) {
      return const AcousticCue(
        type: NonVerbalCueType.affirmativeAha,
        textRepresentation: 'Ach so, verstehe!',
        durationSeconds: 0.7,
        energyScale: 0.80,
      );
    }

    return null;
  }

  /// Formats natural text response with non-verbal filler.
  String prependCue(String responseText, AcousticCue? cue) {
    if (cue == null) return responseText;
    return '${cue.textRepresentation} $responseText';
  }
}
