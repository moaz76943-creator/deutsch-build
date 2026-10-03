import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/placement_agent/application/placement_agent_notifier.dart';
import 'package:deutsch_bilarabi/features/placement_agent/data/local_placement_agent_repository.dart';
import 'package:deutsch_bilarabi/features/placement_agent/domain/placement_agent_models.dart';

Future<PlacementAgentNotifier> _started({int maxQuestions = 6}) async {
  final notifier = PlacementAgentNotifier(
    LocalPlacementAgentRepository(),
    maxQuestions: maxQuestions,
  );
  await notifier.resetAssessment();
  return notifier;
}

void main() {
  test('correct answer escalates the next question difficulty', () async {
    final notifier = await _started(maxQuestions: 4);
    addTearDown(notifier.dispose);

    final first = notifier.currentQuestion!;
    expect(first.difficulty, 3);

    await notifier.submitAnswer(first.correctAnswerIndex);

    expect(notifier.currentQuestion, isNotNull);
    expect(notifier.currentQuestion!.difficulty, greaterThan(first.difficulty));
  });

  test('wrong answer lowers the next question difficulty', () async {
    final notifier = await _started(maxQuestions: 4);
    addTearDown(notifier.dispose);

    final first = notifier.currentQuestion!;
    expect(first.difficulty, 3);
    final wrongIndex = first.correctAnswerIndex == 0 ? 1 : 0;

    await notifier.submitAnswer(wrongIndex);

    expect(notifier.currentQuestion, isNotNull);
    expect(notifier.currentQuestion!.difficulty, lessThan(first.difficulty));
  });

  test('consistently correct adaptive evidence resolves to A2.2', () async {
    final repository = LocalPlacementAgentRepository();
    final notifier = PlacementAgentNotifier(repository, maxQuestions: 6);
    addTearDown(notifier.dispose);
    await notifier.resetAssessment();

    while (!notifier.isCompleted) {
      final question = notifier.currentQuestion!;
      await notifier.submitAnswer(question.correctAnswerIndex);
    }

    expect(notifier.result, isNotNull);
    expect(notifier.result!.inferredLevel, LanguageCefrSubLevel.a2_2);
    expect(notifier.result!.accuracy, 1);
    expect(notifier.result!.masteredSkills, isNotEmpty);
    expect(await repository.getLatestResult(), same(notifier.result));
  });

  test('consistently incorrect adaptive evidence resolves to A1.1', () async {
    final notifier = await _started(maxQuestions: 6);
    addTearDown(notifier.dispose);

    while (!notifier.isCompleted) {
      final question = notifier.currentQuestion!;
      final wrongIndex = question.correctAnswerIndex == 0 ? 1 : 0;
      await notifier.submitAnswer(wrongIndex);
    }

    expect(notifier.result, isNotNull);
    expect(notifier.result!.inferredLevel, LanguageCefrSubLevel.a1_1);
    expect(notifier.result!.accuracy, 0);
    expect(notifier.result!.skillsToStrengthen, isNotEmpty);
    expect(notifier.progress, 1);
  });
}
