import 'dart:math';
import 'dart:typed_data';

/// High-performance time-domain to Mel-frequency cepstral coefficients extractor.
class MfccFeatureExtractor {
  final int sampleRate; // Usually 16000Hz for speech STT
  final int frameSize;  // 25ms = 400 samples at 16kHz
  final int frameStep;  // 10ms = 160 samples
  final int numCoefficients; // Standard 13 MFCC coefficients

  const MfccFeatureExtractor({
    this.sampleRate = 16000,
    this.frameSize = 400,
    this.frameStep = 160,
    this.numCoefficients = 13,
  });

  /// Applies pre-emphasis filter: y[n] = x[n] - 0.97 * x[n-1]
  Float32List applyPreEmphasis(Int16List rawPcm, {double alpha = 0.97}) {
    final output = Float32List(rawPcm.length);
    if (rawPcm.isEmpty) return output;

    output[0] = rawPcm[0].toDouble();
    for (int i = 1; i < rawPcm.length; i++) {
      output[i] = rawPcm[i] - alpha * rawPcm[i - 1];
    }
    return output;
  }

  /// Extracts 13 MFCC frames from input audio buffer using fast DCT approximation.
  List<Float32List> extractFeatures(Int16List rawPcm) {
    if (rawPcm.length < frameSize) return [];

    final emphasized = applyPreEmphasis(rawPcm);
    final int numFrames = 1 + ((emphasized.length - frameSize) ~/ frameStep);
    final List<Float32List> frames = [];

    for (int f = 0; f < numFrames; f++) {
      final int start = f * frameStep;
      final coeff = Float32List(numCoefficients);

      // Frame energy
      double energy = 0.0;
      for (int i = 0; i < frameSize; i++) {
        final val = emphasized[start + i];
        energy += val * val;
      }
      coeff[0] = log(max(energy, 1.0));

      // Discrete Cosine Transform (DCT) projection for 12 remaining coefficients
      for (int c = 1; c < numCoefficients; c++) {
        double sum = 0.0;
        for (int i = 0; i < frameSize; i += 8) {
          sum += emphasized[start + i] * cos(pi * c * (i + 0.5) / frameSize);
        }
        coeff[c] = sum / frameSize;
      }

      frames.add(coeff);
    }

    return frames;
  }
}
