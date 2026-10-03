import 'package:deutsch_bilarabi/features/dialogues/data/dialogue_repository.dart';
import 'package:deutsch_bilarabi/features/dialogues/domain/dialogue_engine.dart';
import 'package:deutsch_bilarabi/features/dialogues/domain/dialogue_models.dart';
import 'package:deutsch_bilarabi/features/dialogues/presentation/dialogue_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeDialogueAudioPort implements DialogueAudioPort {
  int calls = 0;
  DialogueTurn? lastTurn;

  @override
  Future<bool> speak(DialogueTurn turn) async {
    calls += 1;
    lastTurn = turn;
    return true;
  }
}

void main() {
  testWidgets('tap toggles Arabic translation and listen uses domain audio port', (
    tester,
  ) async {
    final audio = _FakeDialogueAudioPort();
    final repository = InMemoryDialogueRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DialogueChatView(
            scenario: DefaultDialogueScenarios.bakery,
            repository: repository,
            audioPort: audio,
          ),
        ),
      ),
    );

    expect(find.text('صباح الخير. ماذا ترغب؟'), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey<String>('dialogue-turn-bakery-start-turn')),
    );
    await tester.pump();
    expect(find.text('صباح الخير. ماذا ترغب؟'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('dialogue-listen-bakery-start-turn')),
    );
    await tester.pump();
    expect(audio.calls, 1);
    expect(audio.lastTurn?.id, 'bakery-start-turn');
  });

  testWidgets('reply cards advance and persist completion', (tester) async {
    final repository = InMemoryDialogueRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DialogueChatView(
            scenario: DefaultDialogueScenarios.bakery,
            repository: repository,
            audioPort: const SilentDialogueAudioPort(),
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('dialogue-choice-bakery-two-rolls')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('dialogue-choice-bakery-price')),
    );
    await tester.pump();

    expect(find.textContaining('النتيجة 100%'), findsOneWidget);
    expect(repository.progressFor('bakery').completedRuns, 1);
    expect(repository.progressFor('bakery').bestScorePercent, 100);
  });
}
