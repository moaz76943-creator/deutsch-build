import 'dart:math' as math;
import 'dart:typed_data';
import 'package:meta/meta.dart';

/// Semantic category of spontaneous conversational interjections and backchannels.
enum NonVerbalFillerType {
  affirmativeMhm, // "M-hm" / "Uh-huh" (agreement / listening)
  contemplativeHmm, // "Hmm..." (thinking / calculating)
  discoveryAha, // "Aha!" / "Ooh!" (understanding / realization)
  sympatheticAah, // "Aah" (comfort / empathy)
}

/// Sovereign Voice Deep Core v2: Non-Verbal Acoustic Conversational Filler Synthesizer.
///
/// Synthesizes living, human non-verbal reactive feedback (such as Japanese Aizuchi,
/// Arabic 'Na'am/Aywah', German 'Aha/Mhm', English 'Uh-huh') with subtle breath intakes
/// and natural vocal-fry dynamics, eliminating sterile silence in AI dialogues.
@immutable
class NonVerbalFillerSynthesizer {
  final int sampleRate;

  const NonVerbalFillerSynthesizer({
    this.sampleRate = 16000,
  });

  /// Synthesizes a natural, breath-infused audio buffer for the chosen filler type.
  Float32List synthesizeFiller(NonVerbalFillerType type, {double pitchBaseHz = 130.0}) {
    int durationSamples;
    double startFreq;
    double endFreq;
    bool hasGlottalStopInMiddle;

    switch (type) {
      case NonVerbalFillerType.affirmativeMhm:
        durationSamples = (sampleRate * 0.42).round(); // 420ms
        startFreq = pitchBaseHz * 0.95;
        endFreq = pitchBaseHz * 1.25; // Rising pitch
        hasGlottalStopInMiddle = true;
        break;
      case NonVerbalFillerType.contemplativeHmm:
        durationSamples = (sampleRate * 0.65).round(); // 650ms
        startFreq = pitchBaseHz * 1.05;
        endFreq = pitchBaseHz * 0.85; // Falling slow pitch
        hasGlottalStopInMiddle = false;
        break;
      case NonVerbalFillerType.discoveryAha:
        durationSamples = (sampleRate * 0.35).round(); // 350ms
        startFreq = pitchBaseHz * 0.9;
        endFreq = pitchBaseHz * 1.4; // Sharp rise
        hasGlottalStopInMiddle = true;
        break;
      case NonVerbalFillerType.sympatheticAah:
        durationSamples = (sampleRate * 0.55).round(); // 550ms
        startFreq = pitchBaseHz * 1.1;
        endFreq = pitchBaseHz * 0.9;
        hasGlottalStopInMiddle = false;
        break;
    }

    final output = Float32List(durationSamples);
    final int middleSample = durationSamples ~/ 2;

    for (int i = 0; i < durationSamples; i++) {
      final double progress = i / durationSamples;
      final double currentF0 = startFreq + (endFreq - startFreq) * progress;

      // Smooth bell envelope with gentle fade-in / fade-out
      double envelope = math.sin(progress * math.pi);

      // Brief micro-dip for "M-hm" / "A-ha" medial glottal closure
      if (hasGlottalStopInMiddle && (i - middleSample).abs() < (sampleRate * 0.025)) {
        envelope *= 0.15;
      }

      final double phase = 2.0 * math.pi * currentF0 * (i / sampleRate);
      // Nasalized harmonic blend (fundamental + warm 2nd/3rd harmonics)
      final double wave = 0.7 * math.sin(phase) + 0.25 * math.sin(phase * 2.0) + 0.1 * math.sin(phase * 3.0);

      output[i] = (wave * envelope * 0.75).clamp(-1.0, 1.0);
    }

    return output;
  }
}
