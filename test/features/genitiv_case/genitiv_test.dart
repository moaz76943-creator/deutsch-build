import 'package:deutsch_bilarabi/features/genitiv_case/application/genitiv_notifier.dart';
import 'package:deutsch_bilarabi/features/genitiv_case/data/local_genitiv_repository.dart';
import 'package:deutsch_bilarabi/features/genitiv_case/domain/genitiv_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalGenitivRepository repository;

  setUp(() {
    repository = LocalGenitivRepository();
  });

  test('assigns des to masculine and neuter, der to feminine and plural', () async {
    final drills = await repository.getChallenges(
      type: GenitivDrillType.possessionArticle,
    );

    final masculine = drills.firstWhere(
      (item) => item.gender == GenitivGender.maskulin,
    );
    final neuter = drills.firstWhere(
      (item) => item.gender == GenitivGender.neutrum,
    );
    final feminine = drills.firstWhere(
      (item) => item.gender == GenitivGender.feminin,
    );
    final plural = drills.firstWhere(
      (item) => item.gender == GenitivGender.plural,
    );

    expect(masculine.correctArticle, 'des');
    expect(neuter.correctArticle, 'des');
    expect(feminine.correctArticle, 'der');
    expect(plural.correctArticle, 'der');
  });

  test('masculine and neuter nouns carry the expected genitive suffix', () async {
    final drills = await repository.getChallenges(
      type: GenitivDrillType.possessionArticle,
    );

    final haus = drills.firstWhere((item) => item.targetNoun == 'Haus');
    final auto = drills.firstWhere((item) => item.targetNoun == 'Auto');
    final tisch = drills.firstWhere((item) => item.targetNoun == 'Tisch');

    expect(haus.correctNounSuffix, 'es');
    expect(haus.inflectedNoun, 'Hauses');
    expect(auto.correctNounSuffix, 's');
    expect(auto.inflectedNoun, 'Autos');
    expect(tisch.correctNounSuffix, 'es');
    expect(tisch.inflectedNoun, 'Tisches');
  });

  test('covers the four requested genitive prepositions', () async {
    final drills = await repository.getChallenges(
      type: GenitivDrillType.genitivPrepositions,
    );

    expect(
      drills.map((item) => item.genitivPreposition).toSet(),
      containsAll(<String>{'wegen', 'während', 'trotz', 'anstatt'}),
    );

    for (final item in drills) {
      expect(
        await repository.validateAnswer(
          item.id,
          chosenArticle: item.correctArticle,
          chosenNounSuffix: item.correctNounSuffix,
          chosenPreposition: item.genitivPreposition,
        ),
        isTrue,
      );
    }
  });

  test('rejects wrong article, suffix, or genitive preposition', () async {
    final drills = await repository.getChallenges(
      type: GenitivDrillType.genitivPrepositions,
    );
    final wegen = drills.firstWhere(
      (item) => item.genitivPreposition == 'wegen',
    );

    expect(
      await repository.validateAnswer(
        wegen.id,
        chosenArticle: 'der',
        chosenNounSuffix: wegen.correctNounSuffix,
        chosenPreposition: 'wegen',
      ),
      isFalse,
    );
    expect(
      await repository.validateAnswer(
        wegen.id,
        chosenArticle: wegen.correctArticle,
        chosenNounSuffix: '',
        chosenPreposition: 'wegen',
      ),
      isFalse,
    );
    expect(
      await repository.validateAnswer(
        wegen.id,
        chosenArticle: wegen.correctArticle,
        chosenNounSuffix: wegen.correctNounSuffix,
        chosenPreposition: 'trotz',
      ),
      isFalse,
    );
  });

  test('notifier filters, scores, and exposes immediate Arabic explanation', () async {
    final notifier = GenitivNotifier(repository: repository);

    await notifier.filterByType(GenitivDrillType.genitivPrepositions);

    expect(
      notifier.currentChallenge?.type,
      GenitivDrillType.genitivPrepositions,
    );

    final challenge = notifier.currentChallenge!;
    await notifier.checkGenitivAnswer(
      challenge.correctArticle,
      challenge.correctNounSuffix,
      chosenPreposition: challenge.genitivPreposition,
    );

    expect(notifier.isCorrect, isTrue);
    expect(notifier.selectedArticle, challenge.correctArticle);
    expect(notifier.selectedNounSuffix, challenge.correctNounSuffix);
    expect(notifier.showExplanation, isTrue);
    expect(notifier.explanationAr, challenge.explanationAr);

    await notifier.nextChallenge();

    expect(notifier.showExplanation, isFalse);
    expect(notifier.isCorrect, isNull);
  });
}
