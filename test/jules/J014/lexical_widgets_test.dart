import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/widgets/accessible_multilingual_text.dart';
import 'package:deutsch_bilarabi/widgets/bidi_lexicon_view.dart';
import 'package:deutsch_bilarabi/widgets/lexicon_rich_details.dart';
import 'package:deutsch_bilarabi/widgets/resilient_text_container.dart';
import 'package:deutsch_bilarabi/core/bidi_helper.dart';
import 'package:deutsch_bilarabi/design_system/widgets/app_directional_text.dart';

void main() {
  testWidgets('AccessibleMultilingualText handles RTL and LTR properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccessibleMultilingualText(
            text: 'مرحبا',
            languageCode: 'ar',
          ),
        ),
      ),
    );
    expect(find.byType(AccessibleMultilingualText), findsOneWidget);
    expect(find.text(BiDiHelper.wrapRtl('مرحبا')), findsOneWidget);

    // Explicitly check for AppDirectionalText usage
    expect(find.byType(AppDirectionalText), findsOneWidget);
    final AppDirectionalText dirText = tester.widget(find.byType(AppDirectionalText));
    expect(dirText.forceDirection, TextDirection.rtl);
  });

  testWidgets('BidiLexiconView renders safely with missing optional fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BidiLexiconView(
            sourceText: 'مرحبا',
            sourceLanguageCode: 'ar',
            targetText: 'Hello',
            targetLanguageCode: 'en',
          ),
        ),
      ),
    );
    expect(find.byType(BidiLexiconView), findsOneWidget);
    expect(find.text(BiDiHelper.wrapRtl('مرحبا')), findsOneWidget);
    expect(find.text(BiDiHelper.wrapLtr('Hello')), findsOneWidget);
  });

  testWidgets('LexiconRichDetails renders correctly when all fields provided and handles BiDi', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LexiconRichDetails(
            partOfSpeech: 'Noun',
            gender: 'Male',
            pluralForm: 'Hellos',
            ipa: 'hɛˈloʊ',
            explanation: 'تحية',
            explanationLanguageCode: 'ar',
          ),
        ),
      ),
    );
    expect(find.byType(LexiconRichDetails), findsOneWidget);
    expect(find.text('POS: \u2068Noun\u2069'), findsOneWidget); // We need to update this to expect Unicode isolation
    expect(find.text('Gender: \u2068Male\u2069'), findsOneWidget);
    expect(find.text('Plural: \u2068Hellos\u2069'), findsOneWidget);
    expect(find.text('/hɛˈloʊ/'), findsOneWidget);
    expect(find.text(BiDiHelper.wrapRtl('تحية')), findsOneWidget);
  });

  testWidgets('BidiLexiconView renders safely with extreme dynamic text scaling', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400); // 400x800 logical
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(3.0)),
            child: BidiLexiconView(
              sourceText: 'شجرة',
              sourceLanguageCode: 'ar',
              targetText: 'Tree',
              targetLanguageCode: 'en',
              explanation: 'A woody perennial plant, typically having a single stem or trunk growing to a considerable height and bearing lateral branches at some distance from the ground.',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(BidiLexiconView), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('ResilientTextContainer does not crash with narrow width constraints', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 10,
            child: ResilientTextContainer(
              child: Text('This is a very long text that will definitely overflow a width of 10 pixels without resilient constraints.'),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ResilientTextContainer), findsOneWidget);
  });
}
