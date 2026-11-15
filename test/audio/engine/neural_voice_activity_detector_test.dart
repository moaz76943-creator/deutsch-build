import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/audio/engine/neural_voice_activity_detector.dart';

void main() {
  group('NeuralVoiceActivityDetector Tests', () {
    const vad = NeuralVoiceActivityDetector();

    test('Initializes with standard 16kHz and speech threshold', () {
      expect(vad.sampleRate, equals(16000));
      expect(vad.speechThresholdDb, equals(-38.0));
      expect(vad.hangoverFrameCount, equals(5));
    });

    test('Detects speech frame with high confidence', () {
      final speechFrame = Float32List(160);
      for (int i = 0; i < 160; i++) {
        speechFrame[i] = 0.25 * (i % 8 < 4 ? 1.0 : -1.0);
      }
      final result = vad.evaluateFrame(speechFrame);
      expect(result.isSpeech, isTrue);
      expect(result.confidence, greaterThan(0.5));
      expect(result.isArtifact, isFalse);
    });

    test('Rejects high-frequency breathing noise as artifact', () {
      final breathFrame = Float32List(160);
      for (int i = 0; i < 160; i++) {
        // High ZCR noise with low energy
        breathFrame[i] = 0.015 * (i % 2 == 0 ? 1.0 : -1.0);
      }
      final result = vad.evaluateFrame(breathFrame);
      expect(result.isArtifact, isTrue);
    });
  });
}
