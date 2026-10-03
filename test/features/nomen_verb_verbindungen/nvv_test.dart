import 'package:deutsch_bilarabi/features/nomen_verb_verbindungen/application/nvv_notifier.dart';
import 'package:deutsch_bilarabi/features/nomen_verb_verbindungen/data/local_nvv_repository.dart';
import 'package:deutsch_bilarabi/features/nomen_verb_verbindungen/domain/nvv_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalNvvRepository repository;

  setUp(() {
    repository = LocalNvvRepository();
  });

  test('repository matches canonical noun-verb pairs', () async {
    final challenges = await repository.getChallenges();

    final decision = challenges.firstWhere(
      (item) => item.id == 'entscheidung_treffen',
    );
    final measures = challenges.firstWhere(
      (item) => item.id == 'massnahmen_ergreifen',
    );
    final farewell = challenges.firstWhere(
      (item) => item.id == 'abschied_nehmen',
    );

    expect(
      await repository.validateAnswer(decision.id, 'treffen'),
      isTrue,
    );
    expect(
      await repository.validateAnswer(measures.id, 'ergreifen'),
      isTrue,
    );
    expect(
      await repository.validateAnswer(farewell.id, 'nehmen'),
      isTrue,
    );
  });

  test('repository rejects common but incorrect verb substitutions', () async {
    expect(
      await repository.validateAnswer('entscheidung_treffen', 'machen'),
      isFalse,
    );
    expect(
      await repository.validateAnswer('massnahmen_ergreifen', 'machen'),
      isFalse,
    );
    expect(
      await repository.validateAnswer('abschied_nehmen', 'machen'),
      isFalse,
    );
    expect(
      await repository.validateAnswer('missing_item', 'nehmen'),
      isFalse,
    );
  });

  test('search finds collocations through noun, verb and simple equivalent',
      () async {
    final byNoun = await repository.search('Rücksicht');
    final byVerb = await repository.search('ergreifen');
    final byEquivalent = await repository.search('beantragen');

    expect(
      byNoun.map((item) => item.id),
      contains('ruecksicht_nehmen'),
    );
    expect(
      byVerb.map((item) => item.id),
      contains('massnahmen_ergreifen'),
    );
    expect(
      byEquivalent.map((item) => item.id),
      contains('antrag_stellen'),
    );
  });

  test('notifier updates selection, correctness and explanation state',
      () async {
    final notifier = NvvNotifier(repository: repository);

    await notifier.nextChallenge();
    final current = notifier.currentChallenge!;

    expect(notifier.displayedOptions, contains(current.correctVerb));
    expect(notifier.showExplanation, isFalse);

    await notifier.checkPair(current.correctVerb);

    expect(notifier.selectedVerb, current.correctVerb);
    expect(notifier.isCorrect, isTrue);
    expect(notifier.showExplanation, isTrue);

    await notifier.nextChallenge();

    expect(notifier.currentChallenge, isNotNull);
    expect(notifier.selectedVerb, isNull);
    expect(notifier.isCorrect, isNull);
    expect(notifier.showExplanation, isFalse);
  });

  test('notifier exposes incorrect answer and filters by register', () async {
    final notifier = NvvNotifier(repository: repository);

    await notifier.filterByRegister(NvvRegister.academicOfficial);

    expect(notifier.activeRegister, NvvRegister.academicOfficial);
    expect(
      notifier.currentChallenge!.register,
      NvvRegister.academicOfficial,
    );
    expect(
      notifier.displayedOptions,
      contains(notifier.currentChallenge!.correctVerb),
    );

    const wrongVerb = 'machen';
    expect(notifier.currentChallenge!.correctVerb, isNot(wrongVerb));

    await notifier.checkPair(wrongVerb);

    expect(notifier.selectedVerb, wrongVerb);
    expect(notifier.isCorrect, isFalse);
    expect(notifier.showExplanation, isTrue);
  });

  test('grammar hints preserve governed preposition and case', () async {
    final challenges = await repository.getChallenges();
    final consideration = challenges.firstWhere(
      (item) => item.id == 'ruecksicht_nehmen',
    );

    expect(consideration.preposition, 'auf');
    expect(consideration.caseHint, 'Akkusativ');
    expect(consideration.grammarHint, 'auf + Akkusativ');
  });
}
