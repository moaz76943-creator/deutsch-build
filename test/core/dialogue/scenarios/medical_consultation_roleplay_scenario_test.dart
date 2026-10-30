import 'package:test/test.dart';
import 'package:deutsch_build/src/core/dialogue/scenarios/medical_consultation_roleplay_scenario.dart';

void main() {
  group('MedicalConsultationRoleplayScenario Tests', () {
    test('Simulates complete patient-doctor consultation workflow', () {
      final scenario = MedicalConsultationRoleplayScenario();
      expect(scenario.currentPhase, equals(MedicalPhase.greetingAndSymptoms));

      final turn1 = scenario.evaluatePatientTurn('Guten Tag Frau Doktor, ich fühle mich sehr schlecht und habe Halsschmerzen.');
      expect(turn1.goalAchieved, isTrue);
      expect(turn1.nextPhase, equals(MedicalPhase.durationAndPainSeverity));

      final turn2 = scenario.evaluatePatientTurn('Ich habe seit drei Tagen hohes Fieber und starke Schmerzen.');
      expect(turn2.goalAchieved, isTrue);
      expect(turn2.nextPhase, equals(MedicalPhase.allergiesAndMedication));

      final turn3 = scenario.evaluatePatientTurn('Nein, ich habe keine bekannten Allergien.');
      expect(turn3.goalAchieved, isTrue);
      expect(turn3.nextPhase, equals(MedicalPhase.prescriptionAndSickNote));

      final turn4 = scenario.evaluatePatientTurn('Vielen Dank für das Rezept und die Krankschreibung. Auf Wiedersehen!');
      expect(turn4.goalAchieved, isTrue);
      expect(turn4.nextPhase, equals(MedicalPhase.completed));
    });

    test('Provides idiomatic correction for non-standard pain phrasing', () {
      final scenario = MedicalConsultationRoleplayScenario();
      final result = scenario.evaluatePatientTurn('Ich habe Schmerz im Kopf seit gestern.');

      expect(result.correctionHint, isNotNull);
      expect(result.correctionHint!.originalText, equals('Schmerz im Kopf'));
      expect(result.correctionHint!.idiomaticExpression, contains('Kopfschmerzen'));
    });
  });
}
