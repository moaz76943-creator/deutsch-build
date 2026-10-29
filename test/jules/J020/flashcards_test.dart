import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/features/flashcards/flashcards_plug.dart';
import 'package:deutsch_bilarabi/core/srs_scheduler.dart';

void main() {
  group('Flashcards Feature Tests - J020', () {
    final entry1 = LexicalEntry(
      id: 'e1',
      domainId: 'd1',
      sourceLocale: 'de',
      targetLocale: 'ar',
      targetTerm: 'Haus',
      sourceMeaning: 'بيت',
      targetExample: 'Das ist ein Haus',
      sourceExampleTranslation: 'هذا بيت',
      partOfSpeech: 'Noun',
    );

    final entry2 = LexicalEntry(
      id: 'e2',
      domainId: 'd1',
      sourceLocale: 'de',
      targetLocale: 'ar',
      targetTerm: 'Auto',
      sourceMeaning: 'سيارة',
      targetExample: '', // Missing optional fields
      sourceExampleTranslation: '',
      partOfSpeech: '',
    );

    testWidgets('Card grading and SRS bridge invocation, pair switching', (WidgetTester tester) async {
      final plug = FlashcardsPlug(entries: [entry1]);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: plug.buildEntry(MockBuildContext())),
      ));
      await tester.pumpAndSettle();

      // Tap to flip
      expect(find.text('Haus'), findsOneWidget);
      await tester.tap(find.text('Haus'));
      await tester.pumpAndSettle(); // Animation complete

      expect(find.text('بيت'), findsOneWidget);

      // Tap Good
      final initialHistoryLength = UnifiedSrsScheduler.instance.history.length;
      await tester.tap(find.widgetWithText(ElevatedButton, 'Good'));
      await tester.pumpAndSettle();

      final updatedHistory = UnifiedSrsScheduler.instance.history;
      expect(updatedHistory.length, initialHistoryLength + 1);

      final lastEvent = updatedHistory.last;
      expect(lastEvent.learnerContentKey, 'e1');
      expect(lastEvent.rating, 2); // SrsRating.good
      expect(lastEvent.languagePairKey, 'de_ar'); // Pair identity preserved
    });

    testWidgets('Prevention of duplicate grading from rapid taps', (WidgetTester tester) async {
       final plug = FlashcardsPlug(entries: [entry1]);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: plug.buildEntry(MockBuildContext())),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Haus'));
      await tester.pumpAndSettle();

      final initialHistoryLength = UnifiedSrsScheduler.instance.history.length;

      // Tap multiple times very quickly
      await tester.tap(find.widgetWithText(ElevatedButton, 'Good'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Good'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Good'));

      await tester.pumpAndSettle();

      // Ensure only 1 event recorded
      expect(UnifiedSrsScheduler.instance.history.length, initialHistoryLength + 1);
    });

    testWidgets('Missing optional fields do not crash the view', (WidgetTester tester) async {
       final plug = FlashcardsPlug(entries: [entry2]);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: plug.buildEntry(MockBuildContext())),
      ));
      await tester.pumpAndSettle();

      // Front side
      expect(find.text('Auto'), findsOneWidget);
      // Tap to flip
      await tester.tap(find.text('Auto'));
      await tester.pumpAndSettle();

      // Back side - no example, only meaning
      expect(find.text('سيارة'), findsOneWidget);
      expect(find.text('Das ist ein Haus'), findsNothing); // Ensure no crashes
    });

    testWidgets('Safe state disposal on interrupted review', (WidgetTester tester) async {
       final plug = FlashcardsPlug(entries: [entry1]);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: plug.buildEntry(MockBuildContext())),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Haus'));
      await tester.pump(const Duration(milliseconds: 100)); // Animation mid-way

      // Interrupt view
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Interrupted'))));
      await tester.pumpAndSettle();

      expect(find.text('Interrupted'), findsOneWidget);
      // Test passes if no exception thrown during dispose
    });

    testWidgets('Correct/wrong/skipped logic', (WidgetTester tester) async {
       final plug = FlashcardsPlug(entries: [entry1, entry2]);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: plug.buildEntry(MockBuildContext())),
      ));
      await tester.pumpAndSettle();

      // Skip entry1
      expect(find.text('Haus'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Now entry2 should be shown
      expect(find.text('Auto'), findsOneWidget);

      // Mark entry2 as Hard
      await tester.tap(find.text('Auto')); // Flip
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Hard'));
      await tester.pumpAndSettle();

      // Now entry1 should be shown (since it was skipped and appended)
      expect(find.text('Haus'), findsOneWidget);

      // Mark entry1 as Easy
      await tester.tap(find.text('Haus')); // Flip
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Easy'));
      await tester.pumpAndSettle();

      // Now entry2 should be shown again (since it was marked hard and appended)
      expect(find.text('Auto'), findsOneWidget);

      await tester.tap(find.text('Auto')); // Flip
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Easy'));
      await tester.pumpAndSettle();

      expect(find.text('Session Complete!'), findsOneWidget);

    });

  });
}

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
