import 'package:deutsch_bilarabi/core/localization/german_article_style.dart';
import 'package:deutsch_bilarabi/features/komposita_builder/application/komposita_notifier.dart';
import 'package:deutsch_bilarabi/features/komposita_builder/data/local_komposita_repository.dart';
import 'package:deutsch_bilarabi/features/komposita_builder/domain/komposita_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalKompositaRepository repository;

  setUp(() {
    repository = LocalKompositaRepository();
  });

  test('final article follows the final compound part', () async {
    final challenges = await repository.getChallenges();
    final apfelbaum = challenges.firstWhere(
      (item) => item.compoundWord == 'Apfelbaum',
    );
    final haustuer = challenges.firstWhere(
      (item) => item.compoundWord == 'Haustür',
    );
    final woerterbuch = challenges.firstWhere(
      (item) => item.compoundWord == 'Wörterbuch',
    );

    expect(apfelbaum.parts.last.originalArticle, GermanArticle.der);
    expect(apfelbaum.finalArticle, GermanArticle.der);

    expect(haustuer.parts.last.originalArticle, GermanArticle.die);
    expect(haustuer.finalArticle, GermanArticle.die);

    expect(woerterbuch.parts.last.originalArticle, GermanArticle.das);
    expect(woerterbuch.finalArticle, GermanArticle.das);
  });

  test('validates ordered composition, linking element and final article', () async {
    final challenges = await repository.getChallenges();
    final arbeitszimmer = challenges.firstWhere(
      (item) => item.compoundWord == 'Arbeitszimmer',
    );

    expect(
      await repository.validateComposition(
        arbeitszimmer.id,
        orderedParts: const <String>['Arbeit', 'Zimmer'],
        linkingElement: LinkingElement.s,
        finalArticle: GermanArticle.das,
      ),
      isTrue,
    );
    expect(
      await repository.validateComposition(
        arbeitszimmer.id,
        orderedParts: const <String>['Zimmer', 'Arbeit'],
        linkingElement: LinkingElement.s,
        finalArticle: GermanArticle.das,
      ),
      isFalse,
    );
    expect(
      await repository.validateComposition(
        arbeitszimmer.id,
        orderedParts: const <String>['Arbeit', 'Zimmer'],
        linkingElement: LinkingElement.none,
        finalArticle: GermanArticle.das,
      ),
      isFalse,
    );
  });

  test('bank covers requested common linking patterns across A1-B1', () async {
    final challenges = await repository.getChallenges();
    final links = challenges.map((item) => item.linkingElement).toSet();
    final levels = challenges.map((item) => item.level).toSet();

    expect(
      links,
      containsAll(<LinkingElement>{
        LinkingElement.none,
        LinkingElement.s,
        LinkingElement.es,
        LinkingElement.n,
        LinkingElement.en,
        LinkingElement.er,
      }),
    );
    expect(levels, containsAll(<String>{'A1', 'A2', 'B1'}));
  });

  test('notifier manages assembly verdict, explanation and reset', () async {
    final notifier = KompositaNotifier(repository: repository);
    await notifier.nextChallenge();

    final first = notifier.currentChallenge!;
    for (final part in first.parts) {
      notifier.choosePart(part.word);
    }
    notifier.selectLinkingElement(first.linkingElement);
    notifier.selectArticle(first.finalArticle);

    await notifier.checkComposition(
      notifier.assembledParts,
      notifier.selectedLinkingElement!,
      notifier.selectedArticle!,
    );

    expect(notifier.isCorrect, isTrue);
    expect(notifier.explanationAr, first.derivationExplanationAr);
    expect(notifier.showExplanation, isTrue);

    notifier.reset();

    expect(notifier.currentChallenge, isNull);
    expect(notifier.assembledParts, isEmpty);
    expect(notifier.selectedArticle, isNull);
    expect(notifier.selectedLinkingElement, isNull);
    expect(notifier.isCorrect, isNull);
    expect(notifier.showExplanation, isFalse);
  });

  test('deconstruct and assemble modes can be switched without scoring', () async {
    final notifier = KompositaNotifier(repository: repository);
    await notifier.nextChallenge();

    notifier.setMode(KompositaMode.deconstruct);
    expect(notifier.mode, KompositaMode.deconstruct);
    expect(notifier.isCorrect, isNull);

    notifier.setMode(KompositaMode.assemble);
    expect(notifier.mode, KompositaMode.assemble);
    expect(notifier.isCorrect, isNull);
  });
}
