import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/flashcards/flashcard_models.dart';
import 'package:deutsch_bilarabi/features/flashcards/flashcard_widget.dart';
import 'package:deutsch_bilarabi/features/flashcards/flashcards_plug.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';

void main() {
  group('Flashcards Widget Tests', () {
    testWidgets('Card flip and grading submit correctly', (WidgetTester tester) async {
      int? submittedRating;
      String? submittedCardId;

      final card = const FlashcardData(
        id: 'card_1',
        frontText: 'Apfel',
        backText: 'تفاحة',
        example: 'Der Apfel ist rot.',
        translation: 'التفاحة حمراء.',
        hasAudio: true,
        sourceIso: 'de',
        targetIso: 'ar',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onReviewed: (id, rating, src, tgt) async {
                submittedCardId = id;
                submittedRating = rating;
              },
            ),
          ),
        ),
      );

      expect(find.text('Apfel'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('flashcard_front')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Correct'));
      await tester.pumpAndSettle();

      expect(submittedCardId, 'card_1');
      expect(submittedRating, 2);
    });

    testWidgets('Duplicate tap prevention during rating submission', (WidgetTester tester) async {
      int reviewCallCount = 0;
      final completer = Completer<void>();

      final card = const FlashcardData(
        id: 'card_2',
        frontText: 'Katze',
        backText: 'قطة',
        sourceIso: 'de',
        targetIso: 'ar',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onReviewed: (id, rating, src, tgt) async {
                reviewCallCount++;
                await completer.future; // Simulate network or db delay
              },
            ),
          ),
        ),
      );

      // Flip
      await tester.tap(find.byKey(const ValueKey('flashcard_front')));
      await tester.pumpAndSettle();

      // Tap Easy rapidly multiple times
      final button = find.text('Easy');
      await tester.tap(button);
      await tester.tap(button);
      await tester.tap(button);

      // Wait for UI to update to loading state
      await tester.pump();

      // Verify loading state is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Tap again while answering (button should be hidden, but we verify logic doesn't allow it if somehow pressed)
      // The button widget itself gets replaced by the indicator, so tapping it might throw if not careful.
      // The fact we tapped 3 times synchronously above tests the debounce logic inside _submitRating itself!

      expect(reviewCallCount, 1); // Should only trigger once

      // Complete the future to clean up
      completer.complete();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    testWidgets('Interrupted review safe disposal', (WidgetTester tester) async {
      final completer = Completer<void>();

      final card = const FlashcardData(
        id: 'card_3',
        frontText: 'Hund',
        backText: 'كلب',
        sourceIso: 'de',
        targetIso: 'ar',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onReviewed: (id, rating, src, tgt) async {
                await completer.future;
              },
            ),
          ),
        ),
      );

      // Flip
      await tester.tap(find.byKey(const ValueKey('flashcard_front')));
      await tester.pumpAndSettle();

      // Tap to start answering
      await tester.tap(find.text('Correct'));
      await tester.pump();

      // Replace widget to simulate disposal before future completes
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));

      // Complete future after widget is disposed
      completer.complete();

      // Pump to process any pending microtasks - should not throw unhandled exception for calling setState on unmounted widget
      await tester.pumpAndSettle();
    });
    testWidgets('Missing optional fields do not crash', (WidgetTester tester) async {
      final card = const FlashcardData(
        id: 'card_4',
        frontText: 'Vogel',
        backText: 'طائر',
        // Omit example, translation, hasAudio
        sourceIso: 'de',
        targetIso: 'ar',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onReviewed: (_, __, ___, ____) async {},
            ),
          ),
        ),
      );

      // Flip
      await tester.tap(find.byKey(const ValueKey('flashcard_front')));
      await tester.pumpAndSettle();

      // Ensure back is visible and no exceptions thrown
      expect(find.text('طائر'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsNothing);
    });

    testWidgets('Language pair switching enforces correct text directionality', (WidgetTester tester) async {
      // Create a card with AR as source and DE as target
      final card = const FlashcardData(
        id: 'card_5',
        frontText: 'تفاحة',
        backText: 'Apfel',
        example: 'التفاحة حمراء.',
        translation: 'Der Apfel ist rot.',
        sourceIso: 'ar',
        targetIso: 'de',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onReviewed: (_, __, ___, ____) async {},
            ),
          ),
        ),
      );

      // Verify front text directionality (Arabic Source -> RTL)
      final frontDirectionalityFinder = find.ancestor(
        of: find.text('تفاحة'),
        matching: find.byType(Directionality),
      ).first;

      final Directionality frontDir = tester.widget(frontDirectionalityFinder);
      expect(frontDir.textDirection, TextDirection.rtl);

      // Flip
      await tester.tap(find.byKey(const ValueKey('flashcard_front')));
      await tester.pumpAndSettle();

      // Verify back text directionality (German Target -> LTR)
      final backDirectionalityFinder = find.ancestor(
        of: find.text('Apfel'),
        matching: find.byType(Directionality),
      ).first;

      final Directionality backDir = tester.widget(backDirectionalityFinder);
      expect(backDir.textDirection, TextDirection.ltr);

      // Verify translation directionality (Arabic Source -> RTL)
      final transDirectionalityFinder = find.ancestor(
        of: find.text('Der Apfel ist rot.'),
        matching: find.byType(Directionality),
      ).first;

      final Directionality transDir = tester.widget(transDirectionalityFinder);
      expect(transDir.textDirection, TextDirection.rtl);
    });
  });
}
