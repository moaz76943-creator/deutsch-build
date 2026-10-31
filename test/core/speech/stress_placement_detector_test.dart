import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/stress_placement_detector.dart';

void main() {
  group('StressPlacementDetector Tests', () {
    const detector = StressPlacementDetector();

    test('Identifies primary stress on first syllable correctly (Kühlschrank)', () {
      final syllables = [
        const SyllableAcousticEnergy(text: 'Kühl', rmsEnergy: 85.0, durationMs: 400, peakPitchHz: 180.0), // High prominence
        const SyllableAcousticEnergy(text: 'schrank', rmsEnergy: 40.0, durationMs: 250, peakPitchHz: 130.0),
      ];

      final result = detector.evaluateStress(
        syllables: syllables,
        expectedStressIndex: 0,
      );

      expect(result.isStressCorrect, isTrue);
      expect(result.detectedStressIndex, equals(0));
      expect(result.feedback, contains('رائع'));
    });

    test('Detects misplaced stress and provides actionable feedback', () {
      final syllables = [
        const SyllableAcousticEnergy(text: 'ge', rmsEnergy: 20.0, durationMs: 150, peakPitchHz: 120.0),
        const SyllableAcousticEnergy(text: 'hen', rmsEnergy: 90.0, durationMs: 450, peakPitchHz: 210.0), // Erroneously stressed
      ];

      final result = detector.evaluateStress(
        syllables: syllables,
        expectedStressIndex: 0, // In German root verbs, stem carries stress
      );

      expect(result.isStressCorrect, isFalse);
      expect(result.detectedStressIndex, equals(1));
      expect(result.feedback, contains('انتبه'));
    });
  });
}
