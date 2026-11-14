import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/audio/engine/phonetic_distance_diagnostic_engine.dart';

void main() {
  group('PhoneticDistanceDiagnosticEngine Tests', () {
    const diagnostic = PhoneticDistanceDiagnosticEngine();

    test('Diagnoses perfect match with zero distance and positive feedback', () {
      const nativeY = PhoneticFeatureVector(
        tongueHeight: 0.9,
        tongueBackness: 0.1,
        lipRounding: 0.9,
        voicing: 1.0,
        nasality: 0.0,
        constrictionDegree: 0.0,
      );

      final guide = diagnostic.diagnoseMismatch(learner: nativeY, nativeTarget: nativeY);
      expect(guide.totalDistance, equals(0.0));
      expect(guide.primarySummary, contains('native-like'));
    });

    test('Generates clear physiological instructions when lips are unrounded', () {
      // Learner says [i] (unrounded) instead of target [y] (rounded)
      const learnerI = PhoneticFeatureVector(
        tongueHeight: 0.9,
        tongueBackness: 0.1,
        lipRounding: 0.0, // Error: unrounded!
        voicing: 1.0,
        nasality: 0.0,
        constrictionDegree: 0.0,
      );
      const targetY = PhoneticFeatureVector(
        tongueHeight: 0.9,
        tongueBackness: 0.1,
        lipRounding: 0.9, // Expected: rounded!
        voicing: 1.0,
        nasality: 0.0,
        constrictionDegree: 0.0,
      );

      final guide = diagnostic.diagnoseMismatch(learner: learnerI, nativeTarget: targetY);
      expect(guide.totalDistance, greaterThan(0.5));
      expect(guide.roundingAdvice, contains('round your lips'));
    });
  });
}
