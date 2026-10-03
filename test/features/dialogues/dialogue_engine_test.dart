import 'package:deutsch_bilarabi/features/dialogues/data/dialogue_repository.dart';
import 'package:deutsch_bilarabi/features/dialogues/domain/dialogue_engine.dart';
import 'package:deutsch_bilarabi/features/dialogues/domain/dialogue_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dialogue engine advances through the selected branch in order', () {
    final engine = DialogueEngine(DefaultDialogueScenarios.bakery);

    expect(engine.currentNode.id, 'bakery-start');
    expect(engine.transcript, hasLength(1));

    final step = engine.choose('bakery-two-rolls');

    expect(step.currentNode.id, 'bakery-more');
    expect(step.completed, isFalse);
    expect(engine.transcript, hasLength(3));
    expect(engine.transcript[1].speaker, DialogueSpeaker.learner);
    expect(engine.transcript[2].id, 'bakery-more-turn');
  });

  test('dialogue engine calculates normalized points across the chosen path', () {
    final perfect = DialogueEngine(DefaultDialogueScenarios.bakery)
      ..choose('bakery-two-rolls')
      ..choose('bakery-price');
    final partial = DialogueEngine(DefaultDialogueScenarios.bakery)
      ..choose('bakery-two-bread')
      ..choose('bakery-no');

    expect(perfect.isCompleted, isTrue);
    expect(perfect.result.points, 20);
    expect(perfect.result.maxPoints, 20);
    expect(perfect.result.scorePercent, 100);
    expect(partial.result.scorePercent, 50);
  });

  test('dialogue engine rejects choices outside the current node', () {
    final engine = DialogueEngine(DefaultDialogueScenarios.bakery);
    expect(() => engine.choose('bakery-price'), throwsA(isA<ArgumentError>()));
  });

  test('scenario validation rejects a broken branch target', () {
    expect(
      () => DialogueScenario(
        id: 'broken',
        titleGerman: 'Broken',
        titleArabic: 'معطوب',
        startNodeId: 'start',
        nodes: const <String, DialogueNode>{
          'start': DialogueNode(
            id: 'start',
            turn: DialogueTurn(
              id: 'turn',
              speaker: DialogueSpeaker.interlocutor,
              germanText: 'Hallo',
              arabicTranslation: 'مرحبًا',
            ),
            choices: <DialogueChoice>[
              DialogueChoice(
                id: 'missing-choice',
                germanText: 'Weiter',
                arabicTranslation: 'تابع',
                nextNodeId: 'missing',
                points: 10,
              ),
            ],
          ),
        },
      ),
      throwsA(isA<DialogueDefinitionException>()),
    );
  });

  test('repository exposes scenarios and records completion with best score', () {
    final repository = InMemoryDialogueRepository();
    expect(
      repository.scenarios.map((scenario) => scenario.titleGerman),
      containsAll(<String>[
        'Beim Bäcker',
        'Am Bahnhof',
        'Bei der Ausländerbehörde',
      ]),
    );

    final partial = DialogueEngine(DefaultDialogueScenarios.bakery)
      ..choose('bakery-two-bread')
      ..choose('bakery-no');
    final perfect = DialogueEngine(DefaultDialogueScenarios.bakery)
      ..choose('bakery-two-rolls')
      ..choose('bakery-price');
    repository.recordCompletion(
      partial.result,
      completedAt: DateTime.utc(2026, 10, 3, 10),
    );
    repository.recordCompletion(
      perfect.result,
      completedAt: DateTime.utc(2026, 10, 3, 11),
    );

    final progress = repository.progressFor('bakery');
    expect(progress.completedRuns, 2);
    expect(progress.lastScorePercent, 100);
    expect(progress.bestScorePercent, 100);
    expect(progress.lastCompletedAt, DateTime.utc(2026, 10, 3, 11));
  });
}
