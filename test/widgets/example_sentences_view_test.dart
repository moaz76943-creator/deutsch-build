import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:deutsch_bilarabi/widgets/example_sentences_view.dart';

class _RecordingTtsService extends TtsService {
  final List<String> utterances = <String>[];
  final List<String> languageCodes = <String>[];

  @override
  Future<bool> speak(String text, {String languageCode = 'de'}) async {
    utterances.add(text);
    languageCodes.add(languageCode);
    return true;
  }
}

void main() {
  const sampleJson =
      '[{"sentence":"Das Haus ist groß.","translation":"البيت كبير."},'
      '{"sentence":"Ich mag dieses Haus.","translation":"أحب هذا البيت."}]';

  test('parses sentence and translation pairs', () {
    final examples = ExampleSentence.parseJson(sampleJson);

    expect(examples, hasLength(2));
    expect(examples.first.sentence, 'Das Haus ist groß.');
    expect(examples.first.translation, 'البيت كبير.');
    expect(examples.last.sentence, 'Ich mag dieses Haus.');
  });

  test('ignores malformed JSON, non-array values, and invalid entries', () {
    expect(ExampleSentence.parseJson(null), isEmpty);
    expect(ExampleSentence.parseJson(''), isEmpty);
    expect(ExampleSentence.parseJson('{invalid'), isEmpty);
    expect(ExampleSentence.parseJson('{"sentence":"Hallo"}'), isEmpty);

    final examples = ExampleSentence.parseJson(
      '[null,5,{"sentence":"","translation":"فارغ"},'
      '{"sentence":"Guten Tag","translation":null},'
      '{"sentence":"  Hallo!  ","translation":"  مرحباً!  "}]',
    );
    expect(examples, hasLength(1));
    expect(examples.single.sentence, 'Hallo!');
    expect(examples.single.translation, 'مرحباً!');
  });

  testWidgets('empty and unusable examples occupy no layout space',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              ExampleSentencesView(examplesJson: '[]', keyword: 'Haus'),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(ExampleSentencesView)).height, 0);
    expect(find.byIcon(Icons.volume_up_outlined), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              ExampleSentencesView(
                examplesJson: '[{"sentence":"","translation":"فارغ"}]',
                keyword: 'Haus',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(ExampleSentencesView)).height, 0);
    expect(find.byIcon(Icons.volume_up_outlined), findsNothing);
  });

  testWidgets('renders both example sentences and translations',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExampleSentencesView(
            examplesJson: sampleJson,
            keyword: 'Haus',
          ),
        ),
      ),
    );

    expect(find.text('Das Haus ist groß.'), findsOneWidget);
    expect(find.text('Ich mag dieses Haus.'), findsOneWidget);
    expect(find.text('البيت كبير.'), findsOneWidget);
    expect(find.text('أحب هذا البيت.'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_outlined), findsNWidgets(2));
  });

  testWidgets('highlights every case-insensitive keyword occurrence',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExampleSentencesView(
            examplesJson:
                '[{"sentence":"Haus und HAUS.","translation":"منزلان."}]',
            keyword: 'haus',
          ),
        ),
      ),
    );

    final richText = tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.textSpan != null,
      ),
    );
    final spans = (richText.textSpan! as TextSpan).children!.cast<TextSpan>();
    final highlighted = spans
        .where((span) => span.style?.fontWeight == FontWeight.bold)
        .map((span) => span.text)
        .toList();

    expect(highlighted, <String?>['Haus', 'HAUS']);
    expect(richText.textSpan!.toPlainText(), 'Haus und HAUS.');
  });

  testWidgets('keeps source LTR and Arabic translations RTL',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExampleSentencesView(
            examplesJson: sampleJson,
            keyword: 'Haus',
          ),
        ),
      ),
    );

    final source = tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.textSpan != null,
      ).first,
    );
    final translation = tester.widget<Text>(find.text('البيت كبير.'));

    expect(source.textDirection, TextDirection.ltr);
    expect(translation.textDirection, TextDirection.rtl);
  });

  testWidgets('uses LTR translation direction for Latin-script languages',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: ExampleSentencesView(
              examplesJson:
                  '[{"sentence":"Guten Tag!","translation":"Good day!"}]',
              keyword: 'Tag',
              translationLanguageCode: 'en-US',
            ),
          ),
        ),
      ),
    );

    final source = tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.textSpan != null,
      ),
    );
    final translation = tester.widget<Text>(find.text('Good day!'));

    expect(source.textDirection, TextDirection.ltr);
    expect(translation.textDirection, TextDirection.ltr);
  });

  testWidgets('plays only the tapped sentence with its source language',
      (tester) async {
    final tts = _RecordingTtsService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExampleSentencesView(
            examplesJson: sampleJson,
            keyword: 'Haus',
            sourceLanguageCode: 'de-DE',
            ttsService: tts,
          ),
        ),
      ),
    );

    expect(tts.utterances, isEmpty);
    await tester.tap(find.byIcon(Icons.volume_up_outlined).last);
    await tester.pump();
    expect(tts.utterances, <String>['Ich mag dieses Haus.']);
    expect(tts.languageCodes, <String>['de-DE']);

    await tester.tap(find.byIcon(Icons.volume_up_outlined).first);
    await tester.pump();
    expect(tts.utterances, <String>[
      'Ich mag dieses Haus.',
      'Das Haus ist groß.',
    ]);
  });

  testWidgets('hides previous examples when the current entry becomes empty',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExampleSentencesView(
            examplesJson: sampleJson,
            keyword: 'Haus',
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.volume_up_outlined), findsNWidgets(2));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExampleSentencesView(
            examplesJson: null,
            keyword: 'Haus',
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(ExampleSentencesView)).height, 0);
    expect(find.byIcon(Icons.volume_up_outlined), findsNothing);
  });
}
