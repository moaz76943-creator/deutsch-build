import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/widgets/bidi_lexicon_view.dart';
import 'package:deutsch_bilarabi/widgets/accessible_multilingual_text.dart';
import 'package:deutsch_bilarabi/widgets/lexicon_rich_details.dart';
import 'package:deutsch_bilarabi/widgets/resilient_text_container.dart';

void main() {
  Widget _wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('J014 BiDi Lexical Widgets Tests', () {
    testWidgets('AccessibleMultilingualText renders correct direction', (tester) async {
      await tester.pumpWidget(_wrap(
        const AccessibleMultilingualText(
          text: 'مرحبا',
          languageCode: 'ar',
          protectPunctuation: false, // Don't wrap with markers to easily test semantics label
        ),
      ));

      // The inner Directionality is inside AppDirectionalText, which uses LanguageBiDiHelper correctly
      // We also wrap it inside Semantics which specifies the textDirection. We'll check the inner Directionality.
      // The AccessibleMultilingualText wrapper itself uses a Semantics node
      final semanticsNodes = tester.widgetList<Semantics>(find.byType(Semantics));
      final semantics = semanticsNodes.firstWhere((s) => s.properties.label == 'مرحبا');
      expect(semantics.properties.label, 'مرحبا');
      expect(semantics.properties.textDirection, TextDirection.rtl);

      // AppDirectionalText sets direction explicitly to Directionality
      final directionality = tester.widget<Directionality>(
        find.descendant(
          of: find.byWidget(semantics),
          matching: find.byType(Directionality),
        ).first,
      );
      expect(directionality.textDirection, TextDirection.rtl);
    });

    testWidgets('LexiconRichDetails handles missing metadata gracefully', (tester) async {
      await tester.pumpWidget(_wrap(
        const LexiconRichDetails(
          partOfSpeech: null,
          gender: null,
          pluralForm: null,
          ipa: null,
          explanation: null,
        ),
      ));

      expect(find.byType(Column), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('LexiconRichDetails renders metadata and RTL explanation', (tester) async {
      await tester.pumpWidget(_wrap(
        const LexiconRichDetails(
          partOfSpeech: 'Noun',
          gender: 'der',
          pluralForm: 'Apfel',
          ipa: 'ˈapfl̩',
          explanation: 'تفاحة',
          explanationLanguageCode: 'ar',
        ),
      ));

      expect(find.text('POS: Noun'), findsOneWidget);
      expect(find.text('Gender: der'), findsOneWidget);
      expect(find.text('Plural: Apfel'), findsOneWidget);
      expect(find.text('/ˈapfl̩/'), findsOneWidget);

      // IPA should be LTR
      final ipaDirectionality = tester.widget<Directionality>(
        find.ancestor(
          of: find.text('/ˈapfl̩/'),
          matching: find.byType(Directionality),
        ).first,
      );
      expect(ipaDirectionality.textDirection, TextDirection.ltr);
    });

    testWidgets('ResilientTextContainer bounds test without overflow', (tester) async {
      // Intentionally using long text and constrained width to ensure LayoutBuilder prevents unbounded constraints
      await tester.pumpWidget(_wrap(
        SizedBox(
          width: 100,
          child: ResilientTextContainer(
            child: const Text('A very very very very very very very very long text that could overflow'),
          ),
        ),
      ));

      // Should not throw an overflow exception during layout
      expect(tester.takeException(), isNull);
    });

    testWidgets('BidiLexiconView renders mixed scripts correctly', (tester) async {
      await tester.pumpWidget(_wrap(
        const BidiLexiconView(
          sourceText: 'Haus',
          sourceLanguageCode: 'de',
          targetText: 'منزل',
          targetLanguageCode: 'ar',
          gender: 'das',
        ),
      ));

      // The texts in AccessibleMultilingualText are wrapped with LTR/RTL marks due to protectPunctuation being true.
      // So we use partial matches for the wrapped text.
      expect(find.textContaining('Haus', skipOffstage: false), findsWidgets); // Source Text
      expect(find.text('Gender: das', skipOffstage: false), findsOneWidget); // Metadata
      expect(find.textContaining('منزل', skipOffstage: false), findsWidgets); // Target Text
    });
  });
}
