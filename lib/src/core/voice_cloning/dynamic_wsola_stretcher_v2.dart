import 'dart:math' as math;
import 'dart:typed_data';

class DynamicWsolaStretcherV2 {
  static const int windowSize = 512;
  static const int hopSize = 256;

  const DynamicWsolaStretcherV2();

  /// Time-scale expands speech by stretchFactor (e.g. 0.6x speed = 1.66x duration) without pitch distortion.
  Int16List timeStretchPcm(Int16List inputPcm, double speedMultiplier) {
    if (inputPcm.isEmpty || speedMultiplier <= 0) return Int16List(0);
    if ((speedMultiplier - 1.0).abs() < 0.02) return Int16List.fromList(inputPcm);

    final double expansionRatio = 1.0 / speedMultiplier.clamp(0.4, 2.0);
    final int outputLength = (inputPcm.length * expansionRatio).round();
    final output = Int16List(outputLength);

    int inPos = 0;
    int outPos = 0;

    // Overlap-Add synthesis loop with triangular cross-fade windowing
    while (outPos + windowSize < outputLength && inPos + windowSize < inputPcm.length) {
      for (int i = 0; i < windowSize; i++) {
        final double window = 0.5 * (1.0 - math.cos(2.0 * math.pi * i / (windowSize - 1)));
        final double sample = inputPcm[inPos + i] * window;
        output[outPos + i] = (output[outPos + i] + sample).clamp(-32768.0, 32767.0).round();
      }

      inPos += hopSize;
      outPos += (hopSize * expansionRatio).round();
    }

    return output;
  }
}
