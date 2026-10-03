import 'package:deutsch_bilarabi/features/conjunctions_arena/application/conjunctions_notifier.dart';
import 'package:deutsch_bilarabi/features/conjunctions_arena/data/local_conjunctions_repository.dart';
import 'package:deutsch_bilarabi/features/conjunctions_arena/domain/conjunctions_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalConjunctionsRepository repository;

  setUp(() {
    repository = LocalConjunctionsRepository();
  });

  test('ADUSO bank validates connector and Position 0 effect', () async {
    final drills = await repository.getDrills(
      category: ConjunctionCategory.coordinatingADUSO,
    );

    expect(
      drills.map((item) => item.targetConnector).toSet(),
      containsAll(<String>{'und', 'aber', 'denn', 'oder', 'sondern'}),
    );
    expect(
      drills.every(
        (item) =>
            item.correctVerbPosition == ConjunctionDrillItem.positionZero,
      ),
      isTrue,
    );

    final denn = drills.firstWhere(
      (item) => item.targetConnector == 'denn',
    );
    expect(
      await repository.validateAnswer(
        denn.id,
        'denn',
        ConjunctionDrillItem.positionZero,
      ),
      isTrue,
    );
    expect(
      await repository.validateAnswer(
        denn.id,
        'weil',
        ConjunctionDrillItem.positionZero,
      ),
      isFalse,
    );
  });

  test('subordinating connectors require verb-final position', () async {
    final drills = await repository.getDrills(
      category: ConjunctionCategory.subordinatingNebensatz,
    );

    expect(
      drills.map((item) => item.targetConnector).toSet(),
      containsAll(<String>{'weil', 'dass', 'wenn', 'obwohl'}),
    );
    expect(
      drills.every(
        (item) =>
            item.correctVerbPosition == ConjunctionDrillItem.positionEnd,
      ),
      isTrue,
    );

    final weil = drills.firstWhere(
      (item) => item.targetConnector == 'weil',
    );
    expect(
      await repository.validateAnswer(
        weil.id,
        'weil',
        ConjunctionDrillItem.positionEnd,
      ),
      isTrue,
    );
    expect(
      await repository.validateAnswer(
        weil.id,
        'weil',
        ConjunctionDrillItem.positionZero,
      ),
      isFalse,
    );
  });

  test('adverbial connectors use Position 1 inversion effect', () async {
    final drills = await repository.getDrills(
      category: ConjunctionCategory.adverbialInversion,
    );

    expect(
      drills.map((item) => item.targetConnector).toSet(),
      containsAll(<String>{'deshalb', 'trotzdem'}),
    );
    expect(
      drills.every(
        (item) =>
            item.correctVerbPosition == ConjunctionDrillItem.positionOne,
      ),
      isTrue,
    );
  });

  test('notifier calculates correct session result and exposes verdict', () async {
    final notifier = ConjunctionsNotifier(
      repository: repository,
      category: ConjunctionCategory.coordinatingADUSO,
    );

    await notifier.nextDrill();
    final first = notifier.currentDrill!;
    await notifier.checkAnswer(
      first.targetConnector,
      first.correctVerbPosition,
    );

    expect(notifier.isCorrect, isTrue);
    expect(notifier.verbPositionVerdict, VerbPositionVerdict.correct);
    expect(notifier.showExplanation, isTrue);
    expect(notifier.answeredCount, 1);
    expect(notifier.correctCount, 1);
    expect(notifier.accuracy, 1.0);

    await notifier.nextDrill();
    final second = notifier.currentDrill!;
    await notifier.checkAnswer(
      second.targetConnector,
      ConjunctionDrillItem.positionEnd,
    );

    expect(notifier.isCorrect, isFalse);
    expect(notifier.verbPositionVerdict, VerbPositionVerdict.incorrect);
    expect(notifier.answeredCount, 2);
    expect(notifier.correctCount, 1);
    expect(notifier.accuracy, 0.5);
  });
}
