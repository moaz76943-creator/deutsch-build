/// Standard 3D facial blendshape coefficients for conversational avatar (0.0 to 1.0).
class FacialBlendshapes {
  final double smileIntensity;
  final double browRaise;
  final double attentiveTilt;
  final double nodAmplitude;

  const FacialBlendshapes({
    required this.smileIntensity,
    required this.browRaise,
    required this.attentiveTilt,
    required this.nodAmplitude,
  });
}

/// Dynamic synthesizer controlling empathetic non-verbal feedback during conversational flow.
class FacialEmotionSynthesizer {
  /// Computes appropriate avatar facial expression corresponding to dialogue feedback.
  FacialBlendshapes synthesizeExpression({
    required bool isLearnerCorrect,
    required bool isListeningAttentively,
    required bool isExplainingGrammar,
  }) {
    if (isListeningAttentively) {
      return const FacialBlendshapes(
        smileIntensity: 0.35,
        browRaise: 0.15,
        attentiveTilt: 0.65,
        nodAmplitude: 0.40,
      );
    }

    if (isLearnerCorrect) {
      return const FacialBlendshapes(
        smileIntensity: 0.85,
        browRaise: 0.40,
        attentiveTilt: 0.10,
        nodAmplitude: 0.75, // Approving nod
      );
    }

    if (isExplainingGrammar) {
      return const FacialBlendshapes(
        smileIntensity: 0.20,
        browRaise: 0.30,
        attentiveTilt: 0.20,
        nodAmplitude: 0.10,
      );
    }

    // Neutral baseline
    return const FacialBlendshapes(
      smileIntensity: 0.10,
      browRaise: 0.0,
      attentiveTilt: 0.0,
      nodAmplitude: 0.0,
    );
  }
}
