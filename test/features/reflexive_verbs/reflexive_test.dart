import 'package:deutsch_bilarabi/features/reflexive_verbs/application/reflexive_notifier.dart';
import 'package:deutsch_bilarabi/features/reflexive_verbs/data/local_reflexive_repository.dart';
import 'package:deutsch_bilarabi/features/reflexive_verbs/domain/reflexive_models.dart';
import 'package:deutsch_bilarabi/features/reflexive_verbs/presentation/reflexive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = LocalReflexiveRepository();

  test('ich distinguishes Akkusativ mich from Dativ mir', () {
    expect(
      repository.expectedPronoun(
        subjectPronoun: 'ich',
        reflexCase: ReflexiveCase.akkusativ,
      ),
      'mich',
    );
    expect(
      repository.expectedPronoun(
        subjectPronoun: 'ich',
        reflexCase: ReflexiveCase.dativ,
      ),
      'mir',
    );
  });

  test('du distinguishes Akkusativ dich from Dativ dir', () {
    expect(
      repository.expectedPronoun(
        subjectPronoun: 'du',
        reflexCase: ReflexiveCase.akkusativ,
      ),
      'dich',
    );
    expect(
      repository.expectedPronoun(
        subjectPronoun: 'du',
        reflexCase: ReflexiveCase.dativ,
      ),
      'dir',
    );
  });

  test('er uses sich in both cases while the grammatical case still differs', () {
    expect(
      repository.expectedPronoun(
        subjectPronoun: 'er',
        reflexCase: ReflexiveCase.akkusativ,
      ),
      'sich',
    );
    expect(
      repository.expectedPronoun(
        subjectPronoun: 'er',
        reflexCase: ReflexiveCase.dativ,
      ),
      'sich',
    );

    final accusative = repository.byId('rasieren_er_akk')!;
    final dative = repository.byId('jacke_anziehen_er_dat')!;
    expect(accusative.reflexiveCase, ReflexiveCase.akkusativ);
    expect(dative.reflexiveCase, ReflexiveCase.dativ);
    expect(dative.additionalObject, 'die Jacke');
  });

  test('additional Akkusativ object switches ich reflexive pronoun to Dativ', () {
    final wholeBody = repository.byId('waschen_ich_akk')!;
    final hands = repository.byId('haende_waschen_ich_dat')!;

    expect(repository.isCorrectPronoun(wholeBody, 'mich'), isTrue);
    expect(repository.isCorrectCase(
      wholeBody,
      ReflexiveCase.akkusativ,
    ), isTrue);

    expect(hands.additionalObject, 'die Hände');
    expect(repository.isCorrectPronoun(hands, 'mir'), isTrue);
    expect(repository.isCorrectPronoun(hands, 'mich'), isFalse);
    expect(repository.isCorrectCase(hands, ReflexiveCase.dativ), isTrue);
  });

  test('reciprocal drills retain their governed grammatical case', () {
    final treffen = repository.byId('treffen_wir_reciprocal_akk')!;
    final helfen = repository.byId('helfen_wir_reciprocal_dat')!;

    expect(treffen.reflexiveType, ReflexiveType.reciprocal);
    expect(treffen.reflexiveCase, ReflexiveCase.akkusativ);
    expect(helfen.reflexiveType, ReflexiveType.reciprocal);
    expect(helfen.reflexiveCase, ReflexiveCase.dativ);
    expect(treffen.reflexivePronoun, 'uns');
    expect(helfen.reflexivePronoun, 'uns');
  });

  test('all bank entries match the repository pronoun table', () {
    for (final item in repository.allDrills) {
      expect(
        repository.expectedPronoun(
          subjectPronoun: item.subjectPronoun,
          reflexCase: item.reflexiveCase,
        ),
        item.reflexivePronoun,
        reason: item.id,
      );
    }
  });

  test('notifier validates and resets when moving to the next drill', () {
    final notifier = ReflexiveNotifier(repository);
    final first = notifier.state.current;

    notifier.checkReflexivePronoun(first.reflexivePronoun);

    expect(notifier.state.checked, isTrue);
    expect(notifier.state.correct, isTrue);
    expect(notifier.state.selectedPronoun, first.reflexivePronoun);
    expect(notifier.state.feedbackAr, isNotEmpty);

    notifier.nextDrill();

    expect(notifier.state.checked, isFalse);
    expect(notifier.state.selectedPronoun, isNull);
    expect(notifier.state.feedbackAr, isEmpty);
    expect(notifier.state.current.id, isNot(first.id));
  });

  test('notifier filters by Dativ and resets interaction state', () {
    final notifier = ReflexiveNotifier(repository);
    notifier.checkReflexivePronoun('wrong');

    notifier.filterByCase(ReflexiveCase.dativ);

    expect(notifier.state.filter, ReflexiveCase.dativ);
    expect(notifier.state.checked, isFalse);
    expect(notifier.state.selectedPronoun, isNull);
    expect(
      notifier.state.drills.every(
        (item) => item.reflexiveCase == ReflexiveCase.dativ,
      ),
      isTrue,
    );
  });

  testWidgets('presentation uses SafeArea and a scroll view', (tester) async {
    final notifier = ReflexiveNotifier(repository);

    await tester.pumpWidget(
      MaterialApp(home: ReflexiveScreen(notifier: notifier)),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
