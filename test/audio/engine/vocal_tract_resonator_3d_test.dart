import 'package:test/test.dart';
import 'package:deutsch_build/src/audio/engine/vocal_tract_resonator_3d.dart';

void main() {
  group('VocalTractResonator3D Tests', () {
    const resonator = VocalTractResonator3D();

    test('3D vocal tract resonator parameters initialize accurately', () {
      expect(resonator.tubeSectionsCount, equals(44));
      expect(resonator.vocalTractLengthCm, equals(17.5));
    });

    test('Simulates formant trajectory shifts based on articulatory parameters', () {
      // High-front rounded vowel (e.g. [y] / ü)
      final stateY = resonator.simulateResonance(
        tongueHeight: 0.9,
        tongueAdvancement: 0.9,
        lipRounding: 0.9,
      );
      // Low-back unrounded vowel (e.g. [a])
      final stateA = resonator.simulateResonance(
        tongueHeight: 0.1,
        tongueAdvancement: 0.1,
        lipRounding: 0.0,
      );

      expect(stateY.f1Hz, lessThan(stateA.f1Hz)); // High vowels have lower F1!
      expect(stateY.f2Hz, greaterThan(stateA.f2Hz)); // Front vowels have higher F2!
      expect(stateY.lipProtrusion, greaterThan(stateA.lipProtrusion));
    });

    test('Computes acoustic distance error reliably', () {
      final target = resonator.simulateResonance(tongueHeight: 0.8, tongueAdvancement: 0.8, lipRounding: 0.8);
      final exactMatch = resonator.simulateResonance(tongueHeight: 0.8, tongueAdvancement: 0.8, lipRounding: 0.8);
      final divergent = resonator.simulateResonance(tongueHeight: 0.2, tongueAdvancement: 0.2, lipRounding: 0.0);

      expect(resonator.computeAcousticDistance(exactMatch, target), equals(0.0));
      expect(resonator.computeAcousticDistance(divergent, target), greaterThan(0.3));
    });
  });
}
