import 'dart:math' as math;
import 'dart:typed_data';

enum HapticPatternType {
  lightTap,
  successDoublePulse,
  levelUpCelebration,
  gentleEncouragement,
}

class HapticPulse {
  final int durationMs;
  final double intensity; // 0.0 to 1.0

  const HapticPulse(this.durationMs, this.intensity);
}

class ProceduralTone {
  final double frequencyHz;
  final int durationMs;
  final double attackMs;
  final double decayMs;

  const ProceduralTone({
    required this.frequencyHz,
    required this.durationMs,
    this.attackMs = 10.0,
    this.decayMs = 40.0,
  });
}

class HapticAudioChimesSynthesizer {
  static const int sampleRate = 22050; // Standard low-RAM audio rate

  const HapticAudioChimesSynthesizer();

  /// Synthesizes short, pleasant, harmonic pentatonic chime for correct answer:
  /// C5 (523.25 Hz) -> E5 (659.25 Hz) -> G5 (783.99 Hz)
  Int16List synthesizeSuccessChime() {
    final tones = [
      const ProceduralTone(frequencyHz: 523.25, durationMs: 80),
      const ProceduralTone(frequencyHz: 659.25, durationMs: 80),
      const ProceduralTone(frequencyHz: 783.99, durationMs: 140),
    ];
    return _renderTonesSequence(tones);
  }

  /// Synthesizes a warm, non-punitive gentle chime for review retry.
  Int16List synthesizeGentleRetryChime() {
    final tones = [
      const ProceduralTone(frequencyHz: 392.00, durationMs: 90), // G4
      const ProceduralTone(frequencyHz: 329.63, durationMs: 120), // E4
    ];
    return _renderTonesSequence(tones);
  }

  /// Synthesizes celebratory multi-chord fanfare for level-up.
  Int16List synthesizeLevelUpFanfare() {
    final tones = [
      const ProceduralTone(frequencyHz: 523.25, durationMs: 60), // C5
      const ProceduralTone(frequencyHz: 659.25, durationMs: 60), // E5
      const ProceduralTone(frequencyHz: 783.99, durationMs: 60), // G5
      const ProceduralTone(frequencyHz: 1046.50, durationMs: 200), // C6
    ];
    return _renderTonesSequence(tones);
  }

  /// Returns vibration duration/intensity sequence for haptic actuator.
  List<HapticPulse> getHapticPattern(HapticPatternType type) {
    switch (type) {
      case HapticPatternType.lightTap:
        return const [HapticPulse(12, 0.4)];
      case HapticPatternType.successDoublePulse:
        return const [HapticPulse(15, 0.7), HapticPulse(30, 0.0), HapticPulse(25, 0.9)];
      case HapticPatternType.levelUpCelebration:
        return const [
          HapticPulse(20, 0.5),
          HapticPulse(20, 0.0),
          HapticPulse(30, 0.8),
          HapticPulse(20, 0.0),
          HapticPulse(60, 1.0),
        ];
      case HapticPatternType.gentleEncouragement:
        return const [HapticPulse(18, 0.3)];
    }
  }

  Int16List _renderTonesSequence(List<ProceduralTone> tones) {
    int totalSamples = 0;
    for (final tone in tones) {
      totalSamples += (sampleRate * (tone.durationMs / 1000.0)).round();
    }

    final pcm = Int16List(totalSamples);
    int offset = 0;

    for (final tone in tones) {
      final int toneSamples = (sampleRate * (tone.durationMs / 1000.0)).round();
      final double angularFreq = 2.0 * math.pi * tone.frequencyHz;

      for (int i = 0; i < toneSamples; i++) {
        final double t = i / sampleRate;
        final double progress = i / toneSamples;

        // Envelope: linear attack, exponential decay
        double envelope = 1.0;
        if (t * 1000.0 < tone.attackMs) {
          envelope = (t * 1000.0) / tone.attackMs;
        } else {
          envelope = math.exp(-3.5 * progress);
        }

        // Pure harmonic sine wave with 10% overtone for richness
        final double sampleValue = (math.sin(angularFreq * t) + 0.1 * math.sin(angularFreq * 2.0 * t)) * envelope;
        final int int16Val = (sampleValue * 30000.0).clamp(-32768.0, 32767.0).round();
        pcm[offset + i] = int16Val;
      }
      offset += toneSamples;
    }

    return pcm;
  }
}
