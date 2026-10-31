import 'package:test/test.dart';
import 'package:deutsch_build/src/audio/engine/emotional_prosody_modulator.dart';

void main() {
  group('EmotionalProsodyModulator Tests', () {
    const modulator = EmotionalProsodyModulator();

    test('Patient state reduces speech rate for clear Krashen comprehensible input', () {
      final patient = modulator.calculateParameters(PedagogicalAffectiveState.patientCalming);
      expect(patient.speechRateMultiplier, lessThan(1.0));
      expect(patient.breathinessRatio, greaterThan(0.05));
    });

    test('Celebratory state boosts energy and pitch dynamically', () {
      final proud = modulator.calculateParameters(PedagogicalAffectiveState.celebratoryProud);
      expect(proud.pitchShiftRatio, greaterThan(1.10));
      expect(proud.dynamicRangeBoostDb, greaterThan(2.0));
    });
  });
}
