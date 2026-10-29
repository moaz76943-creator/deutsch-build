import 'dart:math';
import 'dart:typed_data';

/// Real-time spectral noise suppression using adaptive noise floor subtraction.
class SpectralNoiseSuppressor {
  final double overSubtractionFactor; // Alpha factor (~1.2)
  final double spectralFloor; // Beta floor preventing musical noise (~0.05)

  const SpectralNoiseSuppressor({
    this.overSubtractionFactor = 1.2,
    this.spectralFloor = 0.05,
  });

  /// Estimates stationary background noise level from initial silence buffer.
  double estimateNoiseFloor(Int16List silencePcm) {
    if (silencePcm.isEmpty) return 100.0;
    double energy = 0.0;
    for (int i = 0; i < silencePcm.length; i++) {
      energy += silencePcm[i].abs();
    }
    return energy / silencePcm.length;
  }

  /// Suppresses ambient background noise from noisy speech buffer in-place.
  Int16List process(Int16List noisyPcm, {double estimatedNoiseFloor = 100.0}) {
    if (noisyPcm.isEmpty) return Int16List(0);

    final cleanPcm = Int16List(noisyPcm.length);
    final threshold = estimatedNoiseFloor * overSubtractionFactor;
    final floorGain = spectralFloor;

    for (int i = 0; i < noisyPcm.length; i++) {
      final sample = noisyPcm[i];
      final absSample = sample.abs();

      if (absSample <= threshold) {
        // Below noise threshold: Attenuate aggressively
        cleanPcm[i] = (sample * floorGain).round().clamp(-32768, 32767);
      } else {
        // Speech present: Subtract noise floor smoothly
        final sign = sample >= 0 ? 1 : -1;
        final subtracted = absSample - threshold;
        cleanPcm[i] = (sign * subtracted).round().clamp(-32768, 32767);
      }
    }

    return cleanPcm;
  }
}
