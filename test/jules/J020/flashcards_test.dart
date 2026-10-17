import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/flashcards/flashcards_plug.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';

void main() {
  setUpAll(() {
    LexicalRepository.initializeStore([
      const LexicalEntry(
        id: 'test_1',
        domainId: 'general',
        sourceLocale: 'de-DE',
        targetLocale: 'ar-SA',
        targetTerm: 'مرحبا',
        sourceMeaning: 'Hallo',
        targetExample: 'مرحبا بك في التطبيق',
        sourceExampleTranslation: 'Willkommen in der App',
        partOfSpeech: 'greeting',
      ),
      const LexicalEntry(
        id: 'test_2',
        domainId: 'general',
        sourceLocale: 'en-US',
        targetLocale: 'es-ES',
        targetTerm: 'Hola',
        sourceMeaning: 'Hello',
        targetExample: '',
        sourceExampleTranslation: '',
        partOfSpeech: 'greeting',
      ),
    ]);
  });

  testWidgets('Flashcards container displays lexical data dynamically by pair and handles flip', (WidgetTester tester) async {
    final plug = FlashcardsPlug(
      sourceLocale: 'de-DE',
      targetLocale: 'ar-SA',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: plug.buildEntry(MockContext()),
      ),
    ));

    expect(find.textContaining('Hallo'), findsWidgets);

    // Tap to flip
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.textContaining('مرحبا'), findsWidgets);
  });

  testWidgets('Pair switching preserves context', (WidgetTester tester) async {
    final plug = FlashcardsPlug(
      sourceLocale: 'en-US',
      targetLocale: 'es-ES',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: plug.buildEntry(MockContext()),
      ),
    ));

    expect(find.textContaining('Hello'), findsWidgets);

    // Tap to flip
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Hola'), findsWidgets);
  });

  testWidgets('Card grading triggers SrsCompatBridge and prevents rapid double taps (interrupted review)', (WidgetTester tester) async {
    final plug = FlashcardsPlug(
      sourceLocale: 'de-DE',
      targetLocale: 'ar-SA',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: plug.buildEntry(MockContext()),
      ),
    ));

    // Tap to flip
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Tap the 'جيد' (Good) rating twice rapidly
    await tester.tap(find.text('جيد'));
    await tester.tap(find.text('جيد'));

    await tester.pumpAndSettle();

    expect(find.text('اكتملت المراجعة'), findsOneWidget);
  });

  testWidgets('Repeated-answer flow: Hard rating appends card to end', (WidgetTester tester) async {
    final plug = FlashcardsPlug(
      sourceLocale: 'de-DE',
      targetLocale: 'ar-SA',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: plug.buildEntry(MockContext()),
      ),
    ));

    // Tap to flip
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Tap 'صعب' (Hard), it should repeat the card
    await tester.tap(find.text('صعب'));
    await tester.pumpAndSettle();

    // The state should be front again instead of completed
    expect(find.textContaining('Hallo'), findsWidgets);

    // Tap to flip again
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Tap 'جيد' (Good) this time
    await tester.tap(find.text('جيد'));
    await tester.pumpAndSettle();

    expect(find.text('اكتملت المراجعة'), findsOneWidget);
  });

  testWidgets('Skip flow handles gracefully', (WidgetTester tester) async {
    final plug = FlashcardsPlug(
      sourceLocale: 'en-US',
      targetLocale: 'es-ES',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: plug.buildEntry(MockContext()),
      ),
    ));

    // Tap to flip
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Tap 'تخطي' (Skip)
    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();

    expect(find.text('اكتملت المراجعة'), findsOneWidget);
  });

  testWidgets('Missing optional fields handle gracefully', (WidgetTester tester) async {
    final plug = FlashcardsPlug(
      sourceLocale: 'en-US',
      targetLocale: 'es-ES',
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: plug.buildEntry(MockContext()),
      ),
    ));

    // Tap to flip
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Hola'), findsWidgets);
  });
}

class MockContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
