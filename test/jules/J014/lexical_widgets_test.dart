import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/widgets/accessible_multilingual_text.dart';
import 'package:deutsch_bilarabi/widgets/bidi_lexicon_view.dart';
import 'package:deutsch_bilarabi/widgets/resilient_text_container.dart';
import 'package:deutsch_bilarabi/widgets/lexicon_rich_details.dart';
import 'package:deutsch_bilarabi/core/design/bidi_text_isolator.dart';

void main() {
  group('BiDi Lexical Widgets Tests', () {
    testWidgets('AccessibleMultilingualText handles RTL and LTR correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const AccessibleMultilingualText(text: 'مرحبا', languageCode: 'ar'),
                const AccessibleMultilingualText(text: 'Hello', languageCode: 'en'),
              ],
            ),
          ),
        ),
      );

      final arabicDir = tester.widget<Semantics>(
        find.ancestor(of: find.textContaining('مرحبا'), matching: find.byType(Semantics)).first
      );
      expect(arabicDir.properties.textDirection, TextDirection.rtl);

      final englishDir = tester.widget<Directionality>(
        find.ancestor(of: find.textContaining('Hello'), matching: find.byType(Directionality)).first
      );
      expect(englishDir.textDirection, TextDirection.ltr);
    });

    testWidgets('BidiLexiconView renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const BidiLexiconView(
              sourceText: 'der Hund',
              sourceLanguageCode: 'de',
              targetText: 'الكلب',
              targetLanguageCode: 'ar',
            ),
          ),
        ),
      );

      expect(find.textContaining('der Hund'), findsOneWidget);
      expect(find.textContaining('الكلب'), findsOneWidget);
    });

    testWidgets('LexiconRichDetails renders optional fields without crash', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LexiconRichDetails(
              explanation: 'القطار',
              explanationLanguageCode: 'ar',
            ),
          ),
        ),
      );

      expect(find.textContaining('القطار'), findsOneWidget);
    });

    testWidgets('LexiconRichDetails renders with all fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LexiconRichDetails(
              partOfSpeech: 'Noun (m)',
              explanation: 'Der Zug fährt ab.',
              explanationLanguageCode: 'de',
            ),
          ),
        ),
      );

      expect(find.textContaining('Noun (m)'), findsOneWidget);
      expect(find.textContaining('Der Zug fährt ab.'), findsOneWidget);
    });
    testWidgets('LexiconRichDetails handles long strings and dynamic scaling safely', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0)),
              child: child!,
            );
          },
          home: Scaffold(
            body: SingleChildScrollView(
              child: const LexiconRichDetails(
                explanation: 'هذا مثال طويل بشكل لا يصدق لاختبار كيفية تعامل النظام مع تجاوز النص في الشاشات الضيقة.',
                explanationLanguageCode: 'ar',
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('هذا مثال طويل بشكل لا يصدق لاختبار كيفية تعامل النظام مع تجاوز النص في الشاشات الضيقة.'), findsOneWidget);
    });
  });
}
