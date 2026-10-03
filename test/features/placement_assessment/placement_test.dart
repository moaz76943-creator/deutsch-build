import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/placement_assessment/application/placement_notifier.dart';
import 'package:deutsch_bilarabi/features/placement_assessment/data/local_placement_repository.dart';
import 'package:deutsch_bilarabi/features/placement_assessment/domain/placement_models.dart';

void main() {
  group('adaptive difficulty path', () {
    test('correct A2 answer promotes the next target to B1', () async {
      final notifier = PlacementNotifier(
        const LocalPlacementRepository(),
        maxQuestions: 6,
      );
      addTearDown(notifier.dispose);

      await notifier.restartAssessment();
      final first = notifier.currentQuestion!;
      expect(first.targetLevel, CefrLevel.a2);

      await notifier.submitAnswer(first.correctAnswerIndex);

      expect(notifier.currentQuestion, isNotNull);
      expect(notifier.currentQuestion!.targetLevel, CefrLevel.b1);
      expect(
        notifier.currentQuestion!.difficultyWeight,
        greaterThan(first.difficultyWeight),
      );
    });

    test('wrong A2 answer lowers the next target to A1', () async {
      final notifier = PlacementNotifier(
        const LocalPlacementRepository(),
        maxQuestions: 6,
      );
      addTearDown(notifier.dispose);

      await notifier.restartAssessment();
      final first = notifier.currentQuestion!;
      final wrongIndex = first.correctAnswerIndex == 0 ? 1 : 0;

      await notifier.submitAnswer(wrongIndex);

      expect(notifier.currentQuestion, isNotNull);
      expect(notifier.currentQuestion!.targetLevel, CefrLevel.a1);
      expect(
        notifier.currentQuestion!.difficultyWeight,
        lessThan(first.difficultyWeight),
      );
    });
  });

  group('standardized placement score', () {
    test('known B1/B2 evidence produces deterministic B1 score', () {
      const repository = LocalPlacementRepository();
      final evidence = <PlacementAnswerRecord>[
        PlacementAnswerRecord(
          questionId: 'b1_grammar_verb',
          level: CefrLevel.b1,
          skill: AssessmentSkillCategory.grammar,
          difficultyWeight: 1.20,
          isCorrect: true,
        ),
        PlacementAnswerRecord(
          questionId: 'b2_vocab_register',
          level: CefrLevel.b2,
          skill: AssessmentSkillCategory.vocabulary,
          difficultyWeight: 1.60,
          isCorrect: false,
        ),
      ];

      final result = repository.calculateStandardizedResult(evidence);

      expect(result.standardizedScore, closeTo(75, 0.0001));
      expect(result.finalLevel, CefrLevel.b1);
      expect(
        result.skillAccuracy[AssessmentSkillCategory.grammar],
        1,
      );
      expect(
        result.skillAccuracy[AssessmentSkillCategory.vocabulary],
        0,
      );
    });

    test('balanced correct B2 evidence resolves to B2', () {
      const repository = LocalPlacementRepository();
      final evidence = <PlacementAnswerRecord>[
        PlacementAnswerRecord(
          questionId: 'b2_g',
          level: CefrLevel.b2,
          skill: AssessmentSkillCategory.grammar,
          difficultyWeight: 1.50,
          isCorrect: true,
        ),
        PlacementAnswerRecord(
          questionId: 'b2_v',
          level: CefrLevel.b2,
          skill: AssessmentSkillCategory.vocabulary,
          difficultyWeight: 1.55,
          isCorrect: true,
        ),
        PlacementAnswerRecord(
          questionId: 'b2_r',
          level: CefrLevel.b2,
          skill: AssessmentSkillCategory.readingComprehension,
          difficultyWeight: 1.60,
          isCorrect: true,
        ),
        PlacementAnswerRecord(
          questionId: 'b2_p',
          level: CefrLevel.b2,
          skill: AssessmentSkillCategory.practicalContext,
          difficultyWeight: 1.65,
          isCorrect: true,
        ),
      ];

      final result = repository.calculateStandardizedResult(evidence);

      expect(result.finalLevel, CefrLevel.b2);
      expect(result.standardizedScore, 100);
      expect(result.skillAccuracy.values.every((value) => value == 1), isTrue);
    });
  });

  group('PlacementNotifier state', () {
    test('completes, calculates result, then restart clears state', () async {
      final notifier = PlacementNotifier(
        const LocalPlacementRepository(),
        maxQuestions: 4,
      );
      addTearDown(notifier.dispose);

      await notifier.restartAssessment();
      while (!notifier.isCompleted) {
        final question = notifier.currentQuestion!;
        await notifier.submitAnswer(question.correctAnswerIndex);
      }

      expect(notifier.result, isNotNull);
      expect(notifier.progress, 1);
      expect(notifier.answers, hasLength(4));

      await notifier.restartAssessment();

      expect(notifier.result, isNull);
      expect(notifier.answers, isEmpty);
      expect(notifier.progress, 0);
      expect(notifier.currentQuestion, isNotNull);
      expect(notifier.currentQuestion!.targetLevel, CefrLevel.a2);
    });

    test('rejects an option index outside the current question', () async {
      final notifier = PlacementNotifier(
        const LocalPlacementRepository(),
      );
      addTearDown(notifier.dispose);
      await notifier.restartAssessment();

      expect(
        () => notifier.submitAnswer(99),
        throwsRangeError,
      );
    });
  });
}
