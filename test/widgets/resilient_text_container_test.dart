import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/widgets/resilient_text_container.dart';
import 'package:deutsch_bilarabi/screens/word_deep_dive_sheet.dart';

void main() {
  test('long Latin compounds gain discretionary, non-destructive breaks', () {
    const input = 'Donaudampfschifffahrtsgesellschaftskapitän';
    final result = ResilientTextContainer.wrapCompounds(input);
    expect(result, contains('\u00AD'));
    expect(result.replaceAll('\u00AD', ''), input);
    expect(ResilientTextContainer.wrapCompounds('العربية 你好'), 'العربية 你好');
  });

  testWidgets('long compounds do not overflow at 320 and 360 logical pixels',
      (tester) async {
    for (final width in <double>[320, 360]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: const Row(
                children: <Widget>[
                  Icon(Icons.text_fields),
                  Expanded(
                    child: ResilientTextContainer(
                      text: 'Donaudampfschifffahrtsgesellschaftskapitän'
                          'Donaudampfschifffahrtsgesellschaftskapitän',
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('null or empty optional metadata keeps deep-dive stable',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WordDeepDiveSheet(
          wordData: <String, dynamic>{
            'surface': 'Donaudampfschifffahrtsgesellschaftskapitän',
            'article': null,
            'translation_ar': null,
            'ipa': null,
            'part_of_speech': null,
            'fields': <String, dynamic>{
              'examples': null,
              'classifier': null,
              'measure_word': null,
              'idioms': null,
            },
          },
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(ResilientTextContainer), findsWidgets);
    expect(find.textContaining('المعنى غير متوفر'), findsOneWidget);
  });
}
