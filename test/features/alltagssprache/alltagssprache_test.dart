import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/alltagssprache/application/alltagssprache_notifier.dart';
import 'package:deutsch_bilarabi/features/alltagssprache/data/local_alltagssprache_repository.dart';
import 'package:deutsch_bilarabi/features/alltagssprache/domain/alltagssprache_models.dart';
import 'package:deutsch_bilarabi/features/alltagssprache/presentation/alltagssprache_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = LocalAlltagsspracheRepository();

  test('content covers every requested everyday etiquette topic', () {
    for (final topic in AlltagTopic.values) {
      expect(
        repository.byTopic(topic),
        isNotEmpty,
        reason: 'Missing content for ${topic.name}',
      );
    }

    final phrases = repository.all().map((item) => item.phraseDe).toSet();
    expect(phrases, contains('Sonntagsruhe'));
    expect(phrases, contains('Ruhezeiten'));
    expect(phrases, contains('Schönen Feierabend!'));
    expect(phrases, contains('Mahlzeit!'));
    expect(phrases, contains('Passt schon.'));
  });

  test('content stays clean and focused on respectful daily life', () {
    final corpus = repository
        .all()
        .expand(
          (item) => <String>[
            item.phraseDe,
            item.contextDe,
            item.etiquetteAr,
            item.promptAr,
            ...item.optionsDe,
          ],
        )
        .join(' ')
        .toLowerCase();

    for (final blocked in <String>[
      'alkohol',
      'nachtclub',
      'nachtleben',
      'casino',
      'drogen',
    ]) {
      expect(corpus.contains(blocked), isFalse);
    }
  });

  test('choice engine accepts only the culturally appropriate response', () {
    final item = repository.byId('feierabend_wish')!;

    expect(repository.isChoiceCorrect(item, item.correctIndex), isTrue);
    expect(
      repository.isChoiceCorrect(
        item,
        (item.correctIndex + 1) % item.optionsDe.length,
      ),
      isFalse,
    );
  });

  test('notifier filters topics, checks answers and advances cleanly', () {
    final notifier = AlltagsspracheNotifier(repository);

    notifier.filterByTopic(AlltagTopic.politePhrases);
    expect(notifier.current.topic, AlltagTopic.politePhrases);

    notifier.selectChoice(notifier.current.correctIndex);
    notifier.checkSelection();

    expect(notifier.checked, isTrue);
    expect(notifier.isCorrect, isTrue);
    expect(notifier.feedbackAr, isNotEmpty);

    final first = notifier.current.id;
    notifier.nextScenario();

    expect(notifier.checked, isFalse);
    expect(notifier.selectedIndex, isNull);
    expect(notifier.current.id, isNot(first));

    notifier.dispose();
  });

  test('notifier rejects invalid choice indexes', () {
    final notifier = AlltagsspracheNotifier(repository);

    expect(() => notifier.selectChoice(-1), throwsRangeError);
    expect(
      () => notifier.selectChoice(notifier.current.optionsDe.length),
      throwsRangeError,
    );

    notifier.dispose();
  });

  testWidgets('screen uses glass cards, safe scrolling and explicit BiDi',
      (tester) async {
    final notifier = AlltagsspracheNotifier(repository)
      ..filterByTopic(AlltagTopic.politePhrases);

    await tester.pumpWidget(
      MaterialApp(
        home: AlltagsspracheScreen(notifier: notifier),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(Directionality), findsWidgets);
    expect(find.text('Schönen Feierabend!'), findsOneWidget);

    notifier.dispose();
  });
}
