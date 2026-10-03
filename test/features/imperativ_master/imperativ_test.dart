import 'package:deutsch_bilarabi/features/imperativ_master/application/imperativ_notifier.dart';
import 'package:deutsch_bilarabi/features/imperativ_master/data/local_imperativ_repository.dart';
import 'package:deutsch_bilarabi/features/imperativ_master/domain/imperativ_models.dart';
import 'package:deutsch_bilarabi/features/imperativ_master/presentation/imperativ_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = LocalImperativRepository();

  test('du form removes pronoun and -st while preserving e to ie', () {
    final item = repository.byId('lesen_du')!;

    expect(item.referenceForm, 'du liest');
    expect(item.correctForm, 'Lies!');
    expect(item.vowelChange, ImperativVowelChange.eToIe);
    expect(repository.isCorrect(item, 'Lies!'), isTrue);
    expect(repository.isCorrect(item, 'Lies'), isTrue);
    expect(repository.isCorrect(item, 'Liest du!'), isFalse);
  });

  test('du fahren drops the umlaut and the -st ending', () {
    final item = repository.byId('fahren_du')!;

    expect(item.referenceForm, 'du fährst');
    expect(item.correctForm, 'Fahr!');
    expect(item.vowelChange, ImperativVowelChange.umlautDropped);
    expect(repository.isCorrect(item, 'Fahr!'), isTrue);
    expect(repository.isCorrect(item, 'Fährst!'), isFalse);
  });

  test('du umlaut-drop verbs also accept the optional long e form', () {
    for (final pair in <(String, String)>[
      ('fahren_du', 'Fahre!'),
      ('laufen_du', 'Laufe!'),
      ('schlafen_du', 'Schlafe!'),
      ('tragen_du', 'Trage!'),
    ]) {
      final item = repository.byId(pair.$1)!;
      expect(
        repository.isCorrect(item, pair.$2),
        isTrue,
        reason: '${pair.$1} should accept ${pair.$2}',
      );
    }
  });

  test('verbs ending in t or d keep the imperative e for du', () {
    final arbeiten = repository.byId('arbeiten_du')!;
    final warten = repository.byId('warten_du')!;
    final reden = repository.byId('reden_du')!;

    expect(arbeiten.correctForm, 'Arbeite!');
    expect(warten.correctForm, 'Warte!');
    expect(reden.correctForm, 'Rede!');
    expect(repository.isCorrect(arbeiten, 'Arbeite!'), isTrue);
  });

  test('sein uses its exceptional imperative forms', () {
    final du = repository.byId('sein_du')!;
    final ihr = repository.byId('sein_ihr')!;
    final formal = repository.byId('sein_sie')!;
    final wir = repository.byId('sein_wir')!;

    expect(du.correctForm, 'Sei!');
    expect(ihr.correctForm, 'Seid!');
    expect(formal.correctForm, 'Seien Sie!');
    expect(wir.correctForm, 'Seien wir!');
    expect(du.vowelChange, ImperativVowelChange.irregularSein);
    expect(formal.vowelChange, ImperativVowelChange.irregularSein);
  });

  test('ihr omits ihr while formal Sie keeps the pronoun', () {
    final ihr = repository.byId('fahren_ihr')!;
    final formal = repository.byId('fahren_sie')!;

    expect(repository.isCorrect(ihr, 'Fahrt!'), isTrue);
    expect(repository.isCorrect(ihr, 'Fahrt ihr!'), isFalse);
    expect(repository.isCorrect(formal, 'Fahren Sie!'), isTrue);
    expect(repository.isCorrect(formal, 'Fahren!'), isFalse);
  });

  test('wir imperative keeps wir after the infinitive', () {
    final item = repository.byId('sprechen_wir')!;

    expect(item.correctForm, 'Sprechen wir!');
    expect(repository.isCorrect(item, 'Sprechen wir!'), isTrue);
    expect(repository.isCorrect(item, 'Sprechen!'), isFalse);
  });

  test('notifier validates answers and advances the drill', () {
    final notifier = ImperativNotifier(repository);
    final firstId = notifier.state.current.id;

    notifier.checkImperativForm(notifier.state.current.correctForm);

    expect(notifier.state.checked, isTrue);
    expect(notifier.state.correct, isTrue);
    expect(notifier.state.feedbackAr, isNotEmpty);

    notifier.nextDrill();

    expect(notifier.state.checked, isFalse);
    expect(notifier.state.input, isEmpty);
    expect(notifier.state.current.id, isNot(firstId));
  });

  testWidgets('screen hides the expected command until submission', (tester) async {
    final notifier = ImperativNotifier(repository);
    final expected = notifier.state.current.correctForm;

    await tester.pumpWidget(
      MaterialApp(home: ImperativScreen(notifier: notifier)),
    );

    expect(find.textContaining(expected), findsNothing);

    notifier.checkImperativForm('wrong');
    await tester.pump();

    expect(find.textContaining(expected), findsWidgets);
  });

  test('notifier filters the bank by target and resets state', () {
    final notifier = ImperativNotifier(repository);
    notifier.checkImperativForm('wrong');

    notifier.filterByTarget(ImperativTarget.sieForm);

    expect(notifier.state.filter, ImperativTarget.sieForm);
    expect(notifier.state.checked, isFalse);
    expect(notifier.state.input, isEmpty);
    expect(
      notifier.state.drills.every(
        (item) => item.target == ImperativTarget.sieForm,
      ),
      isTrue,
    );
  });
}
