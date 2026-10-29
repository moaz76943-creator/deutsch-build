import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/widgets/lexical/accessible_multilingual_text.dart';
import 'package:deutsch_bilarabi/widgets/lexical/bidi_lexicon_view.dart';
import 'package:deutsch_bilarabi/widgets/lexical/lexicon_rich_details.dart';
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
            ),
          ),
        ),
      );

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
            ),
          ),
        ),
      );

      expect(find.text('Hallo'), findsOneWidget);
      expect(find.text('مرحبا'), findsOneWidget);
      expect(find.text('الجمع:'), findsNothing); // should not find the plural prefix
      expect(find.byIcon(Icons.format_quote_rounded), findsNothing); // should not find example section
    });
  });
}
