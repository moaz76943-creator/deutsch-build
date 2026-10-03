import 'package:deutsch_bilarabi/features/verb_prefixes/application/prefix_notifier.dart';
import 'package:deutsch_bilarabi/features/verb_prefixes/data/local_prefix_repository.dart';
import 'package:deutsch_bilarabi/features/verb_prefixes/domain/prefix_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalPrefixRepository', () {
    test('covers separable, inseparable, and ambiguous verb classes', () async {
      final repository = LocalPrefixRepository();

      final drills = await repository.getDrills();

      expect(
        drills.map((item) => item.verbClass).toSet(),
        containsAll(<VerbPrefixClass>{
          VerbPrefixClass.trennbar,
          VerbPrefixClass.untrennbar,
          VerbPrefixClass.doppeldeutig,
        }),
      );
    });

    test('separable travel verb splits in present and keeps ge in participle', () async {
      final repository = LocalPrefixRepository();
      final drill = (await repository.getDrills()).firstWhere(
        (item) => item.id == 'travel_ankommen',
      );

      expect(drill.infinitive, 'ankommen');
      expect(drill.prefix, 'an');
      expect(drill.isSeparableInContext, isTrue);
      expect(drill.correctSentence, 'Der Zug kommt um 18 Uhr in Berlin an.');
      expect(drill.partizipII, 'angekommen');
    });

    test('inseparable technology verb does not insert ge in participle', () async {
      final repository = LocalPrefixRepository();
      final drill = (await repository.getDrills()).firstWhere(
        (item) => item.id == 'technology_verarbeiten',
      );

      expect(drill.verbClass, VerbPrefixClass.untrennbar);
      expect(drill.isSeparableInContext, isFalse);
      expect(drill.partizipII, 'verarbeitet');
      expect(drill.partizipII, isNot(contains('ge')));
    });

    test('ambiguous übersetzen changes behavior with meaning', () async {
      final repository = LocalPrefixRepository();
      final drills = await repository.getDrills(
        verbClass: VerbPrefixClass.doppeldeutig,
      );

      final literature = drills.firstWhere(
        (item) => item.id == 'literature_uebersetzen_translate',
      );
      final travel = drills.firstWhere(
        (item) => item.id == 'travel_uebersetzen_cross',
      );

      expect(literature.infinitive, 'übersetzen');
      expect(literature.isSeparableInContext, isFalse);
      expect(literature.partizipII, 'übersetzt');
      expect(travel.infinitive, 'übersetzen');
      expect(travel.isSeparableInContext, isTrue);
      expect(travel.partizipII, 'übergesetzt');
    });

    test('checks normalized sentence answer and rejects wrong split', () async {
      final repository = LocalPrefixRepository();

      expect(
        await repository.checkAnswer(
          drillId: 'engineering_einbauen',
          answer: '  Die Ingenieurin baut den neuen Sensor ein. ',
        ),
        isTrue,
      );
      expect(
        await repository.checkAnswer(
          drillId: 'engineering_einbauen',
          answer: 'Die Ingenieurin einbaut den neuen Sensor.',
        ),
        isFalse,
      );
    });
  });

  group('PrefixNotifier', () {
    test('loads first drill and reveals feedback after checking answer', () async {
      final notifier = PrefixNotifier(LocalPrefixRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      final drill = notifier.currentDrill!;

      await notifier.checkAnswer(drill.correctSentence);

      expect(notifier.answerText, drill.correctSentence);
      expect(notifier.isCorrect, isTrue);
      expect(notifier.showExplanation, isTrue);
      expect(notifier.feedbackAr, isNotEmpty);
    });

    test('nextDrill clears answer state and advances', () async {
      final notifier = PrefixNotifier(LocalPrefixRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      final firstId = notifier.currentDrill!.id;
      await notifier.checkAnswer(notifier.currentDrill!.correctSentence);

      notifier.nextDrill();

      expect(notifier.currentIndex, 1);
      expect(notifier.currentDrill!.id, isNot(firstId));
      expect(notifier.answerText, isEmpty);
      expect(notifier.isCorrect, isNull);
      expect(notifier.showExplanation, isFalse);
    });

    test('switchVerbClass filters drills and resets progress', () async {
      final notifier = PrefixNotifier(LocalPrefixRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      await notifier.switchVerbClass(VerbPrefixClass.doppeldeutig);

      expect(notifier.activeClass, VerbPrefixClass.doppeldeutig);
      expect(notifier.currentIndex, 0);
      expect(
        notifier.drills.every(
          (item) => item.verbClass == VerbPrefixClass.doppeldeutig,
        ),
        isTrue,
      );
      expect(notifier.showExplanation, isFalse);
    });
  });
}
