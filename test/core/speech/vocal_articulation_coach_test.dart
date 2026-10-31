import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/vocal_articulation_coach.dart';

void main() {
  group('VocalArticulationCoach Tests', () {
    const coach = VocalArticulationCoach();

    test('Provides physical lip and tongue instructions for German ö vowel', () {
      final guidance = coach.getGuidance('øː');

      expect(guidance, isNotNull);
      expect(guidance!.lipPosition, contains('استدر الشفتين'));
      expect(guidance.practiceTip, contains('انطق صوت (ee)'));
    });

    test('Provides distinct guidance for Ich-Laut vs Ach-Laut', () {
      final ichLaut = coach.getGuidance('ç');
      final achLaut = coach.getGuidance('χ');

      expect(ichLaut, isNotNull);
      expect(achLaut, isNotNull);
      expect(ichLaut!.airflowType, contains('احتكاك هوائي سلس'));
      expect(achLaut!.airflowType, contains('الخاء'));
    });
  });
}
