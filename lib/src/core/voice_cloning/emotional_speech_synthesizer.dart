enum SpeechEmotion {
  neutralTutor,
  encouragingExcited,
  inquiringCurious,
  calmWhisper,
  formalAdministrative,
}

class EmotionAcousticParameters {
  final double pitchScale;
  final double tempoScale;
  final double energyDynamics;
  final double whisperBreathiness;

  const EmotionAcousticParameters({
    required this.pitchScale,
    required this.tempoScale,
    required this.energyDynamics,
    this.whisperBreathiness = 0.0,
  });
}

class EmotionalSpeechSynthesizer {
  static const Map<SpeechEmotion, EmotionAcousticParameters> profiles = {
    SpeechEmotion.neutralTutor: EmotionAcousticParameters(pitchScale: 1.0, tempoScale: 1.0, energyDynamics: 1.0),
    SpeechEmotion.encouragingExcited: EmotionAcousticParameters(pitchScale: 1.15, tempoScale: 1.08, energyDynamics: 1.3),
    SpeechEmotion.inquiringCurious: EmotionAcousticParameters(pitchScale: 1.08, tempoScale: 0.96, energyDynamics: 1.1),
    SpeechEmotion.calmWhisper: EmotionAcousticParameters(pitchScale: 0.92, tempoScale: 0.88, energyDynamics: 0.5, whisperBreathiness: 0.4),
    SpeechEmotion.formalAdministrative: EmotionAcousticParameters(pitchScale: 0.98, tempoScale: 1.02, energyDynamics: 0.9),
  };

  const EmotionalSpeechSynthesizer();

  EmotionAcousticParameters resolveParameters(SpeechEmotion emotion) => profiles[emotion]!;
}
