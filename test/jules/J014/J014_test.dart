import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/widgets/accessible_multilingual_text.dart';
import 'package:deutsch_bilarabi/widgets/bidi_lexicon_view.dart';
import 'package:deutsch_bilarabi/widgets/lexicon_rich_details.dart';

void main() {
  group('J014 BiDi Lexical Widgets & Overflow-Safe Rendering', () {
    testWidgets('AccessibleMultilingualText applies correct directionality and semantic label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleMultilingualText(
              text: 'مرحبا',
              languageCode: 'ar-SA',
              semanticLabel: 'Welcome',
            ),
          ),
        ),
      );

      final textFinder = find.byType(AccessibleMultilingualText);
      expect(textFinder, findsOneWidget);

      final directionalityFinder = find.descendant(
        of: textFinder,
        matching: find.byType(Directionality),
      );
      expect(directionalityFinder, findsWidgets);

      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Welcome',
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('BidiLexiconView renders safely without overflows in narrow constraints', (WidgetTester tester) async {
      const entry = LexicalEntry(
        id: '1',
        domainId: 'domain_1',
        sourceLocale: 'ar-EG',
        targetLocale: 'de-DE',
        targetTerm: 'der Zug',
        sourceMeaning: 'القطار الطويل جدا جدا جدا جدا الذي لا ينتهي ابدا في هذا النص الطويل جدا',
        targetExample: 'Der Zug ist sehr schnell.',
        sourceExampleTranslation: 'القطار سريع جدا.',
        partOfSpeech: 'Nomen (m)',
      );

      // Force narrow width constraint
      tester.view.physicalSize = const Size(200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiLexiconView(
              sourceText: entry.sourceMeaning,
              sourceLanguageCode: 'ar',
              targetText: entry.targetTerm,
              targetLanguageCode: 'de',
              partOfSpeech: entry.partOfSpeech,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull); // Should not crash or overflow
      expect(find.textContaining('der Zug'), findsOneWidget);

      // Reset view to avoid affecting other tests
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('LexiconRichDetails does not crash on missing optional fields', (WidgetTester tester) async {
      const entryEmpty = LexicalEntry(
        id: '2',
        domainId: 'domain_1',
        sourceLocale: 'ar-EG',
        targetLocale: 'de-DE',
        targetTerm: 'laufen',
        sourceMeaning: 'يركض',
        targetExample: '', // Empty
        sourceExampleTranslation: '', // Empty
        partOfSpeech: '', // Empty
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LexiconRichDetails(
              partOfSpeech: entryEmpty.partOfSpeech,
              explanation: entryEmpty.sourceExampleTranslation,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // It should just render nothing if they are empty
      expect(find.byType(AccessibleMultilingualText), findsNothing);
    });

    testWidgets('LexiconRichDetails renders mixed scripts and long text accurately', (WidgetTester tester) async {
      const entry = LexicalEntry(
        id: '3',
        domainId: 'domain_1',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'schlafen',
        sourceMeaning: 'ينام',
        targetExample: 'Ich schlafe jeden Tag 8 Stunden, weil es wichtig ist für meine Gesundheit, besonders wenn ich arbeite.',
        sourceExampleTranslation: 'أنا أنام كل يوم 8 ساعات، لأن ذلك مهم لصحتي، خاصة عندما أعمل.',
        partOfSpeech: 'Verb',
      );

      // Apply huge text scaling constraint
      tester.platformDispatcher.textScaleFactorTestValue = 3.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LexiconRichDetails(
                partOfSpeech: entry.partOfSpeech,
                explanation: entry.sourceExampleTranslation,
                explanationLanguageCode: 'ar',
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull); // Should not crash or overflow
      expect(find.textContaining('Verb'), findsOneWidget);
      expect(find.byType(AccessibleMultilingualText), findsOneWidget);

      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
  });
}
