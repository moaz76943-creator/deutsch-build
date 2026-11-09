import 'dart:math';
import 'dart:typed_data';

/// Voice activity detection classification result for a frame.
class VadFrameDecision {
  final bool isSpeech;
  final double rootMeanSquareEnergy;
  final int zeroCrossingRate;

  VadFrameDecision({
    required this.isSpeech,
    required this.rootMeanSquareEnergy,
    required this.zeroCrossingRate,
  });
}

/// Zero-lag, lightweight Voice Activity Detector (VAD) for pronunciation exercises.
/// Trims leading and trailing silence without requiring neural inference or cloud APIs.
class OfflineVoiceActivityDetector {
  final double energyThreshold;
  final int minZcrThreshold;

  OfflineVoiceActivityDetector({
    this.energyThreshold = 250.0,
    this.minZcrThreshold = 10,
  });

  /// Analyze a 20ms mono 16-bit PCM frame (e.g. 480 samples at 24kHz).
  VadFrameDecision analyzeFrame(Uint8List pcmFrameBytes) {
    final sampleCount = pcmFrameBytes.length ~/ 2;
    if (sampleCount == 0) {
      return VadFrameDecision(isSpeech: false, rootMeanSquareEnergy: 0.0, zeroCrossingRate: 0);
    }

    final view = ByteData.sublistView(pcmFrameBytes);
    double sumSquares = 0.0;
    int zeroCrossings = 0;
    int? prevSample;

    for (int i = 0; i < sampleCount; i++) {
      final sample = view.getInt16(i * 2, Endian.little);
      sumSquares += sample * sample;

      if (prevSample != null) {
        if ((prevSample >= 0 && sample < 0) || (prevSample < 0 && sample >= 0)) {
          zeroCrossings++;
        }
      }
      prevSample = sample;
    }

    final rmsEnergy = sqrt(sumSquares / sampleCount);
    final isSpeech = rmsEnergy > energyThreshold || (rmsEnergy > 100.0 && zeroCrossings > minZcrThreshold);

    return VadFrameDecision(
      isSpeech: isSpeech,
      rootMeanSquareEnergy: rmsEnergy,
      zeroCrossingRate: zeroCrossings,
    );
  }
}
