import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';
import 'package:deutsch_bilarabi/features/flashcards/flashcard_session.dart';
import 'package:deutsch_bilarabi/features/flashcards/flashcards_plug.dart';

class FakeReviewWriter implements ReviewCommandPort {
  final List<ReviewCommand> received = <ReviewCommand>[];
  Completer<void>? pending;
  bool fail = false;

  @override
  Future<void> submit(ReviewCommand command) async {
    received.add(command);
    if (pending != null) await pending!.future;
    if (fail) throw StateError('injected DB failure');
  }
}

LexicalEntry entry(String id, {String source = 'de', String target = 'ar'}) =>
    LexicalEntry(
      id: id, domainId: 'food', sourceLocale: source,
      targetLocale: target, targetTerm: id == 'a' ? 'Haus' : 'بيت',
      sourceMeaning: id == 'a' ? 'بيت' : 'house',
      targetExample: '', sourceExampleTranslation: '', partOfSpeech: '',
    );

FlashcardReviewItem item(String id, {String source = 'de', String target = 'ar'}) =>
    FlashcardReviewItem(
      entry: entry(id, source: source, target: target),
      reviewEventId: 'event-$id-$source-$target',
      semanticVersion: 'v2',
      pairEpoch: 5,
    );

Widget session(List<FlashcardReviewItem> items, FakeReviewWriter writer) =>
    MaterialApp(home: Scaffold(
      body: FlashcardSessionWidget(items: items, reviewPort: writer),
    ));

void main() {
  testWidgets('commits once before next card and keeps versioned pair', (tester) async {
    final writer = FakeReviewWriter();
    await tester.pumpWidget(session(<FlashcardReviewItem>[
      item('a'), item('b', source: 'ar', target: 'de'),
    ], writer));
    await tester.tap(find.byKey(const Key('flashcard-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Good'));
    await tester.pumpAndSettle();
    expect(writer.received.length, 1);
    expect(writer.received.single.sourceLanguageId, 'de');
    expect(writer.received.single.targetLanguageId, 'ar');
    expect(writer.received.single.semanticVersion, 'v2');
    expect(writer.received.single.rating, ReviewRating.good);
    expect(find.text('بيت'), findsWidgets);
  });

  testWidgets('rapid grading is single-flight until persistence succeeds',
      (tester) async {
    final writer = FakeReviewWriter()..pending = Completer<void>();
    await tester.pumpWidget(session(<FlashcardReviewItem>[item('a')], writer));
    await tester.tap(find.byKey(const Key('flashcard-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Good'));
    await tester.pump();
    expect(writer.received.length, 1);
    final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Good'));
    expect(button.onPressed, isNull);
    writer.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Session Complete!'), findsOneWidget);
  });

  testWidgets('storage failure retains same review event for safe retry',
      (tester) async {
    final writer = FakeReviewWriter()..fail = true;
    await tester.pumpWidget(session(<FlashcardReviewItem>[item('a')], writer));
    await tester.tap(find.byKey(const Key('flashcard-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hard'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('review-error')), findsOneWidget);
    expect(find.text('Session Complete!'), findsNothing);
    expect(tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Easy')).onPressed, isNull);
    writer.fail = false;
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hard'));
    await tester.pumpAndSettle();
    expect(writer.received.length, 2);
    expect(writer.received[0].reviewId, writer.received[1].reviewId);
    expect(find.text('Session Complete!'), findsOneWidget);
  });

  testWidgets('malformed content cannot be graded', (tester) async {
    final writer = FakeReviewWriter();
    const bad = FlashcardReviewItem(
      entry: LexicalEntry(
        id: 'bad', domainId: '', sourceLocale: 'de', targetLocale: 'de',
        targetTerm: 'bad', sourceMeaning: '', targetExample: '',
        sourceExampleTranslation: '', partOfSpeech: '',
      ),
      reviewEventId: '', semanticVersion: '', pairEpoch: -1,
    );
    await tester.pumpWidget(session(<FlashcardReviewItem>[bad], writer));
    await tester.tap(find.byKey(const Key('flashcard-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Easy'));
    await tester.pumpAndSettle();
    expect(writer.received, isEmpty);
    expect(find.byKey(const Key('review-error')), findsOneWidget);
  });

  testWidgets('disposed widget ignores completed pending result',
      (tester) async {
    final writer = FakeReviewWriter()..pending = Completer<void>();
    await tester.pumpWidget(session(<FlashcardReviewItem>[item('a')], writer));
    await tester.tap(find.byKey(const Key('flashcard-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Easy'));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: Text('exited')));
    writer.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.text('exited'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('legacy entry refuses in-memory journal fallback',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (context) =>
          const FlashcardsPlug().buildEntry(context))),
    ));
    expect(find.textContaining('التخزين المحلي الآمن'), findsOneWidget);
    await expectLater(FlashcardsPlug.dispatchReview(
      cardId: 'x', rating: 2), throwsStateError);
  });
}
