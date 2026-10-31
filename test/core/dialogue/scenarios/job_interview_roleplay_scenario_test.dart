import 'package:test/test.dart';
import 'package:deutsch_build/src/core/dialogue/scenarios/job_interview_roleplay_scenario.dart';

void main() {
  group('JobInterviewRoleplayScenario Tests', () {
    test('Simulates complete structured interview progression', () {
      final scenario = JobInterviewRoleplayScenario();
      expect(scenario.currentPhase, equals(InterviewPhase.formalGreeting));

      final turn1 = scenario.evaluateCandidateTurn('Guten Tag Herr Dr. Hoffmann, es freut mich sehr.');
      expect(turn1.goalAchieved, isTrue);
      expect(turn1.nextPhase, equals(InterviewPhase.selfIntroductionAndExperience));

      final turn2 = scenario.evaluateCandidateTurn('Ich habe fünf Jahre Erfahrung im Bereich Softwareentwicklung gesammelt.');
      expect(turn2.goalAchieved, isTrue);
      expect(turn2.nextPhase, equals(InterviewPhase.strengthsAndProjects));

      final turn3 = scenario.evaluateCandidateTurn('Meine größte Stärke ist lösungsorientiertes Arbeiten im Team.');
      expect(turn3.goalAchieved, isTrue);
      expect(turn3.nextPhase, equals(InterviewPhase.availabilityAndNoticePeriod));

      final turn4 = scenario.evaluateCandidateTurn('Meine Kündigungsfrist beträgt einen Monat, ich kann ab März anfangen.');
      expect(turn4.goalAchieved, isTrue);
      expect(turn4.nextPhase, equals(InterviewPhase.candidateQuestions));

      final turn5 = scenario.evaluateCandidateTurn('Wie sieht die Einarbeitung im Team aus? Vielen Dank!');
      expect(turn5.goalAchieved, isTrue);
      expect(turn5.nextPhase, equals(InterviewPhase.completed));
    });

    test('Flags improper informal pronoun "du" with formal correction', () {
      final scenario = JobInterviewRoleplayScenario();
      final result = scenario.evaluateCandidateTurn('Guten Tag! Wie geht es du heute?');

      expect(result.feedbackHint, isNotNull);
      expect(result.feedbackHint!.originalText, contains('du'));
      expect(result.feedbackHint!.formalRecommendation, contains('Sie'));
    });
  });
}
