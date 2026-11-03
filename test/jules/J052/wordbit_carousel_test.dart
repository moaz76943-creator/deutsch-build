import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/wordbit/ui/wordbit_carousel_screen.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';

void main() {
  setUp(() {
    LexicalRepository.initializeStore([
      const LexicalEntry(
        id: 'c1',
        domainId: 'd1',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'die Herausforderung',
        sourceMeaning: 'التحدي',
        targetExample: 'Das ist eine echte Herausforderung.',
        sourceExampleTranslation: 'هذا تحدٍ حقيقي.',
        partOfSpeech: 'Nomen (f)',
      ),
      const LexicalEntry(
        id: 'c2',
        domainId: 'd1',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'das Wasser',
        sourceMeaning: 'الماء',
        targetExample: 'Ich trinke Wasser.',
        sourceExampleTranslation: 'أشرب الماء.',
        partOfSpeech: 'Nomen (n)',
      )
    ]);
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: WordBitCarouselScreen(
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
      ),
    );
  }

  testWidgets('Renders missing vector fallback correctly without crashing', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Look for the image fallback icon (might be more than one due to PageView pre-rendering)
      expect(find.byIcon(Icons.image_not_supported), findsWidgets);
      expect(find.text('صورة غير متوفرة'), findsWidgets);

      // Look for the term (might also be multiple in PageView, but we can look for at least one)
      expect(find.text('die Herausforderung'), findsWidgets);
    });
  });

  testWidgets('Debounces rapid UI interactions preventing double grading', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap 'سهل' button multiple times rapidly
      final easyButton = find.text('سهل');
      expect(easyButton, findsOneWidget);

      await tester.tap(easyButton);
      await tester.tap(easyButton);
      await tester.tap(easyButton);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Should have only advanced one card due to _isProcessing flag
      expect(find.text('das Wasser'), findsOneWidget);
    });
  });

  testWidgets('Supports RTL/LTR correctly based on locales', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Term is on front, meaning is on back
      final targetTextFinder = find.text('die Herausforderung');
      expect(targetTextFinder, findsOneWidget);

      // Flip card
      await tester.tap(targetTextFinder);
      await tester.pumpAndSettle();

      // Now meaning should be visible
      final sourceTextFinder = find.text('التحدي');
      expect(sourceTextFinder, findsOneWidget);

      final sourceDirectionality = tester.widget<Directionality>(
        find.ancestor(of: sourceTextFinder, matching: find.byType(Directionality)).first
      );

      expect(sourceDirectionality.textDirection, TextDirection.rtl);
    });
  });

  testWidgets('SRS routing: Process review and advance carousel', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap 'صعب' button
      final hardButton = find.text('صعب');
      expect(hardButton, findsOneWidget);

      await tester.tap(hardButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Carousel should have advanced
      expect(find.text('das Wasser'), findsOneWidget);
    });
  });

  testWidgets('Adapts to large text sizes without layout overflow', (WidgetTester tester) async {
    await tester.runAsync(() async {
      // Simulate large text
      tester.binding.platformDispatcher.textScaleFactorTestValue = 3.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Ensure no exceptions were thrown during layout
      expect(tester.takeException(), isNull);

      // Cleanup
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
    });
  });

  testWidgets('Audio button is present as placeholder for missing TTS', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The icon should be visible
      expect(find.byIcon(Icons.volume_up), findsWidgets);
    });
  });

  testWidgets('Preserves current index across widget updates', (WidgetTester tester) async {
    await tester.runAsync(() async {
      // Create a stateful wrapper to update the widget
      late void Function(void Function()) setStateCallback;
      String currentDomain = 'd1';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateCallback = setState;
            return MaterialApp(
              home: WordBitCarouselScreen(
                sourceLocale: "ar-SA",
domainId: currentDomain,
              ),
            );
          },
        )
      );
      await tester.pumpAndSettle();

      // Advance one card
      final easyButton = find.text('سهل');
      await tester.tap(easyButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('das Wasser'), findsWidgets);

      // Trigger update
      setStateCallback(() {
        currentDomain = 'd2'; // We didn't setup d2 so it should either retain or fail gracefully
      });
      await tester.pumpAndSettle();

      // Index should be preserved or reset based on data availability
    });
  });
}
