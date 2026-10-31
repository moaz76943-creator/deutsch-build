import 'package:test/test.dart';
import 'package:deutsch_build/src/core/gamification/exam_prep_study_plan_generator.dart';

void main() {
  group('ExamPrepStudyPlanGenerator Tests', () {
    const generator = ExamPrepStudyPlanGenerator();

    test('Generates 60-day plan for Goethe B1 with zero taper new vocabulary', () {
      final now = DateTime(2026, 1, 1);
      final examDate = DateTime(2026, 3, 2); // 60 days

      final plan = generator.generatePlan(
        exam: SupportedExam.goethe,
        level: 'B1',
        targetExamDate: examDate,
        currentDate: now,
        knownVocabCount: 1000,
        dailyAvailableMinutes: 45,
      );

      expect(plan.daysRemaining, equals(60));
      expect(plan.totalVocabRemaining, equals(1400));
      expect(plan.dailySchedule.length, equals(60));
      expect(plan.mockExamDays.isNotEmpty, isTrue);

      // Verify final taper days introduce no new words
      final lastDay = plan.dailySchedule.last;
      expect(lastDay.phase, equals(ExamPhase.finalSprintTaper));
      expect(lastDay.newVocabCount, equals(0));
    });

    test('Flags intensive pacing when remaining time is constrained', () {
      final now = DateTime(2026, 1, 1);
      final examDate = DateTime(2026, 1, 15); // 14 days for Goethe B1

      final plan = generator.generatePlan(
        exam: SupportedExam.goethe,
        level: 'B1',
        targetExamDate: examDate,
        currentDate: now,
        knownVocabCount: 200,
        dailyAvailableMinutes: 30,
      );

      expect(plan.requiresIntensivePacing, isTrue);
      expect(plan.feasibilityScore, lessThan(0.5));
    });

    test('Throws on past or zero day targets', () {
      final now = DateTime(2026, 1, 1);
      expect(
        () => generator.generatePlan(
          exam: SupportedExam.jlpt,
          level: 'N5',
          targetExamDate: now,
          currentDate: now,
          knownVocabCount: 0,
          dailyAvailableMinutes: 20,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
