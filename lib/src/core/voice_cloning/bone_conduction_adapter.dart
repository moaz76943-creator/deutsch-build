import 'dart:math' as math;

/// Equalization mode for cranial bone-conduction transducers.
enum BoneConductionProfile {
  standard,
  speechClarityBoost,
  cranialResonanceDamping,
  bassCompensated,
}

/// Dynamic audio adapter tailoring voice synthesis to bone-conduction acoustics.
class BoneConductionAdapter {
  final BoneConductionProfile profile;
  final double cranialAbsorptionFactor;
  final bool enableRattleLimiter;

  const BoneConductionAdapter({
    this.profile = BoneConductionProfile.speechClarityBoost,
    this.cranialAbsorptionFactor = 1.35,
    this.enableRattleLimiter = true,
  });

  /// Applies cranial frequency correction and anti-rattle limiting to raw PCM samples.
  List<double> adaptSamples(List<double> inputSamples) {
    if (inputSamples.isEmpty) return [];

    final output = List<double>.filled(inputSamples.length, 0.0);
    double prevSample = 0.0;

    for (int i = 0; i < inputSamples.length; i++) {
      double sample = inputSamples[i];

      switch (profile) {
        case BoneConductionProfile.speechClarityBoost:
          // Pre-emphasis filter for formants attenuated by cranial bone mass (1kHz - 4kHz)
          final highBoost = sample - (0.45 * prevSample);
          sample = (sample * 0.6) + (highBoost * 0.7);
          break;
        case BoneConductionProfile.cranialResonanceDamping:
          // Low-pass dampening to eliminate low-frequency jawbone rattling
          sample = (sample * 0.7) + (prevSample * 0.3);
          break;
        case BoneConductionProfile.bassCompensated:
          // Compensates for natural low-end leakage in open-ear frames
          sample = sample * cranialAbsorptionFactor;
          break;
        case BoneConductionProfile.standard:
          break;
      }

      // Non-linear cranial rattle limiter (soft clipping curve)
      if (enableRattleLimiter) {
        if (sample > 0.85) {
          sample = 0.85 + (0.15 * math.tanh((sample - 0.85) / 0.15));
        } else if (sample < -0.85) {
          sample = -0.85 + (0.15 * math.tanh((sample + 0.85) / 0.15));
        }
      }

      output[i] = sample.clamp(-1.0, 1.0);
      prevSample = inputSamples[i];
    }

    return output;
  }

  /// Calculates the clarity index achieved after bone-conduction compensation.
  double evaluateClarity(List<double> adaptedSamples) {
    if (adaptedSamples.isEmpty) return 0.0;
    double energy = 0.0;
    for (final s in adaptedSamples) {
      energy += s.abs();
    }
    final avg = energy / adaptedSamples.length;
    return (avg * 100).clamp(0.0, 100.0);
  }
}
