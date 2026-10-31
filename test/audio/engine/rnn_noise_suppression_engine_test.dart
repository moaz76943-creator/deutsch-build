import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/audio/engine/rnn_noise_suppression_engine.dart';

void main() {
  group('RnnNoiseSuppressionEngine Tests', () {
    const engine = RnnNoiseSuppressionEngine();

    test('Algorithmic latency meets strict < 15ms ceiling', () {
      expect(engine.algorithmicLatencyMs, equals(10.0));
      expect(engine.algorithmicLatencyMs, lessThanOrEqualTo(15.0));
      expect(engine.frameSize, equals(160));
    });

    test('Passes speech signal while attenuating low-level background noise', () {
      // Create noisy frame (low amplitude noise)
      final noiseFrame = Float32List(160);
      for (int i = 0; i < 160; i++) {
        noiseFrame[i] = 0.005 * (i % 2 == 0 ? 1.0 : -1.0);
      }
      final cleanedNoise = engine.processFrame(noiseFrame);
      expect(cleanedNoise[0].abs(), lessThan(noiseFrame[0].abs()));

      // Create speech frame (high amplitude signal)
      final speechFrame = Float32List(160);
      for (int i = 0; i < 160; i++) {
        speechFrame[i] = 0.6 * (i % 2 == 0 ? 1.0 : -1.0);
      }
      final cleanedSpeech = engine.processFrame(speechFrame);
      expect(cleanedSpeech[0].abs(), greaterThan(0.2));
    });
  });
}
