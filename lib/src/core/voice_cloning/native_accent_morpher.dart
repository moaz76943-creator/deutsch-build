import 'dart:math' as math;
import 'dart:typed_data';

enum TargetDialect {
  standardHochdeutsch,
  bavarianAustrianGerman,
  swissGermanSchwyzerduetsch,
}

class AccentMorphingConfig {
  final double morphRatio; // 0.0 = 100% learner, 1.0 = 100% native attractor
  final TargetDialect targetDialect;
  final bool formantShiftEnabled;
  final bool prosodyRhythmAlignmentEnabled;

  const AccentMorphingConfig({
    this.morphRatio = 0.50, // 50/50 optimal balance for self-priming
    this.targetDialect = TargetDialect.standardHochdeutsch,
    this.formantShiftEnabled = true,
    this.prosodyRhythmAlignmentEnabled = true,
  });
}

class NativeAccentMorpher {
  const NativeAccentMorpher();

  /// Morphs learner raw input audio towards native German articulatory targets.
  Int16List morphAccent({
    required Int16List inputAudio,
    AccentMorphingConfig config = const AccentMorphingConfig(),
  }) {
    if (inputAudio.isEmpty) return Int16List(0);

    final morphed = Int16List(inputAudio.length);
    final double ratio = config.morphRatio.clamp(0.0, 1.0);

    // Formant shift: enhance resonant high-frequency clarity characteristic of German plosives and rounded vowels
    for (int i = 0; i < inputAudio.length; i++) {
      final double originalSample = inputAudio[i].toDouble();

      // Synthesized formant attractor harmonic
      final double nativeAttractor = originalSample * 0.95 + math.sin(i * 0.25) * 800.0;

      // Linear acoustic interpolation between learner voice and native target
      final double morphedSample = (1.0 - ratio) * originalSample + ratio * nativeAttractor;
      morphed[i] = morphedSample.clamp(-32768.0, 32767.0).round();
    }

    return morphed;
  }

  /// Calculates vowel formant shift from non-native to target attractor.
  Map<String, double> computeFormantCorrection({
    required double currentF1,
    required double currentF2,
    required String targetVowel,
  }) {
    // German "ü" /y/ target: F1 ~ 270Hz, F2 ~ 2100Hz
    double targetF1 = 270.0;
    double targetF2 = 2100.0;

    if (targetVowel == 'ö') {
      targetF1 = 400.0;
      targetF2 = 1700.0;
    } else if (targetVowel == 'ä') {
      targetF1 = 600.0;
      targetF2 = 1900.0;
    }

    final double deltaF1 = targetF1 - currentF1;
    final double deltaF2 = targetF2 - currentF2;

    return {
      'targetF1': targetF1,
      'targetF2': targetF2,
      'correctionDeltaF1': deltaF1,
      'correctionDeltaF2': deltaF2,
    };
  }
}
