import 'package:deutsch_bilarabi/features/infinitiv_konstruktionen/application/infinitiv_notifier.dart';
import 'package:deutsch_bilarabi/features/infinitiv_konstruktionen/data/local_infinitiv_repository.dart';
import 'package:deutsch_bilarabi/features/infinitiv_konstruktionen/domain/infinitiv_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalInfinitivRepository repository;

  setUp(() {
    repository = LocalInfinitivRepository();
  });

  test('bank covers all four infinitive construction types', () async {
    final challenges = await repository.getChallenges();

    expect(
      challenges.map((item) => item.type).toSet(),
      containsAll(<InfinitivClauseType>{
        InfinitivClauseType.infinitivMitZu,
        InfinitivClauseType.umZu,
        InfinitivClauseType.ohneZu,
        InfinitivClauseType.anstattZu,
      }),
    );
  });

  test('validates plain Infinitiv mit zu and normalizes punctuation', () async {
    final challenges = await repository.getChallenges(
      type: InfinitivClauseType.infinitivMitZu,
    );
    final challenge = challenges.first;

    expect(
      await repository.validateAnswer(
        challenge.id,
        challenge.correctConstruction,
      ),
      isTrue,
    );
    expect(
      await repository.validateAnswer(
        challenge.id,
        '${challenge.correctConstruction}.',
      ),
      isTrue,
    );
    expect(
      await repository.validateAnswer(
        challenge.id,
        challenge.mainClause,
      ),
      isFalse,
    );
  });

  test('um zu challenges encode same-subject purpose semantics', () async {
    final challenges = await repository.getChallenges(
      type: InfinitivClauseType.umZu,
    );

    expect(challenges, isNotEmpty);
    expect(
      challenges.every((item) => item.requiresSameSubject),
      isTrue,
    );
    expect(
      challenges.every((item) => item.marker == 'um ... zu'),
      isTrue,
    );
  });

  test('ohne zu and anstatt zu remain distinguishable', () async {
    final ohne = (await repository.getChallenges(
      type: InfinitivClauseType.ohneZu,
    )).first;
    final anstatt = (await repository.getChallenges(
      type: InfinitivClauseType.anstattZu,
    )).first;

    expect(ohne.marker, 'ohne ... zu');
    expect(anstatt.marker, 'anstatt ... zu');
    expect(
      await repository.validateAnswer(
        ohne.id,
        anstatt.correctConstruction,
      ),
      isFalse,
    );
  });

  test('notifier filters, scores, explains and advances', () async {
    final notifier = InfinitivNotifier(repository: repository);

    await notifier.filterByType(InfinitivClauseType.umZu);

    final challenge = notifier.currentChallenge;
    expect(challenge, isNotNull);
    expect(challenge!.type, InfinitivClauseType.umZu);

    notifier.selectAnswer(challenge.correctConstruction);
    await notifier.checkAnswer();

    expect(notifier.isCorrect, isTrue);
    expect(notifier.showExplanation, isTrue);
    expect(notifier.explanationAr, challenge.ruleExplanationAr);

    await notifier.nextChallenge();

    expect(notifier.showExplanation, isFalse);
    expect(notifier.isCorrect, isNull);
    expect(notifier.selectedAnswer, isNull);
  });

  test('notifier rejects scoring without an active selection', () async {
    final notifier = InfinitivNotifier(repository: repository);
    await notifier.nextChallenge();

    expect(notifier.currentChallenge, isNotNull);
    expect(
      notifier.checkAnswer,
      throwsStateError,
    );
  });
}
