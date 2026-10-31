import 'dart:math';
import 'dart:typed_data';

/// High-performance time-scale modification of speech audio using WSOLA.
/// Modifies tempo (0.5x to 2.0x) while preserving original acoustic pitch.
class WsolaTimeStretchingProcessor {
  final int windowSize; // Usually 20-30ms (~512 samples at 22050Hz)
  final int searchRange; // Cross-correlation search delta (~128 samples)

  const WsolaTimeStretchingProcessor({
    this.windowSize = 512,
    this.searchRange = 128,
  });

  /// Processes 16-bit mono PCM samples and returns pitch-invariant time-stretched buffer.
  Int16List process(Int16List input, {required double tempoRatio}) {
    final ratio = tempoRatio.clamp(0.5, 2.0);

    // If ratio is near 1.0, return copy directly with zero overhead
    if ((ratio - 1.0).abs() < 0.01 || input.length < windowSize * 2) {
      return Int16List.fromList(input);
    }

    final int inputLength = input.length;
    final int estimatedOutputLength = (inputLength / ratio).round();
    final output = Int16List(estimatedOutputLength);

    final int halfWindow = windowSize ~/ 2;
    int inputIdx = 0;
    int outputIdx = 0;

    while (inputIdx + windowSize + searchRange < inputLength &&
        outputIdx + halfWindow < estimatedOutputLength) {
      // Find best overlap position minimizing phase cancellation
      int bestOffset = 0;
      double maxCorrelation = -double.infinity;

      final targetWindow = inputIdx;
      for (int delta = -searchRange; delta <= searchRange; delta += 4) {
        final candidateIdx = targetWindow + delta;
        if (candidateIdx < 0 || candidateIdx + halfWindow >= inputLength) continue;

        double correlation = 0.0;
        for (int k = 0; k < halfWindow; k += 8) {
          correlation += (input[candidateIdx + k] * input[targetWindow + k]);
        }

        if (correlation > maxCorrelation) {
          maxCorrelation = correlation;
          bestOffset = delta;
        }
      }

      final copyStart = inputIdx + bestOffset;
      final copyLength = min(halfWindow, estimatedOutputLength - outputIdx);

      // Overlap-add with linear crossfade
      for (int i = 0; i < copyLength; i++) {
        final double weight = i / copyLength;
        final int currentSample = output[outputIdx + i];
        final int newSample = input[copyStart + i];
        final blended = (currentSample * (1.0 - weight) + newSample * weight).round();
        output[outputIdx + i] = blended.clamp(-32768, 32767);
      }

      outputIdx += copyLength;
      inputIdx += (halfWindow * ratio).round();
    }

    // Return trimmed actual generated buffer
    return output.sublist(0, min(outputIdx, output.length));
  }
}
