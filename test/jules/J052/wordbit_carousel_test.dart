import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/wordbit/ui/wordbit_carousel_screen.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';

void main() {
  setUp(() {
    LexicalRepository.initializeStore([
      const LexicalEntry(
        id: 'c_test_01',
        domainId: 'd_test',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'die Herausforderung',
        sourceMeaning: 'التحدي',
        targetExample: 'Das ist eine echte Herausforderung.',
        sourceExampleTranslation: 'هذا تحدٍ حقيقي.',
        partOfSpeech: 'Nomen (f)',
      ),
      const LexicalEntry(
        id: 'c_test_02',
        domainId: 'd_test',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'lernen',
        sourceMeaning: 'يتعلم',
        targetExample: 'Ich lerne Deutsch.',
        sourceExampleTranslation: 'أنا أتعلم الألمانية.',
        partOfSpeech: 'Verb',
      ),
    ]);
  });

  testWidgets('WordBitCarouselScreen displays real cards, handles vector fallback and SRS swipe', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WordBitCarouselScreen(
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
      )
    ));
    await tester.pumpAndSettle();

    // Verify fallback semantic element
    expect(find.byIcon(Icons.image_not_supported), findsWidgets);
    expect(find.text('c_test_01'), findsWidgets);
    expect(find.text('die Herausforderung'), findsWidgets);

    // Tap to flip
    await tester.tap(find.text('die Herausforderung').first);
    await tester.pumpAndSettle();

    // Back should show translation
    expect(find.text('التحدي'), findsWidgets);

    // Hit easy button
    await tester.tap(find.text('سهل'));
    await tester.pumpAndSettle();

    // Next card should be displayed
    expect(find.text('lernen'), findsWidgets);
  });

  testWidgets('Empty state shown when no entries available', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WordBitCarouselScreen(
        sourceLocale: 'ar-SA',
        targetLocale: 'en-US',
      )
    ));
    await tester.pumpAndSettle();

    expect(find.text('لا توجد بطاقات متاحة حالياً'), findsOneWidget);
  });

  testWidgets('Screen pops when the last card is graded', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WordBitCarouselScreen(
          sourceLocale: 'ar-SA',
          targetLocale: 'de-DE',
        )
      )
    ));
    await tester.pumpAndSettle();

    // First card
    await tester.tap(find.text('سهل'));
    await tester.pumpAndSettle();

    // Second card (last)
    await tester.tap(find.text('سهل'));
    await tester.pumpAndSettle();

    // Should pop and remove widget
    expect(find.byType(WordBitCarouselScreen), findsNothing);
  });
  testWidgets('Prevents double tap during animation (rapid swipe)', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WordBitCarouselScreen(
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
      )
    ));
    await tester.pumpAndSettle();

    // Tap first time
    await tester.tap(find.text('سهل'));
    await tester.pump(); // Start animation, but do not settle

    // Tap again rapidly during animation
    await tester.tap(find.text('سهل'));

    // Wait for animation to finish
    await tester.pumpAndSettle();

    // Should be on next page, no crash
    expect(find.text('lernen'), findsWidgets);
  });

  testWidgets('Handles large text sizes gracefully', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3.0)),
          child: child!,
        );
      },
      home: const WordBitCarouselScreen(
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
      )
    ));
    await tester.pumpAndSettle();

    expect(find.text('die Herausforderung'), findsWidgets);
  });

}
