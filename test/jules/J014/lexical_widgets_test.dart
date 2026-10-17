import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
<<<<<<< HEAD
import 'package:deutsch_bilarabi/widgets/lexical/accessible_multilingual_text.dart';
import 'package:deutsch_bilarabi/widgets/lexical/bidi_lexicon_view.dart';
import 'package:deutsch_bilarabi/widgets/lexical/resilient_text_container.dart';
import 'package:deutsch_bilarabi/widgets/lexical/lexicon_rich_details.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/design_system/widgets/app_directional_text.dart';

void main() {
  group('AccessibleMultilingualText', () {
    testWidgets('renders RTL text correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AccessibleMultilingualText('مرحبا'))));

      final directionalText = tester.widget<AppDirectionalText>(find.byType(AppDirectionalText));
      expect(directionalText.text, 'مرحبا');
    });

    testWidgets('renders LTR text correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AccessibleMultilingualText('Hello'))));

      final directionalText = tester.widget<AppDirectionalText>(find.byType(AppDirectionalText));
      expect(directionalText.text, 'Hello');
    });
  });

  group('LexiconRichDetails', () {
    testWidgets('renders title and content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LexiconRichDetails(title: 'Meaning', content: 'معنى', icon: Icons.translate),
          ),
        ),
      );

      expect(find.text('Meaning'), findsOneWidget);
      expect(find.text('معنى'), findsOneWidget);
      expect(find.byIcon(Icons.translate), findsOneWidget);
    });

    testWidgets('does not render if content is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LexiconRichDetails(title: 'Meaning', content: ' ', icon: Icons.translate),
          ),
        ),
      );

      expect(find.text('Meaning'), findsNothing);
      expect(find.byIcon(Icons.translate), findsNothing);
    });
  });

  group('BidiLexiconView', () {
    testWidgets('renders all details correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiLexiconView(
              word: 'Apfel',
              article: 'der',
              plural: 'Äpfel',
              meaning: 'تفاحة',
              example: 'Ich esse einen Apfel.',
=======
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
>>>>>>> origin/main
            ),
          ),
        ),
      );

<<<<<<< HEAD
      expect(find.text('der'), findsOneWidget);
      expect(find.text('Apfel'), findsOneWidget);
      expect(find.text('الجمع: \u2068Äpfel\u2069'), findsOneWidget);
      expect(find.text('تفاحة'), findsOneWidget);
      expect(find.text('\u2068Ich esse einen Apfel.\u2069'), findsOneWidget);
    });

    testWidgets('does not crash or show nulls when optional fields are missing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiLexiconView(
              word: 'Hallo',
              meaning: 'مرحبا',
=======
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
>>>>>>> origin/main
            ),
          ),
        ),
      );

<<<<<<< HEAD
      expect(find.text('Hallo'), findsOneWidget);
      expect(find.text('مرحبا'), findsOneWidget);
      expect(find.text('الجمع:'), findsNothing); // should not find the plural prefix
      expect(find.byIcon(Icons.format_quote_rounded), findsNothing); // should not find example section
=======
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
>>>>>>> origin/main
    });
  });
}
