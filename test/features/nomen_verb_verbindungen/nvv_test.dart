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

  test('B2 bank filters wholesome professional contexts', () async {
    for (final context in NvvContext.values) {
      final items = await repository.getChallenges(context: context);

      expect(items, isNotEmpty);
      expect(items.every((item) => item.context == context), isTrue);
      expect(items.every((item) => item.level == 'B2'), isTrue);
    }
  });

  test('replacement validation works from simple verb to NVV and back',
      () async {
    expect(
      await repository.validateReplacement(
        'entscheidung_treffen',
        ReplacementDirection.simpleToNvv,
        'eine Entscheidung treffen',
      ),
      isTrue,
    );
    expect(
      await repository.validateReplacement(
        'entscheidung_treffen',
        ReplacementDirection.simpleToNvv,
        'entscheiden',
      ),
      isFalse,
    );
    expect(
      await repository.validateReplacement(
        'entscheidung_treffen',
        ReplacementDirection.nvvToSimple,
        'entscheiden',
      ),
      isTrue,
    );
    expect(
      await repository.validateReplacement(
        'entscheidung_treffen',
        ReplacementDirection.nvvToSimple,
        'eine Entscheidung treffen',
      ),
      isFalse,
    );
  });

  test('healthcare and feedback content stays constructive and practical',
      () async {
    final healthcare = await repository.getChallenges(
      context: NvvContext.healthcare,
    );
    final feedback = await repository.getChallenges(
      context: NvvContext.constructiveFeedback,
    );

    expect(
      healthcare.map((item) => item.id),
      contains('diagnose_stellen'),
    );
    expect(
      healthcare.map((item) => item.id),
      contains('untersuchung_durchfuehren'),
    );
    expect(
      feedback.map((item) => item.id),
      contains('kritik_ueben'),
    );
    expect(
      feedback.map((item) => item.id),
      contains('feedback_geben'),
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

    notifier.dispose();
  });

  test('notifier replacement mode updates answer state in both directions',
      () async {
    final notifier = NvvNotifier(repository: repository);

    await notifier.filterByContext(NvvContext.office);
    final current = notifier.currentChallenge!;

    notifier.setReplacementDirection(ReplacementDirection.simpleToNvv);
    await notifier.checkReplacement(current.nvvPhrase);

    expect(notifier.replacementAnswer, current.nvvPhrase);
    expect(notifier.replacementCorrect, isTrue);
    expect(notifier.showReplacementExplanation, isTrue);

    notifier.setReplacementDirection(ReplacementDirection.nvvToSimple);
    expect(notifier.replacementAnswer, isNull);
    expect(notifier.showReplacementExplanation, isFalse);

    await notifier.checkReplacement(current.simpleEquivalent);

    expect(notifier.replacementCorrect, isTrue);
    expect(notifier.showReplacementExplanation, isTrue);

    notifier.dispose();
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

    notifier.dispose();
  });

  test('notifier filters by context and resets active challenge state',
      () async {
    final notifier = NvvNotifier(repository: repository);

    await notifier.nextChallenge();
    await notifier.checkPair(notifier.currentChallenge!.correctVerb);
    await notifier.filterByContext(NvvContext.academics);

    expect(notifier.activeContext, NvvContext.academics);
    expect(notifier.currentChallenge!.context, NvvContext.academics);
    expect(notifier.selectedVerb, isNull);
    expect(notifier.isCorrect, isNull);
    expect(notifier.replacementAnswer, isNull);

    notifier.dispose();
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
