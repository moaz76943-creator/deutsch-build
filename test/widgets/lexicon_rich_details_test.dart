import 'package:deutsch_bilarabi/screens/word_deep_dive_sheet.dart';
import 'package:deutsch_bilarabi/widgets/bidi_lexicon_view.dart';
import 'package:deutsch_bilarabi/widgets/lexicon_rich_details.dart';
import 'package:deutsch_bilarabi/widgets/example_sentences_view.dart';
import 'package:deutsch_bilarabi/widgets/noun_classifier_view.dart';
import 'package:deutsch_bilarabi/widgets/phonetic_ipa_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('missing optional metadata leaves headword and meaning visible',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WordDeepDiveSheet(
          wordData: <String, dynamic>{
            'surface': 'Buch',
            'translation_ar': 'كتاب',
          },
        ),
      ),
    ));

    expect(find.byType(BidiLexiconView), findsOneWidget);
    expect(find.textContaining('Buch'), findsOneWidget);
    expect(find.textContaining('كتاب'), findsOneWidget);
    expect(find.byType(PhoneticIpaView), findsNothing);
    expect(find.byType(ExampleSentencesView), findsNothing);
    expect(find.byKey(const Key('nounClassifierBadge')), findsNothing);
  });

  testWidgets('IPA and translated examples use original lexicon fields',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WordDeepDiveSheet(
          wordData: <String, dynamic>{
            'id': '',
            'surface': 'Buch',
            'fields': <String, dynamic>{
              'ipa': 'buːx',
              'examples': <Map<String, String>>[
                <String, String>{
                  'sentence': 'Das Buch ist neu.',
                  'translation_ar': 'الكتاب جديد.',
                },
              ],
            },
          },
        ),
      ),
    ));

    expect(find.byType(PhoneticIpaView), findsOneWidget);
    expect(find.byType(ExampleSentencesView), findsOneWidget);
    expect(find.text('/buːx/'), findsOneWidget);
    expect(find.text('الكتاب جديد.'), findsOneWidget);
  });

  testWidgets('noun classifier is inline for a supported language',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WordDeepDiveSheet(
          wordData: <String, dynamic>{
            'surface': '纸',
            'language_code': 'zh',
            'part_of_speech': 'noun',
            'classifier': '张',
            'fields': <String, dynamic>{
              'classifier_reading': 'zhāng',
            },
          },
        ),
      ),
    ));

    expect(find.byType(NounClassifierView), findsOneWidget);
    expect(find.byKey(const Key('nounClassifierBadge')), findsOneWidget);
  });

  // PR #17: shared lexicon presenter coverage.
  testWidgets('missing optional data leaves only the headword and meaning',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LexiconRichDetails(
          entry: <String, dynamic>{
            'surface': 'Buch',
            'translation_ar': 'كتاب',
          },
        ),
      ),
    ));

    expect(find.byType(PhoneticIpaView), findsNothing);
    expect(find.byType(ExampleSentencesView), findsNothing);
    expect(find.byType(NounClassifierView), findsNothing);
  });

  testWidgets('IPA and examples are rendered from original lexicon fields',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LexiconRichDetails(
          entry: <String, dynamic>{
            'id': '',
            'surface': 'Buch',
            'fields': <String, dynamic>{
              'ipa': 'buːx',
              'examples': <Map<String, String>>[
                <String, String>{
                  'sentence': 'Das Buch ist neu.',
                  'translation_ar': 'الكتاب جديد.',
                },
              ],
            },
          },
        ),
      ),
    ));

    expect(find.byType(PhoneticIpaView), findsOneWidget);
    expect(find.byType(ExampleSentencesView), findsOneWidget);
    expect(find.text('/buːx/'), findsOneWidget);
    expect(find.text('الكتاب جديد.'), findsOneWidget);
  });

  testWidgets('noun classifier is available inline for supported language',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LexiconRichDetails(
          languageCode: 'zh',
          entry: <String, dynamic>{
            'surface': '纸',
            'part_of_speech': 'noun',
            'classifier': '张',
            'classifier_reading': 'zhāng',
          },
        ),
      ),
    ));
    expect(find.byType(NounClassifierView), findsOneWidget);
    expect(find.byKey(const Key('nounClassifierBadge')), findsOneWidget);
  });
}
