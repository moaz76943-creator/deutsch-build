import 'package:deutsch_bilarabi/features/prepositions_arena/application/preposition_arena_notifier.dart';
import 'package:deutsch_bilarabi/features/prepositions_arena/data/local_prepositions_repository.dart';
import 'package:deutsch_bilarabi/features/prepositions_arena/domain/preposition_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = LocalPrepositionsRepository();

  test('article challenge validates inflected article from grammatical rules', () {
    final notifier = PrepositionArenaNotifier(repository: repository);
    notifier.start(type: PrepositionType.twoWay, limit: 20);

    while (notifier.state.currentChallenge?.kind !=
        PrepositionChallengeKind.articleChoice) {
      notifier.submit(notifier.state.currentChallenge!.options.first);
      notifier.next();
    }

    final challenge = notifier.state.currentChallenge!;
    final expected = notifier.expectedAnswerForCurrent();

    expect(expected, isNotEmpty);
    final result = notifier.submit(expected);

    expect(result.isCorrect, isTrue);
    expect(notifier.state.correctCount, greaterThan(0));
  });

  test('wrong answer affects accuracy and cannot be scored twice', () {
    final notifier = PrepositionArenaNotifier(repository: repository);
    notifier.start(type: PrepositionType.accusative, limit: 3);
    final challenge = notifier.state.currentChallenge!;
    final expected = notifier.expectedAnswerForCurrent();
    final wrong = challenge.options.firstWhere((option) => option != expected);

    final first = notifier.submit(wrong);

    expect(first.isCorrect, isFalse);
    expect(notifier.state.answeredCount, 1);
    expect(notifier.state.accuracy, 0);
    expect(
      () => notifier.submit(expected),
      throwsStateError,
    );
  });

  test('next advances until completed and reports final accuracy', () {
    final notifier = PrepositionArenaNotifier(repository: repository);
    notifier.start(type: PrepositionType.dative, limit: 2);

    while (!notifier.state.isCompleted) {
      if (!notifier.state.hasAnsweredCurrent) {
        notifier.submit(notifier.expectedAnswerForCurrent());
      }
      notifier.next();
    }

    expect(notifier.state.answeredCount, 2);
    expect(notifier.state.correctCount, 2);
    expect(notifier.state.accuracy, 1);
  });

  test('filter starts only matching challenge type', () {
    final notifier = PrepositionArenaNotifier(repository: repository);
    notifier.start(type: PrepositionType.twoWay, limit: 8);

    expect(
      notifier.state.challenges.every(
        (challenge) =>
            repository.byId(challenge.prepositionId)?.type ==
            PrepositionType.twoWay,
      ),
      isTrue,
    );
  });
}
