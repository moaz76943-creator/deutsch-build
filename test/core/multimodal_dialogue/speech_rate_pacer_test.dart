import 'package:test/test.dart';
import '../../lib/src/core/multimodal_dialogue/speech_rate_pacer.dart';

void main() {
  group('SpeechRatePacer Unit Tests (N068)', () {
    final pacer = SpeechRatePacer();

    test('Evaluates hesitant A1 speech and slows AI model tempo to 0.80x', () {
      final metrics = pacer.evaluateFluency(
        totalWords: 15,
        totalDurationSeconds: 20.0, // 45 WPM
        silenceDurationSeconds: 10.0, // 50% hesitation
      );

      expect(metrics.estimatedCefrFluency, equals('A1'));
      expect(metrics.recommendedAiSpeedMultiplier, equals(0.80));
      expect(metrics.wordsPerMinute, equals(45.0));
      expect(metrics.pauseRatio, equals(0.50));
    });

    test('Evaluates fluent B2 conversation and keeps AI model tempo at 1.05x', () {
      final metrics = pacer.evaluateFluency(
        totalWords: 160,
        totalDurationSeconds: 60.0, // 160 WPM
        silenceDurationSeconds: 8.0,
      );

      expect(metrics.estimatedCefrFluency, equals('B2'));
      expect(metrics.recommendedAiSpeedMultiplier, equals(1.05));
      expect(metrics.wordsPerMinute, equals(160.0));
    });

    test('Zero words handles gracefully with default safe pacing', () {
      final metrics = pacer.evaluateFluency(
        totalWords: 0,
        totalDurationSeconds: 10.0,
        silenceDurationSeconds: 10.0,
      );

      expect(metrics.wordsPerMinute, equals(0.0));
      expect(metrics.estimatedCefrFluency, equals('A1'));
      expect(metrics.recommendedAiSpeedMultiplier, equals(0.85));
    });
  });
}
