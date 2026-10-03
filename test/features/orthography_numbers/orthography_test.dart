import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/orthography_numbers/application/orthography_notifier.dart';
import 'package:deutsch_bilarabi/features/orthography_numbers/data/local_orthography_repository.dart';
import 'package:deutsch_bilarabi/features/orthography_numbers/domain/orthography_models.dart';
import 'package:deutsch_bilarabi/features/orthography_numbers/presentation/orthography_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = LocalOrthographyRepository();

  test('comma engine validates subordinate and relative clauses', () {
    final weil = repository.byId('comma_weil')!;
    final relative = repository.byId('comma_relative')!;

    expect(weil.topic, OrthographyTopic.comma);
    expect(repository.isCommaPlacementCorrect(weil, <int>{3}), isTrue);
    expect(repository.isCommaPlacementCorrect(weil, <int>{}), isFalse);

    expect(relative.correctCommaGaps, <int>{1, 4});
    expect(
      repository.isCommaPlacementCorrect(relative, <int>{1, 4}),
      isTrue,
    );
    expect(
      repository.isCommaPlacementCorrect(relative, <int>{1}),
      isFalse,
    );
  });

  test('spelling engine distinguishes dass from das', () {
    final item = repository.byId('spelling_dass')!;

    expect(repository.isTextAnswerCorrect(item, 'dass'), isTrue);
    expect(repository.isTextAnswerCorrect(item, 'das'), isFalse);
  });

  test('capitalization keeps German nouns uppercase', () {
    final item = repository.byId('capitalization_noun')!;

    expect(repository.isTextAnswerCorrect(item, 'Morgen'), isTrue);
    expect(repository.isTextAnswerCorrect(item, 'morgen'), isFalse);
  });

  test('formats German dates in long and numeric notation', () {
    final date = DateTime.utc(2026, 10, 3);

    expect(repository.formatDateLong(date), '3. Oktober 2026');
    expect(repository.formatDateNumeric(date), '03.10.2026');
  });

  test('formats German numbers with decimal comma and thousands point', () {
    expect(repository.formatNumber('12345.67'), '12.345,67');
    expect(repository.formatNumber('-1000000.5'), '-1.000.000,5');
    expect(repository.formatNumber('12'), '12');
  });

  test('notifier manages interactive comma placement and advances', () {
    final notifier = OrthographyNotifier(repository);
    notifier.filterByTopic(OrthographyTopic.comma);
    expect(notifier.state.current.id, 'comma_weil');

    notifier.toggleCommaAfter(3);
    notifier.checkCommaPlacement();

    expect(notifier.state.checked, isTrue);
    expect(notifier.state.correct, isTrue);
    expect(notifier.state.feedbackAr, isNotEmpty);

    final first = notifier.state.current.id;
    notifier.nextExercise();

    expect(notifier.state.checked, isFalse);
    expect(notifier.state.selectedCommaGaps, isEmpty);
    expect(notifier.state.current.id, isNot(first));
  });

  test('notifier validates text answers for spelling items', () {
    final notifier = OrthographyNotifier(repository);
    notifier.filterByTopic(OrthographyTopic.spelling);

    notifier.checkTextAnswer('dass');

    expect(notifier.state.checked, isTrue);
    expect(notifier.state.correct, isTrue);
  });

  testWidgets('screen uses glass cards and explicit BiDi directions', (tester) async {
    final notifier = OrthographyNotifier(repository);

    await tester.pumpWidget(
      MaterialApp(home: OrthographyScreen(notifier: notifier)),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(Directionality), findsWidgets);
  });
}
