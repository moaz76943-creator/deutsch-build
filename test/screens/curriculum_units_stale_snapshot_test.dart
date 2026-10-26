import 'package:deutsch_bilarabi/features/explore/data/local_topic_catalog.dart';
import 'package:deutsch_bilarabi/screens/curriculum_units_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final family = LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');

  testWidgets('empty refresh keeps last verified pair snapshot until retry',
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
          if (reads == 2) return <Map<String, dynamic>>[];
          return <Map<String, dynamic>>[
            {
              'word': 'Mutter',
              'translation_ar': reads == 1 ? 'أم' : 'والدة',
              'source_language': 'de',
              'target_language': 'ar',
            },
          ];
        },
      ),
    ));
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(find.text('أم'), findsOneWidget);

    await tester.tap(find.byKey(const Key('topic-content-refresh')));
    await tester.pumpAndSettle();
    expect(reads, 2);
    expect(find.byKey(const Key('topic-stale-warning')), findsOneWidget);
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
  });


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
    expect(tester.widget<Text>(find.text('بيت').last).textDirection,
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
    expect(tester.widget<Text>(find.text('بيت').last).textDirection,
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

  testWidgets('canonical pair rows expose attested text and reject reverse data',
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
            'source_text': 'Buch',
            'target_text': 'كتاب',
            'cefr_level': 'A1',
            'pair_identity': {
              'id': 'de->ar', 'source_language': 'de',
              'target_language': 'ar', 'source_direction': 'ltr',
              'target_direction': 'rtl',
            },
            'plural_form': 'Bücher',
            'example_sentence': {
              'source': 'Das Buch ist neu.',
              'target': 'الكتاب جديد.',
            },
          },
          {
            'source_text': 'كتاب', 'target_text': 'Buch',
            'pair_identity': {
              'id': 'ar->de', 'source_language': 'ar',
              'target_language': 'de',
            },
          },
          {
            'source_text': 'Vater', 'target_text': 'أب',
            'pair_identity': {
              'id': 'de->ar', 'source_direction': 'rtl',
            },
          },
          {
            'source_text': 'Mutter', 'target_text': 'أم',
          },
          {
            'word': 'Haus', 'source_text': 'Kind', 'target_text': 'بيت',
            'pair_identity': {'id': 'de->ar'},
          },
          {'word': 'Kind', 'translation_ar': 'طفل'},
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Buch'), findsOneWidget);
    expect(find.text('كتاب'), findsOneWidget);
    expect(find.text('Kind'), findsOneWidget);
    for (final rejected in ['Vater', 'Mutter', 'Haus']) {
      expect(find.text(rejected), findsNothing);
    }
    expect(tester.widget<Text>(find.text('Buch')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('كتاب')).textDirection,
        TextDirection.rtl);

    await tester.tap(find.text('Buch'));
    await tester.pumpAndSettle();
    expect(find.text('Bücher'), findsOneWidget);
    expect(find.text('Das Buch ist neu.'), findsOneWidget);
    expect(find.text('الكتاب جديد.'), findsOneWidget);
    expect(tester.widget<Text>(find.text('الكتاب جديد.')).textDirection,
        TextDirection.rtl);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('topic-search')), 'Bücher');
    await tester.pump();
    expect(find.text('Buch'), findsOneWidget);
    expect(find.text('Kind'), findsNothing);
    await tester.enterText(find.byKey(const Key('topic-search')), 'الكتاب جديد.');
    await tester.pump();
    expect(find.text('Buch'), findsOneWidget);
    await tester.tap(find.byKey(const Key('topic-search-clear')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Buch'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('كتاب'), findsOneWidget);
  });


  testWidgets('flat canonical rows require verified direction and languages',
      (tester) async {
    var reads = 0;
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) async {
      reads++;
      return <Map<String, dynamic>>[
        {
          'source_text': 'Zug', 'target_text': 'قطار',
          'pair_id': 'de->ar', 'source_language': 'de',
          'target_language': 'ar', 'cefr_level': 'A1',
          'forms': <String>['Züge'],
        },
        {
          'source_text': 'Buch', 'target_text': 'كتاب',
          'pair_id': 'de->ar', 'source_language_code': 'de',
          'target_language_code': 'ar',
        },
        {
          'source_text': 'كتاب', 'target_text': 'Buch',
          'pair_id': 'ar->de', 'source_language': 'ar',
          'target_language': 'de',
        },
        {
          'source_text': 'Kind', 'target_text': 'طفل',
          'pair_id': 'de->ar', 'source_language': 'de',
        },
        {
          'source_text': 'Haus', 'target_text': 'بيت',
          'pair_id': 'de->ar', 'source_language': 'de',
          'target_language': 'ar', 'pair_identity': {'id': 'ar->de'},
        },
        {'word': 'Mutter', 'translation_ar': 'أم'},
      ];
    }

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: family, cefr: 'A1', languageCode: 'de',
        targetLanguageCode: 'ar', loadWords: loader,
      ),
    ));
    await tester.pumpAndSettle();
    expect(reads, 1);
    for (final accepted in ['Zug', 'Buch', 'Mutter']) {
      expect(find.text(accepted), findsOneWidget);
    }
    for (final rejected in ['Kind', 'Haus', 'طفل', 'بيت']) {
      expect(find.text(rejected), findsNothing);
    }
    expect(tester.widget<Text>(find.text('Zug')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('قطار')).textDirection,
        TextDirection.rtl);
    await tester.tap(find.text('Zug'));
    await tester.pumpAndSettle();
    expect(find.text('Züge'), findsOneWidget);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('topic-search')), 'Züge');
    await tester.pump();
    expect(find.text('Zug'), findsOneWidget);
    expect(find.text('Buch'), findsNothing);
    await tester.tap(find.byKey(const Key('topic-search-clear')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pump();
    expect(find.text('بطاقة 1 من 3'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: family, cefr: 'A1', languageCode: 'ar',
        targetLanguageCode: 'de', loadWords: loader,
      ),
    ));
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(find.text('Zug'), findsNothing);
    expect(find.textContaining('لا تتوفر مفردات موثقة لهذا الاتجاه'), findsOneWidget);
  });

  testWidgets('invalid refresh keeps last verified rows until a clean read',
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
          if (reads == 1) {
            return <Map<String, dynamic>>[
              {'word': 'Mutter', 'translation_ar': 'أم',
               'source_language': 'de', 'target_language': 'ar'},
            ];
          }
          if (reads == 2) {
            return <Map<String, dynamic>>[
              {'word': 'Mother', 'translation_ar': 'أم',
               'source_language': 'en', 'target_language': 'ar'},
              {'word': 'Vater', 'translation_ar': 'أب',
               'source_language': 'de', 'target_language': 'en'},
            ];
          }
          return <Map<String, dynamic>>[
            {'word': 'Vater', 'translation_ar': 'أب',
             'source_language': 'de', 'target_language': 'ar'},
          ];
        },
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Mutter'), findsOneWidget);

    await tester.tap(find.byKey(const Key('topic-content-refresh')));
    await tester.pumpAndSettle();
    expect(reads, 2);
    expect(find.byKey(const Key('topic-stale-warning')), findsOneWidget);
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('Mother'), findsNothing);
    expect(find.text('Vater'), findsNothing);
    expect(tester.widget<Text>(find.text('Mutter')).textDirection,
        TextDirection.ltr);

    await tester.tap(find.byKey(const Key('topic-stale-retry')));
    await tester.pumpAndSettle();
    expect(reads, 3);
    expect(find.byKey(const Key('topic-stale-warning')), findsNothing);
    expect(find.text('Mutter'), findsNothing);
    expect(find.text('Vater'), findsOneWidget);
    expect(tester.widget<Text>(find.text('أب').last).textDirection,
        TextDirection.rtl);
  });

  testWidgets('first read with only foreign-pair rows is retryable, not empty',
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
          if (reads == 1) {
            return <Map<String, dynamic>>[
              {'word': 'Mother', 'translation_ar': 'أم',
               'source_language': 'en', 'target_language': 'ar'},
            ];
          }
          return <Map<String, dynamic>>[
            {'word': 'Mutter', 'translation_ar': 'أم',
             'source_language': 'de', 'target_language': 'ar'},
          ];
        },
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Mother'), findsNothing);
    expect(find.textContaining('تعذر قراءة المحتوى المحلي'), findsOneWidget);
    expect(find.byKey(const Key('topic-empty-refresh')), findsNothing);
    expect(find.byKey(const Key('topic-stale-warning')), findsNothing);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(reads, 2);
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('Mother'), findsNothing);
    expect(tester.widget<Text>(find.text('أم').last).textDirection,
        TextDirection.rtl);
  });

  testWidgets('canonical examples and plural survive empty adapter placeholders',
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
            'source_text': 'Buch',
            'target_text': 'كتاب',
            'pair_identity': {
              'id': 'de->ar',
              'source_language': 'de',
              'target_language': 'ar',
              'source_direction': 'ltr',
              'target_direction': 'rtl',
            },
            'forms': <String>[],
            'plural_form': 'Bücher',
            'examples': <String>[],
            'example_sentence': {
              'source': 'Das Buch ist neu.',
              'target': 'الكتاب جديد.',
            },
          },
          {
            'source_text': 'كتاب',
            'target_text': 'Buch',
            'pair_identity': {'id': 'ar->de'},
            'plural_form': 'كتب',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Buch'), findsOneWidget);
    expect(find.text('كتب'), findsNothing);
    expect(tester.widget<Text>(find.text('Buch')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('كتاب')).textDirection,
        TextDirection.rtl);

    await tester.tap(find.text('Buch'));
    await tester.pumpAndSettle();
    expect(find.text('Bücher'), findsOneWidget);
    expect(find.text('Das Buch ist neu.'), findsOneWidget);
    expect(find.text('الكتاب جديد.'), findsOneWidget);
    expect(tester.widget<Text>(find.text('الكتاب جديد.')).textDirection,
        TextDirection.rtl);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('topic-search')), 'Bücher');
    await tester.pump();
    expect(find.text('Buch'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('topic-search')), 'الكتاب جديد.');
    await tester.pump();
    expect(find.text('Buch'), findsOneWidget);
    await tester.tap(find.byKey(const Key('topic-search-clear')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('study-source')), findsOneWidget);
  });

  testWidgets('formatting-only adapter arrays do not hide canonical evidence',
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
            'source_text': 'Haus',
            'target_text': 'بيت',
            'pair_identity': {'id': 'de->ar'},
            'forms': <String>['\u200e', '\u061c'],
            'plural_form': 'Häuser',
            'examples': <String>['\u200f'],
            'example_sentence': {
              'source': 'Das Haus ist groß.',
              'target': 'البيت كبير.',
            },
          },
          {
            'source_text': 'بيت',
            'target_text': 'Haus',
            'pair_identity': {'id': 'ar->de'},
            'plural_form': 'بيوت',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Haus'), findsOneWidget);
    expect(find.text('بيوت'), findsNothing);
    expect(tester.widget<Text>(find.text('Haus')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('بيت')).textDirection,
        TextDirection.rtl);
    await tester.tap(find.text('Haus'));
    await tester.pumpAndSettle();
    expect(find.text('Häuser'), findsOneWidget);
    expect(find.text('Das Haus ist groß.'), findsOneWidget);
    expect(find.text('البيت كبير.'), findsOneWidget);
    expect(tester.widget<Text>(find.text('البيت كبير.')).textDirection,
        TextDirection.rtl);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('topic-search')), 'Häuser');
    await tester.pump();
    expect(find.text('Haus'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('topic-search')), 'البيت كبير.');
    await tester.pump();
    expect(find.text('Haus'), findsOneWidget);
  });


  testWidgets('card changes and async content states announce to assistive tech',
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
          if (reads > 1) throw StateError('temporary offline read failure');
          return <Map<String, dynamic>>[
            {'word': 'Mutter', 'translation_ar': 'أم',
             'source_language': 'de', 'target_language': 'ar'},
            {'word': 'Vater', 'translation_ar': 'أب',
             'source_language': 'de', 'target_language': 'ar'},
            {'word': 'Mother', 'translation_ar': 'أم',
             'source_language': 'en', 'target_language': 'ar'},
          ];
        },
      ),
    ));
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(find.text('Mother'), findsNothing);
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();

    final card = find.byKey(const Key('study-card-announcement'));
    expect(card, findsOneWidget);
    var semantics = tester.widget<Semantics>(card);
    expect(semantics.properties.liveRegion, isTrue);
    expect(semantics.excludeSemantics, isTrue);
    expect(semantics.properties.label, contains('بطاقة 1 من 2: Mutter'));
    expect(tester.widget<Text>(find.byKey(const Key('study-source')))
        .textDirection, TextDirection.ltr);

    await tester.ensureVisible(find.byKey(const Key('study-next')));
    await tester.tap(find.byKey(const Key('study-next')));
    await tester.pumpAndSettle();
    semantics = tester.widget<Semantics>(card);
    expect(semantics.properties.label, contains('بطاقة 2 من 2: Vater'));
    expect(find.text('Mother'), findsNothing);

    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.text('أم')).textDirection,
        TextDirection.rtl);
    await tester.enterText(find.byKey(const Key('topic-search')), 'no-match');
    await tester.pumpAndSettle();
    final noResults = tester.widget<Semantics>(
        find.byKey(const Key('topic-no-results-announcement')));
    expect(noResults.properties.liveRegion, isTrue);
    await tester.tap(find.byKey(const Key('topic-search-clear')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('topic-content-refresh')));
    await tester.pumpAndSettle();
    expect(reads, 2);
    final stale = tester.widget<Semantics>(
        find.byKey(const Key('topic-stale-announcement')));
    expect(stale.properties.liveRegion, isTrue);
    expect(find.text('Mutter'), findsOneWidget);
  });


  testWidgets('default-ignorable format controls never create lexical evidence',
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
            'word': '\u200C\u200D\u2060\u00AD\uFE0F',
            'translation_ar': 'وهم',
          },
          {
            'word': 'Baum',
            'translation_ar': '\u200D\u2060\uFE0F',
            'forms': ['\u200C\u00AD', 'Bäume'],
            'examples': ['\u034F\u2060', 'Der Baum ist hoch.'],
          },
          {'word': 'Haus', 'translation_ar': 'بيت'},
        ],
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('وهم'), findsNothing);
    expect(find.text('Baum'), findsOneWidget);
    expect(find.text('Haus'), findsOneWidget);
    expect(find.text('لا توجد ترجمة عربية موثقة'), findsOneWidget);
    await tester.tap(find.text('Baum'));
    await tester.pumpAndSettle();
    expect(find.text('Bäume'), findsOneWidget);
    expect(find.text('Der Baum ist hoch.'), findsOneWidget);
    expect(find.text('\u200C\u00AD'), findsNothing);
    expect(find.text('\u034F\u2060'), findsNothing);
    expect(tester.widget<Text>(find.text('Bäume')).textDirection,
        TextDirection.ltr);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('بطاقة 1 من 2'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-quiz-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('study-quiz-input')), findsNothing);
    expect(find.textContaining('لا تتوفر إجابة مرجعية'), findsOneWidget);
    expect(find.byKey(const Key('study-quiz-compare')), findsNothing);
  });
}
