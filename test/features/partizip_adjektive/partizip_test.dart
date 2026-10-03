import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/partizip_adjektive/application/partizip_notifier.dart';
import 'package:deutsch_bilarabi/features/partizip_adjektive/data/local_partizip_repository.dart';
import 'package:deutsch_bilarabi/features/partizip_adjektive/domain/partizip_models.dart';
import 'package:deutsch_bilarabi/features/partizip_adjektive/presentation/partizip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = LocalPartizipRepository();

  test('Partizip I keeps an active or simultaneous meaning', () {
    final item = repository.byId('p1_machine_running')!;

    expect(item.kind, PartizipKind.partizipI);
    expect(item.participle, 'laufend');
    expect(item.correctAttribute, 'die mit hoher Drehzahl laufende Maschine');
    expect(repository.isAnswerCorrect(item, item.correctAttribute), isTrue);
  });

  test('Partizip II describes completed or passive-result meaning', () {
    final item = repository.byId('p2_temperature_measured')!;

    expect(item.kind, PartizipKind.partizipII);
    expect(item.participle, 'gemessen');
    expect(item.correctAttribute, 'die im Labor gemessene Temperatur');
    expect(repository.isAnswerCorrect(item, item.correctAttribute), isTrue);
  });

  test('extended attributes preserve German pre-nominal order', () {
    final item = repository.byId('p1_researchers_extended')!;

    expect(item.scope, PartizipAttributeScope.extended);
    expect(
      item.attributeTokens,
      <String>[
        'die',
        'seit',
        'Jahren',
        'an',
        'diesem',
        'Problem',
        'forschenden',
        'Wissenschaftler',
      ],
    );
    expect(
      repository.isTokenOrderCorrect(item, item.attributeTokens),
      isTrue,
    );
    expect(
      repository.isTokenOrderCorrect(
        item,
        <String>[
          'die',
          'forschenden',
          'seit',
          'Jahren',
          'an',
          'diesem',
          'Problem',
          'Wissenschaftler',
        ],
      ),
      isFalse,
    );
  });

  test('reading example distinguishes Partizip II adjective ending', () {
    final item = repository.byId('p2_book_read')!;

    expect(item.correctAttribute, 'das häufig gelesene Fachbuch');
    expect(repository.isAnswerCorrect(item, 'das häufig gelesene Fachbuch'), isTrue);
    expect(repository.isAnswerCorrect(item, 'das häufig gelesen Fachbuch'), isFalse);
  });

  test('repository filters by participle kind', () {
    final first = repository.forKind(PartizipKind.partizipI);
    final second = repository.forKind(PartizipKind.partizipII);

    expect(first, isNotEmpty);
    expect(second, isNotEmpty);
    expect(first.every((item) => item.kind == PartizipKind.partizipI), isTrue);
    expect(second.every((item) => item.kind == PartizipKind.partizipII), isTrue);
  });

  test('notifier checks answers, reveals explanation, and advances', () {
    final notifier = PartizipNotifier(repository);
    final first = notifier.state.current;

    notifier.checkAttribute(first.correctAttribute);

    expect(notifier.state.checked, isTrue);
    expect(notifier.state.correct, isTrue);
    expect(notifier.state.feedbackAr, isNotEmpty);

    notifier.nextExercise();

    expect(notifier.state.checked, isFalse);
    expect(notifier.state.input, isEmpty);
    expect(notifier.state.current.id, isNot(first.id));
  });

  test('notifier filters by Partizip II and resets state', () {
    final notifier = PartizipNotifier(repository);
    notifier.checkAttribute('wrong');

    notifier.filterByKind(PartizipKind.partizipII);

    expect(notifier.state.filter, PartizipKind.partizipII);
    expect(notifier.state.checked, isFalse);
    expect(
      notifier.state.exercises.every(
        (item) => item.kind == PartizipKind.partizipII,
      ),
      isTrue,
    );
  });

  testWidgets('screen uses glass cards and robust bidirectional text', (tester) async {
    final notifier = PartizipNotifier(repository);

    await tester.pumpWidget(
      MaterialApp(home: PartizipScreen(notifier: notifier)),
    );

    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(Directionality), findsWidgets);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
