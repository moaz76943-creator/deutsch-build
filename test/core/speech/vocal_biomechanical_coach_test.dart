import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/speech/vocal_biomechanical_coach.dart';

void main() {
  test('Returns accurate articulatory guidance for German rounded vowel ü', () {
    const coach = VocalBiomechanicalCoach();
    final guide = coach.getGuidance('y');
    expect(guide, isNotNull);
    expect(guide!.lipShape, contains('rounded'));
  });
}
