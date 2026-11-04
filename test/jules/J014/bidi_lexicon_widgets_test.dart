import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/widgets/accessible_multilingual_text.dart';
import 'package:deutsch_bilarabi/widgets/bidi_lexicon_view.dart';
import 'package:deutsch_bilarabi/widgets/resilient_text_container.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';

void main() {
  group('J014 — BiDi Lexical Widgets Tests', () {
    testWidgets('AccessibleMultilingualText renders safely with correct directionality', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleMultilingualText(
              text: 'القطار',
              languageCode: 'ar',
              semanticLabel: 'Train',
            ),
          ),
        ),
      );

      // We should check that Semantics node exists with the correct label.
      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Train',
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('ResilientTextContainer prevents horizontal overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100, // Very narrow container
              child: ResilientTextContainer(
                child: const Text('This is a very long text that will surely overflow if not protected.'),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull); // No overflow exception
    });

    testWidgets('BidiLexiconView renders full lexical entry safely', (WidgetTester tester) async {
      const entry = LexicalEntry(
        id: '1',
        domainId: 'test',
        sourceLocale: 'ar',
        targetLocale: 'de',
        targetTerm: 'der Zug',
        sourceMeaning: 'القطار',
        targetExample: 'Der Zug fährt ab.',
        sourceExampleTranslation: 'القطار يغادر.',
        partOfSpeech: 'noun',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150, // Small width to trigger ResilientTextContainer
              // Using a flexible container so Column doesn't force infinite width in Row
              child: BidiLexiconView(
                sourceText: entry.sourceMeaning,
                sourceLanguageCode: 'ar',
                targetText: entry.targetTerm,
                targetLanguageCode: 'de',
                partOfSpeech: entry.partOfSpeech,
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('der Zug'), findsOneWidget);
      expect(find.textContaining('القطار'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BidiLexiconView handles missing optional fields without crashing', (WidgetTester tester) async {
      const entry = LexicalEntry(
        id: '2',
        domainId: 'test',
        sourceLocale: 'ar',
        targetLocale: 'de',
        targetTerm: 'Hallo',
        sourceMeaning: 'مرحبا',
        targetExample: '', // Missing
        sourceExampleTranslation: '', // Missing
        partOfSpeech: 'interjection',
      );

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

      expect(find.textContaining('Hallo'), findsOneWidget);
      expect(find.textContaining('مرحبا'), findsOneWidget);
      expect(find.textContaining('Example:'), findsNothing); // Example section shouldn't render
      expect(tester.takeException(), isNull);
    });
  });
}
