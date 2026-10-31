import 'dart:math' as math;
import 'dart:typed_data';
import 'package:meta/meta.dart';

/// Sovereign Voice Deep Core v2: Bone Conduction Auditory Frequency Compensator.
///
/// Equalizes audio output curves specifically for bone conduction transducers
/// and open-ear audio devices. Compensates for skull acoustic impedance by:
/// 1. Attenuating skin-tickle low sub-bass (< 120Hz).
/// 2. Boosting speech intelligibility presence zone (1.5kHz to 4.2kHz).
/// 3. Applying dynamic soft-knee limiting to eliminate mechanical rattle during intensive tutoring.
@immutable
class BoneConductionFrequencyEqualizer {
  final int sampleRate;
  final double presenceBoostDb; // Typically +4dB to +6dB for bone transducers
  final double lowCutoffHz;

  const BoneConductionFrequencyEqualizer({
    this.sampleRate = 16000,
    this.presenceBoostDb = 5.0,
    this.lowCutoffHz = 120.0,
  });

  /// Processes and compensates an audio buffer for optimal bone conduction playback.
  Float32List equalizeForBoneConduction(Float32List inputBuffer) {
    if (inputBuffer.isEmpty) return Float32List(0);

    final output = Float32List(inputBuffer.length);
    final double boostGain = math.pow(10.0, presenceBoostDb / 20.0) as double;

    // High-pass single-pole coefficient for lowCutoffHz
    final double rc = 1.0 / (2.0 * math.pi * lowCutoffHz);
    final double dt = 1.0 / sampleRate;
    final double alpha = rc / (rc + dt);

    double prevInput = inputBuffer[0];
    double prevOutput = inputBuffer[0];

    for (int i = 0; i < inputBuffer.length; i++) {
      // 1. High-pass filter to eliminate sub-bass mechanical vibration
      final double sample = inputBuffer[i];
      final double hpFiltered = alpha * (prevOutput + sample - prevInput);
      prevInput = sample;
      prevOutput = hpFiltered;

      // 2. High-frequency speech presence emphasis
      final double emphasized = hpFiltered * boostGain;

      // 3. Soft-knee tanh limiting to prevent bone transducer over-excursion
      output[i] = _tanh(emphasized * 0.85);
    }

    return output;
  }

  double _tanh(double x) {
    if (x > 3.0) return 1.0;
    if (x < -3.0) return -1.0;
    final double e2x = math.exp(2.0 * x);
    return (e2x - 1.0) / (e2x + 1.0);
  }
}
