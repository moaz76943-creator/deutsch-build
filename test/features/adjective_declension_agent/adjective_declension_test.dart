import 'package:deutsch_bilarabi/features/adjective_declension_agent/application/adjective_declension_notifier.dart';
import 'package:deutsch_bilarabi/features/adjective_declension_agent/data/local_adjective_declension_repository.dart';
import 'package:deutsch_bilarabi/features/adjective_declension_agent/domain/adjective_declension_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalAdjectiveDeclensionRepository', () {
    test('weak dative exercises always use -en after a definite article', () async {
      final repository = LocalAdjectiveDeclensionRepository();

      final exercises = await repository.getExercises(
        type: DeclensionType.weak,
      );
      final dativeExercises = exercises
          .where((item) => item.grammaticalCase == GrammaticalCase.dativ)
          .toList(growable: false);

      expect(dativeExercises, isNotEmpty);
      expect(
        dativeExercises.every((item) => item.correctEnding == '-en'),
        isTrue,
      );
    });

    test('covers representative weak, mixed, and strong endings', () async {
      final repository = LocalAdjectiveDeclensionRepository();
      final exercises = await repository.getExercises();

      AdjectiveExerciseItem byId(String id) =>
          exercises.firstWhere((item) => item.id == id);

      expect(byId('weak_nom_fem').correctEnding, '-e');
      expect(byId('mixed_nom_masc').correctEnding, '-er');
      expect(byId('mixed_akk_neut').correctEnding, '-es');
      expect(byId('strong_dat_masc').correctEnding, '-em');
      expect(byId('strong_gen_fem').correctEnding, '-er');
    });

    test('checks normalized endings by exercise id', () async {
      final repository = LocalAdjectiveDeclensionRepository();

      expect(
        await repository.checkAnswer('mixed_nom_masc', '-er'),
        isTrue,
      );
      expect(
        await repository.checkAnswer('mixed_nom_masc', ' er '),
        isTrue,
      );
      expect(
        await repository.checkAnswer('mixed_nom_masc', '-en'),
        isFalse,
      );
      expect(
        await repository.checkAnswer('missing', '-er'),
        isFalse,
      );
    });
  });

  group('AdjectiveDeclensionNotifier', () {
    test('selects an ending, reveals feedback, and moves to next exercise', () async {
      final notifier = AdjectiveDeclensionNotifier(
        LocalAdjectiveDeclensionRepository(),
      );
      addTearDown(notifier.dispose);

      await notifier.load();
      final first = notifier.currentExercise!;

      await notifier.selectEnding(first.correctEnding);

      expect(notifier.currentIndex, 0);
      expect(notifier.selectedEnding, first.correctEnding);
      expect(notifier.isCorrect, isTrue);
      expect(notifier.showExplanation, isTrue);

      notifier.nextExercise();

      expect(notifier.currentIndex, 1);
      expect(notifier.selectedEnding, isNull);
      expect(notifier.isCorrect, isNull);
      expect(notifier.showExplanation, isFalse);
    });

    test('reset returns to the first exercise and clears answer state', () async {
      final notifier = AdjectiveDeclensionNotifier(
        LocalAdjectiveDeclensionRepository(),
      );
      addTearDown(notifier.dispose);

      await notifier.load(type: DeclensionType.mixed);
      final firstId = notifier.currentExercise!.id;
      await notifier.selectEnding(notifier.currentExercise!.correctEnding);
      notifier.nextExercise();

      await notifier.reset();

      expect(notifier.currentIndex, 0);
      expect(notifier.currentExercise!.id, firstId);
      expect(notifier.selectedEnding, isNull);
      expect(notifier.isCorrect, isNull);
      expect(notifier.showExplanation, isFalse);
      expect(
        notifier.exercises.every(
          (item) => item.declensionType == DeclensionType.mixed,
        ),
        isTrue,
      );
    });
  });
}
