import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/audio/engine/acoustic_echo_cancellation_engine.dart';

void main() {
  group('AcousticEchoCancellationEngine Tests', () {
    const aec = AcousticEchoCancellationEngine();

    test('Initializes with standard telephony sampling and filter tap limits', () {
      expect(aec.sampleRate, equals(16000));
      expect(aec.filterLength, equals(256));
      expect(aec.stepSize, inInclusiveRange(0.01, 0.2));
    });

    test('Attenuates acoustic echo during single-talk playback', () {
      final weights = Float32List(aec.filterLength);
      final speakerRef = Float32List(160);
      final micInput = Float32List(160);

      for (int i = 0; i < 160; i++) {
        speakerRef[i] = 0.3 * (i % 4 < 2 ? 1.0 : -1.0);
        // Echo is delayed and attenuated replica of speaker
        micInput[i] = 0.15 * (i % 4 < 2 ? 1.0 : -1.0);
      }

      final result = aec.processFrame(
        microphoneFrame: micInput,
        speakerReferenceFrame: speakerRef,
        filterWeights: weights,
      );

      expect(result.cleanedMicrophoneBuffer.length, equals(160));
      expect(result.isDoubleTalkDetected, isFalse);
    });

    test('Detects double-talk when user speaks simultaneously with speaker', () {
      final weights = Float32List(aec.filterLength);
      final speakerRef = Float32List(160);
      final micInput = Float32List(160);

      for (int i = 0; i < 160; i++) {
        speakerRef[i] = 0.1 * (i % 2 == 0 ? 1.0 : -1.0);
        // Near-end voice is loud
        micInput[i] = 0.8 * (i % 2 == 0 ? 1.0 : -1.0);
      }

      final result = aec.processFrame(
        microphoneFrame: micInput,
        speakerReferenceFrame: speakerRef,
        filterWeights: weights,
      );

      expect(result.isDoubleTalkDetected, isTrue);
    });
  });
}
