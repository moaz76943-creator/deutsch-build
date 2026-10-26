import 'package:deutsch_bilarabi/features/explore/data/local_topic_catalog.dart';
import 'package:deutsch_bilarabi/screens/curriculum_units_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final family = LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');

  testWidgets('failed refresh visibly marks retained rows stale until recovery',
      (tester) async {
    var reads = 0;
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: family,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'ar',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async {
          reads++;
          if (reads == 2) throw StateError('offline pack unavailable');
          if (reads == 1) {
            return <Map<String, dynamic>>[
              {'word': 'Mutter', 'translation_ar': 'أم',
               'source_language': 'de', 'target_language': 'ar'},
            ];
          }
          return <Map<String, dynamic>>[
            {'word': 'Mutter', 'translation_ar': 'والدة',
             'source_language': 'de', 'target_language': 'ar'},
            {'word': 'Mother', 'translation_ar': 'أم',
             'source_language': 'en', 'target_language': 'ar'},
          ];
        },
      ),
    ));
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(find.byKey(const Key('topic-stale-warning')), findsNothing);
    expect(find.text('أم'), findsOneWidget);

    await tester.tap(find.byKey(const Key('topic-content-refresh')));
    await tester.pumpAndSettle();
    expect(reads, 2);
    expect(find.byKey(const Key('topic-stale-warning')), findsOneWidget);
    expect(find.textContaining('آخر نسخة'), findsWidgets);
    expect(find.text('أم'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Mutter')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أم')).textDirection,
        TextDirection.rtl);

    await tester.tap(find.byKey(const Key('topic-stale-retry')));
    await tester.pumpAndSettle();
    expect(reads, 3);
    expect(find.byKey(const Key('topic-stale-warning')), findsNothing);
    expect(find.text('والدة'), findsOneWidget);
    expect(find.text('أم'), findsNothing);
    expect(find.text('Mother'), findsNothing);
  });

  testWidgets('changing directed pair clears stale snapshot and its warning',
      (tester) async {
    final target = ValueNotifier<String>('ar');
    addTearDown(target.dispose);
    var reads = 0;
    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<String>(
        valueListenable: target,
        builder: (_, language, __) => TopicWordsScreen(
          section: family,
          cefr: 'A1',
          languageCode: 'de',
          targetLanguageCode: language,
          loadWords: ({
            required String sectionId,
            required String cefr,
            required String languageCode,
          }) async {
            reads++;
            if (reads == 2) throw StateError('offline pack unavailable');
            return <Map<String, dynamic>>[
              {'word': 'Vater', 'translation_ar': 'أب'},
            ];
          },
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('topic-content-refresh')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('topic-stale-warning')), findsOneWidget);

    target.value = 'de';
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('topic-stale-warning')), findsNothing);
    expect(find.text('Vater'), findsNothing);
    expect(find.textContaining('لا تتوفر مفردات موثقة لهذا الاتجاه'), findsOneWidget);
  });

  testWidgets('formatting-only headwords never become phantom cards',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: family,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'ar',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          {'word': '\u200F\u200B', 'translation_ar': 'وهم'},
          {'word': '\u064B\u0640', 'translation_ar': 'وهم آخر'},
          {'word': 'Haus', 'translation_ar': 'بيت'},
          {'word': 'House', 'translation_ar': 'بيت',
           'source_language': 'en', 'target_language': 'ar'},
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('وهم'), findsNothing);
    expect(find.text('وهم آخر'), findsNothing);
    expect(find.text('House'), findsNothing);
    expect(find.text('Haus'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Haus')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('بيت')).textDirection,
        TextDirection.rtl);
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('بطاقة 1 من 1'), findsOneWidget);
    expect(find.text('Haus'), findsOneWidget);
  });

  testWidgets('invisible-only translation cannot act as quiz reference',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: family,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'ar',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          {'word': 'Baum', 'translation_ar': '\u200F\u200B'},
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Baum'), findsOneWidget);
    expect(find.text('لا توجد ترجمة عربية موثقة'), findsOneWidget);
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('study-quiz-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('study-quiz-input')), findsNothing);
    expect(find.textContaining('لا تتوفر إجابة مرجعية'), findsOneWidget);
    expect(find.byKey(const Key('study-quiz-compare')), findsNothing);
  });

  testWidgets('invisible-only forms and examples are not presented as attested',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: family,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'ar',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          {
            'word': 'Haus', 'translation_ar': 'بيت',
            'forms': ['\u200F\u200B', 'Häuser'],
            'examples': ['\u061C', 'Das Haus ist groß.'],
          },
          {
            'word': 'Baum', 'translation_ar': 'شجرة',
            'forms': '\u200F\u200B', 'examples': ['\u061C', '\u064B\u0640'],
          },
          {
            'word': 'House', 'translation_ar': 'بيت',
            'source_language': 'en', 'target_language': 'ar',
            'forms': ['English-only form'],
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('House'), findsNothing);
    await tester.tap(find.text('Haus'));
    await tester.pumpAndSettle();
    expect(find.text('Häuser'), findsOneWidget);
    expect(find.text('Das Haus ist groß.'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Häuser')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('بيت')).textDirection,
        TextDirection.rtl);
    expect(find.text('\u200F\u200B'), findsNothing);
    expect(find.text('\u061C'), findsNothing);
    expect(find.text('English-only form'), findsNothing);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Baum'));
    await tester.pumpAndSettle();
    expect(find.text('لا تتوفر صيغ موثقة في هذا السجل.'), findsOneWidget);
    expect(find.text('لا تتوفر أمثلة موثقة في هذا السجل.'), findsOneWidget);
    expect(find.text('\u200F\u200B'), findsNothing);
    expect(find.text('\u061C'), findsNothing);
    expect(find.text('\u064B\u0640'), findsNothing);
  });

}
