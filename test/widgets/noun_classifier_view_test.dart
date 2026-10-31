import 'package:deutsch_bilarabi/widgets/noun_classifier_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget classifierTestApp({
  required String noun,
  required String languageCode,
  required String partOfSpeech,
  required String classifier,
  String reading = '',
  String explanation = '',
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: NounClassifierView(
          noun: noun,
          languageCode: languageCode,
          partOfSpeech: partOfSpeech,
          classifier: classifier,
          reading: reading,
          explanation: explanation,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders a Chinese measure word beside its noun', (tester) async {
    await tester.pumpWidget(classifierTestApp(
      noun: '纸',
      languageCode: 'zh-Hans-CN',
      partOfSpeech: 'NOUN',
      classifier: '张',
      reading: 'zhāng',
      explanation: 'Used for flat objects such as sheets of paper.',
    ));

    expect(find.text('纸'), findsOneWidget);
    expect(find.text('Measure word: 张'), findsOneWidget);
    expect(find.byKey(const Key('nounClassifierBadge')), findsOneWidget);
  });

  testWidgets('reveals reading and explanation on badge tap', (tester) async {
    await tester.pumpWidget(classifierTestApp(
      noun: '纸',
      languageCode: 'zh',
      partOfSpeech: 'noun',
      classifier: '张',
      reading: 'zhāng',
      explanation: 'Used for flat objects such as sheets of paper.',
    ));

    await tester.tap(find.byKey(const Key('nounClassifierBadge')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Reading: zhāng'), findsOneWidget);
    expect(find.text('Used for flat objects such as sheets of paper.'),
        findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('supports Japanese, Vietnamese, Thai and Korean counters',
      (tester) async {
    const examples = <String, String>{
      'ja-JP': '枚',
      'vi-VN': 'tờ',
      'th-TH': 'แผ่น',
      'ko-KR': '장',
    };

    for (final entry in examples.entries) {
      await tester.pumpWidget(classifierTestApp(
        noun: 'paper',
        languageCode: entry.key,
        partOfSpeech: 'n.',
        classifier: entry.value,
      ));

      expect(find.text('Measure word: ${entry.value}'), findsOneWidget);
    }
  });

  testWidgets('labels Bantu noun classes distinctly from measure words',
      (tester) async {
    await tester.pumpWidget(classifierTestApp(
      noun: 'mtu',
      languageCode: 'sw-TZ',
      partOfSpeech: 'noun',
      classifier: 'm-/wa-',
      reading: 'm / wa',
      explanation: 'The noun class controls agreement.',
    ));

    expect(find.text('mtu'), findsOneWidget);
    expect(find.text('Noun class: m-/wa-'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nounClassifierBadge')));
    await tester.pumpAndSettle();
    expect(find.text('Reading: m / wa'), findsOneWidget);
    expect(find.text('The noun class controls agreement.'), findsOneWidget);
  });

  testWidgets('accepts other supported Bantu locales', (tester) async {
    await tester.pumpWidget(classifierTestApp(
      noun: 'umuntu',
      languageCode: 'zu_ZA',
      partOfSpeech: 'noun',
      classifier: 'umu-/aba-',
    ));

    expect(find.text('Noun class: umu-/aba-'), findsOneWidget);
  });

  testWidgets('omits the whole view for unsupported languages', (tester) async {
    await tester.pumpWidget(classifierTestApp(
      noun: 'Papier',
      languageCode: 'de-DE',
      partOfSpeech: 'noun',
      classifier: '张',
    ));

    expect(find.byType(ActionChip), findsNothing);
    expect(find.text('Papier'), findsNothing);
  });

  testWidgets('omits the view for non-nouns', (tester) async {
    await tester.pumpWidget(classifierTestApp(
      noun: '走',
      languageCode: 'zh',
      partOfSpeech: 'verb',
      classifier: '张',
    ));

    expect(find.byType(ActionChip), findsNothing);
    expect(find.text('走'), findsNothing);
  });

  testWidgets('omits the view when classifier or noun is absent',
      (tester) async {
    await tester.pumpWidget(classifierTestApp(
      noun: '纸',
      languageCode: 'zh',
      partOfSpeech: 'noun',
      classifier: '  ',
    ));
    expect(find.byType(ActionChip), findsNothing);

    await tester.pumpWidget(classifierTestApp(
      noun: ' ',
      languageCode: 'zh',
      partOfSpeech: 'noun',
      classifier: '张',
    ));
    expect(find.byType(ActionChip), findsNothing);
  });

  testWidgets('does not fabricate absent reading or explanation',
      (tester) async {
    await tester.pumpWidget(classifierTestApp(
      noun: '紙',
      languageCode: 'ja',
      partOfSpeech: 'noun',
      classifier: '枚',
    ));

    await tester.tap(find.byKey(const Key('nounClassifierBadge')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Reading:'), findsNothing);
  });
}
