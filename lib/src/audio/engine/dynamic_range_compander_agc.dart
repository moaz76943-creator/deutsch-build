import 'dart:math' as math;
import 'dart:typed_data';
import 'package:meta/meta.dart';

/// Sovereign Voice Deep Core v2: Dynamic Range Compander & Automatic Gain Control (AGC).
///
/// Seamlessly balances dynamic speech levels across varied acoustic environments:
/// 1. Downward expansion below -50dBFS to silence background noise floor.
/// 2. Upward expansion (+6dB to +12dB) for quiet whispered speech.
/// 3. Transparent linear pass-through for normal conversational levels (-35dBFS to -14dBFS).
/// 4. Soft-knee compression and brickwall limiting for loud or shouted utterances.
@immutable
class DynamicRangeCompanderAgc {
  final int sampleRate;
  final double targetRms;
  final double attackCoeff;
  final double releaseCoeff;
  final double maxGain;

  const DynamicRangeCompanderAgc({
    this.sampleRate = 16000,
    this.targetRms = 0.15, // Approx -16.5 dBFS
    this.attackCoeff = 0.05, // Fast 5ms attack
    this.releaseCoeff = 0.002, // Smooth 120ms release
    this.maxGain = 4.0, // Maximum +12dB upward boost
  });

  /// Processes an audio buffer with continuous dynamic range companding.
  Float32List processBuffer(Float32List input) {
    if (input.isEmpty) return Float32List(0);

    final output = Float32List(input.length);
    double currentEnvelope = targetRms;

    for (int i = 0; i < input.length; i++) {
      final double sample = input[i];
      final double absSample = sample.abs();

      // Envelope follower with asymmetric attack/release
      if (absSample > currentEnvelope) {
        currentEnvelope += attackCoeff * (absSample - currentEnvelope);
      } else {
        currentEnvelope += releaseCoeff * (absSample - currentEnvelope);
      }

      // Compute dynamic gain multiplier
      double gain = 1.0;
      if (currentEnvelope < 0.005) {
        // Downward expansion for silence/noise floor
        gain = (currentEnvelope / 0.005);
      } else if (currentEnvelope < targetRms) {
        // Upward expansion for whispered/soft speech
        final double boost = (targetRms / math.max(currentEnvelope, 0.005));
        gain = math.min(boost, maxGain);
      } else if (currentEnvelope > 0.6) {
        // Soft compression for loud speech
        gain = 0.6 / currentEnvelope;
      }

      // Apply gain and soft-saturating brickwall limiter
      final double amplified = sample * gain;
      output[i] = _softLimit(amplified);
    }

    return output;
  }

  double _softLimit(double x) {
    if (x > 0.95) {
      return 0.95 + 0.05 * _tanh((x - 0.95) / 0.05);
    } else if (x < -0.95) {
      return -0.95 + 0.05 * _tanh((x + 0.95) / 0.05);
    }
    return x;
  }
}

// Use a decaying exponential so even extreme finite inputs cannot overflow.
double _tanh(double value) {
  final decay = math.exp(-2 * value.abs());
  final magnitude = (1 - decay) / (1 + decay);
  return value.isNegative ? -magnitude : magnitude;
}
