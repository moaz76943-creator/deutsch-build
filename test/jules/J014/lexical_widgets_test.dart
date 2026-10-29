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
                const AccessibleMultilingualText('مرحبا', locale: 'ar'),
                const AccessibleMultilingualText('Hello', locale: 'en'),
              ],
            ),
          ),
        ),
      );

      final arabicText = BiDiTextIsolator.wrapDirectional('مرحبا', isRtl: true);
      final arabicDir = tester.widget<Directionality>(
        find.ancestor(of: find.text(arabicText), matching: find.byType(Directionality)).first
      );
      expect(arabicDir.textDirection, TextDirection.rtl);

      final englishText = BiDiTextIsolator.wrapDirectional('Hello', isRtl: false);
      final englishDir = tester.widget<Directionality>(
        find.ancestor(of: find.text(englishText), matching: find.byType(Directionality)).first
      );
      expect(englishDir.textDirection, TextDirection.ltr);
    });

    testWidgets('BidiLexiconView renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const BidiLexiconView(
              sourceText: 'der Hund',
              sourceLocale: 'de',
              targetText: 'الكلب',
              targetLocale: 'ar',
            ),
          ),
        ),
      );

      final sourceTextWrapped = BiDiTextIsolator.wrapDirectional('der Hund', isRtl: false);
      final targetTextWrapped = BiDiTextIsolator.wrapDirectional('الكلب', isRtl: true);
      expect(find.text(sourceTextWrapped), findsOneWidget);
      expect(find.text(targetTextWrapped), findsOneWidget);
    });

    testWidgets('LexiconRichDetails renders optional fields without crash', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LexiconRichDetails(
              term: 'der Zug',
              termLocale: 'de',
              translation: 'القطار',
              translationLocale: 'ar',
            ),
          ),
        ),
      );

      final sourceTextWrapped = BiDiTextIsolator.wrapDirectional('der Zug', isRtl: false);
      final targetTextWrapped = BiDiTextIsolator.wrapDirectional('القطار', isRtl: true);
      expect(find.text(sourceTextWrapped), findsOneWidget);
      expect(find.text(targetTextWrapped), findsOneWidget);
    });

    testWidgets('LexiconRichDetails renders with all fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LexiconRichDetails(
              term: 'der Zug',
              termLocale: 'de',
              translation: 'القطار',
              translationLocale: 'ar',
              partOfSpeech: 'Noun (m)',
              example: 'Der Zug fährt ab.',
              exampleTranslation: 'القطار يغادر.',
            ),
          ),
        ),
      );

      final sourceTextWrapped = BiDiTextIsolator.wrapDirectional('der Zug', isRtl: false);
      final exampleWrapped = BiDiTextIsolator.wrapDirectional('Der Zug fährt ab.', isRtl: false);
      expect(find.text('Noun (m)'), findsOneWidget);
      expect(find.text(sourceTextWrapped), findsOneWidget);
      expect(find.text(exampleWrapped), findsOneWidget);
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
                term: 'Ein sehr langes deutsches Wort das fast keinen Sinn macht',
                termLocale: 'de',
                translation: 'كلمة ألمانية طويلة جداً تكاد لا يكون لها معنى',
                translationLocale: 'ar',
                example: 'Das ist ein unglaublich langes Beispiel, um zu testen, wie das System mit Textüberlauf in schmalen Bildschirmen umgeht.',
                exampleTranslation: 'هذا مثال طويل بشكل لا يصدق لاختبار كيفية تعامل النظام مع تجاوز النص في الشاشات الضيقة.',
              ),
            ),
          ),
        ),
      );

      final termWrapped = BiDiTextIsolator.wrapDirectional('Ein sehr langes deutsches Wort das fast keinen Sinn macht', isRtl: false);
      final exampleWrapped = BiDiTextIsolator.wrapDirectional('Das ist ein unglaublich langes Beispiel, um zu testen, wie das System mit Textüberlauf in schmalen Bildschirmen umgeht.', isRtl: false);
      expect(find.text(termWrapped), findsOneWidget);
      expect(find.text(exampleWrapped), findsOneWidget);
    });
  });
}
