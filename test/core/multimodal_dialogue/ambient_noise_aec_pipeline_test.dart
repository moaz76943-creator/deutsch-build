import 'package:test/test.dart';
import '../../lib/src/core/multimodal_dialogue/ambient_noise_aec_pipeline.dart';

void main() {
  group('AmbientNoiseAecPipeline Unit Tests (N066)', () {
    const pipeline = AmbientNoiseAecPipeline(noiseFloorThreshold: 0.05, echoCancellationFactor: 0.85);

    test('Cancels speaker echo leakage from microphone audio frame', () {
      final speakerLeakage = [0.4, 0.5, 0.3];
      final micInputWithLeak = [0.35, 0.42, 0.26]; // Microphone capturing speaker sound

      final frame = pipeline.processFrame(
        micInputSamples: micInputWithLeak,
        speakerOutputReference: speakerLeakage,
      );

      // Residual should fall under noise floor threshold and be gated to 0.0
      expect(frame.cleanSamples.every((s) => s.abs() <= 0.05), isTrue);
      expect(frame.echoSuppressionDb, greaterThan(20.0));
    });

    test('Preserves strong learner speech while attenuating mild background hum', () {
      final speechMic = [0.8, -0.75, 0.9, -0.85];
      final silentSpeaker = [0.0, 0.0, 0.0, 0.0];

      final frame = pipeline.processFrame(
        micInputSamples: speechMic,
        speakerOutputReference: silentSpeaker,
      );

      expect(frame.containsSpeech, isTrue);
      expect(frame.snrDb, greaterThan(15.0));
      expect(frame.cleanSamples.first, closeTo(0.8, 0.01));
    });

    test('Empty audio handles safely', () {
      final frame = pipeline.processFrame(micInputSamples: [], speakerOutputReference: []);
      expect(frame.cleanSamples, isEmpty);
      expect(frame.containsSpeech, isFalse);
    });
  });
}
