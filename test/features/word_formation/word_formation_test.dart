import 'package:deutsch_bilarabi/features/word_formation/application/word_formation_notifier.dart';
import 'package:deutsch_bilarabi/features/word_formation/data/local_word_formation_repository.dart';
import 'package:deutsch_bilarabi/features/word_formation/domain/word_formation_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalWordFormationRepository', () {
    test('builds frequent noun and adjective derivations correctly', () async {
      final repository = LocalWordFormationRepository();
      final drills = await repository.getDrills();

      WordDerivationItem byId(String id) =>
          drills.firstWhere((item) => item.id == id);

      expect(byId('noun_freiheit').rootWord, 'frei');
      expect(byId('noun_freiheit').suffix, '-heit');
      expect(byId('noun_freiheit').derivedWord, 'Freiheit');
      expect(byId('noun_freiheit').article, 'die');

      expect(byId('noun_hoffnung').derivedWord, 'Hoffnung');
      expect(byId('noun_puenktlichkeit').derivedWord, 'Pünktlichkeit');
      expect(byId('adj_hoffnungslos').derivedWord, 'hoffnungslos');
      expect(byId('adj_machbar').derivedWord, 'machbar');
    });

    test('assigns die automatically to feminine noun-forming suffixes', () async {
      final repository = LocalWordFormationRepository();
      final drills = await repository.getDrills(
        category: SuffixCategory.nounSuffix,
      );

      final feminineSuffixes = <String>{'-ung', '-heit', '-keit', '-schaft'};
      final targeted = drills
          .where((item) => feminineSuffixes.contains(item.suffix))
          .toList(growable: false);

      expect(targeted, isNotEmpty);
      expect(targeted.every((item) => item.article == 'die'), isTrue);
    });

    test('validates exact derived word and article', () async {
      final repository = LocalWordFormationRepository();

      expect(
        await repository.checkDerivedWord('noun_freiheit', ' Freiheit '),
        isTrue,
      );
      expect(
        await repository.checkDerivedWord('noun_freiheit', 'Freiung'),
        isFalse,
      );
      expect(
        await repository.checkArticle('noun_freiheit', 'die'),
        isTrue,
      );
      expect(
        await repository.checkArticle('noun_freiheit', 'das'),
        isFalse,
      );
      expect(
        await repository.checkArticle('adj_machbar', ''),
        isTrue,
      );
    });

    test('filters drills by requested suffix category', () async {
      final repository = LocalWordFormationRepository();
      final adjectiveDrills = await repository.getDrills(
        category: SuffixCategory.adjectiveSuffix,
      );

      expect(adjectiveDrills, isNotEmpty);
      expect(
        adjectiveDrills.every(
          (item) => item.category == SuffixCategory.adjectiveSuffix,
        ),
        isTrue,
      );
    });
  });

  group('WordFormationNotifier', () {
    test('combineSuffix forms the word and exposes semantic feedback', () async {
      final notifier = WordFormationNotifier(LocalWordFormationRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      final current = notifier.currentDrill!;

      await notifier.combineSuffix(current.suffix);

      expect(notifier.selectedSuffix, current.suffix);
      expect(notifier.formedWord, current.derivedWord);
      expect(notifier.generatedArticle, current.article);
      expect(notifier.isCorrect, isTrue);
      expect(notifier.showExplanation, isTrue);
    });

    test('a wrong suffix is rejected without revealing a correct result', () async {
      final notifier = WordFormationNotifier(LocalWordFormationRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      final current = notifier.currentDrill!;
      final wrong = notifier.availableSuffixes.firstWhere(
        (suffix) => suffix != current.suffix,
      );

      await notifier.combineSuffix(wrong);

      expect(notifier.selectedSuffix, wrong);
      expect(notifier.formedWord, isNot(current.derivedWord));
      expect(notifier.isCorrect, isFalse);
      expect(notifier.showExplanation, isTrue);
    });

    test('nextDrill clears the current attempt state', () async {
      final notifier = WordFormationNotifier(LocalWordFormationRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      final firstId = notifier.currentDrill!.id;
      await notifier.combineSuffix(notifier.currentDrill!.suffix);

      notifier.nextDrill();

      expect(notifier.currentDrill, isNotNull);
      expect(notifier.currentDrill!.id, isNot(firstId));
      expect(notifier.selectedSuffix, isNull);
      expect(notifier.formedWord, isNull);
      expect(notifier.generatedArticle, isNull);
      expect(notifier.isCorrect, isNull);
      expect(notifier.showExplanation, isFalse);
    });

    test('filterByCategory resets to drills in that category', () async {
      final notifier = WordFormationNotifier(LocalWordFormationRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      await notifier.filterByCategory(SuffixCategory.verbPrefixDerivation);

      expect(
        notifier.activeCategory,
        SuffixCategory.verbPrefixDerivation,
      );
      expect(notifier.currentIndex, 0);
      expect(notifier.drills, isNotEmpty);
      expect(
        notifier.drills.every(
          (item) =>
              item.category == SuffixCategory.verbPrefixDerivation,
        ),
        isTrue,
      );
    });
  });
}
