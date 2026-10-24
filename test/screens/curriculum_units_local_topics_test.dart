import 'dart:async';

import 'package:deutsch_bilarabi/features/explore/data/local_topic_catalog.dart';
import 'package:deutsch_bilarabi/screens/curriculum_units_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('family topic opens real local rows without fabricated progress',
      (tester) async {
    String? selectedSection;
    String? selectedLevel;
    String? selectedLanguage;

    await tester.pumpWidget(MaterialApp(
      home: CurriculumUnitsScreen(
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async {
          selectedSection = sectionId;
          selectedLevel = cefr;
          selectedLanguage = languageCode;
          return <Map<String, dynamic>>[
            <String, dynamic>{
              'word': 'Mutter',
              'article': 'die',
              'translation_ar': 'أم',
              'cefr_level': 'A1',
            },
          ];
        },
      ),
    ));

    expect(find.textContaining('العائلة والأسرة'), findsOneWidget);
    expect(find.textContaining('75%'), findsNothing);
    expect(find.textContaining('28 مفردة'), findsNothing);

    await tester.tap(find.textContaining('العائلة والأسرة'));
    await tester.pumpAndSettle();

    expect(selectedSection, 'FAMILY');
    expect(selectedLevel, 'A1');
    expect(selectedLanguage, 'de');
    expect(find.text('die Mutter'), findsOneWidget);
    expect(find.text('أم'), findsOneWidget);
    expect(find.text('A1'), findsWidgets);
    expect(
      tester.widget<Text>(find.text('die Mutter')).textDirection,
      TextDirection.ltr,
    );
    expect(
      tester.widget<Text>(find.text('أم')).textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('selected CEFR is forwarded without inventing level membership',
      (tester) async {
    String? receivedLevel;
    await tester.pumpWidget(MaterialApp(
      home: CurriculumUnitsScreen(
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async {
          receivedLevel = cefr;
          return <Map<String, dynamic>>[];
        },
      ),
    ));

    await tester.tap(find.byKey(const Key('cefr-B2')));
    await tester.pump();
    await tester.tap(find.textContaining('العائلة والأسرة'));
    await tester.pumpAndSettle();

    expect(receivedLevel, 'B2');
    expect(find.textContaining('لا توجد مفردات موثقة'), findsOneWidget);
    expect(find.text('Mutter'), findsNothing);
  });

  testWidgets('unverified language does not show German topics', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CurriculumUnitsScreen(languageCode: 'fr'),
    ));

    expect(find.textContaining('لا تتوفر أقسام محلية موثقة'), findsOneWidget);
    expect(find.textContaining('العائلة والأسرة'), findsNothing);
  });

  testWidgets('pack read failure has a retry path and no false content',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      home: CurriculumUnitsScreen(
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async {
          calls++;
          if (calls == 1) throw StateError('missing pack');
          return <Map<String, dynamic>>[
            <String, dynamic>{
              'word': 'Haus',
              'translation_ar': 'منزل',
              'cefr_level': 'A1',
            },
          ];
        },
      ),
    ));

    await tester.tap(find.textContaining('المنزل والحياة اليومية'));
    await tester.pumpAndSettle();

    expect(find.textContaining('تعذر قراءة المحتوى المحلي'), findsOneWidget);
    expect(find.text('Haus'), findsNothing);

    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Haus'), findsOneWidget);
    expect(find.text('منزل'), findsOneWidget);
  });
  testWidgets('unsupported target and reverse direction never query German content',
      (tester) async {
    var calls = 0;
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) async {
      calls++;
      return <Map<String, dynamic>>[
        <String, dynamic>{'word': 'Mutter', 'translation_ar': 'أم'},
      ];
    }

    await tester.pumpWidget(MaterialApp(
      home: CurriculumUnitsScreen(
        languageCode: 'de',
        targetLanguageCode: 'en',
        loadWords: loader,
      ),
    ));
    expect(find.textContaining('لا تتوفر أقسام محلية موثقة'), findsOneWidget);
    expect(find.textContaining('العائلة والأسرة'), findsNothing);

    await tester.pumpWidget(MaterialApp(
      home: CurriculumUnitsScreen(
        languageCode: 'ar',
        targetLanguageCode: 'de',
        loadWords: loader,
      ),
    ));
    expect(find.textContaining('لا تتوفر أقسام محلية موثقة'), findsOneWidget);
    expect(find.textContaining('العائلة والأسرة'), findsNothing);
    expect(calls, 0);
  });

  testWidgets('pair switch discards an in-flight German topic response',
      (tester) async {
    final pending = Completer<List<Map<String, dynamic>>>();
    var calls = 0;
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) {
      calls++;
      return pending.future;
    }
    final section = LocalTopicCatalog.sections[1];

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'ar',
        loadWords: loader,
      ),
    ));
    expect(calls, 1);

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'en',
        loadWords: loader,
      ),
    ));
    expect(find.textContaining('لا تتوفر مفردات موثقة لهذا الاتجاه'),
        findsOneWidget);
    expect(calls, 1);

    pending.complete(<Map<String, dynamic>>[
      <String, dynamic>{'word': 'Mutter', 'translation_ar': 'أم'},
    ]);
    await tester.pump();
    expect(find.text('Mutter'), findsNothing);
    expect(find.text('أم'), findsNothing);
  });

  testWidgets('level switch keeps latest rows when older request finishes last',
      (tester) async {
    final first = Completer<List<Map<String, dynamic>>>();
    final section = LocalTopicCatalog.sections[1];
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) {
      if (cefr == 'A1') return first.future;
      return Future.value(<Map<String, dynamic>>[
        <String, dynamic>{
          'word': 'Verwandtschaft',
          'translation_ar': 'قرابة',
          'cefr_level': 'B2',
        },
      ]);
    }

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        loadWords: loader,
      ),
    ));
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'B2',
        languageCode: 'de',
        loadWords: loader,
      ),
    ));
    await tester.pump();
    expect(find.text('Verwandtschaft'), findsOneWidget);

    first.complete(<Map<String, dynamic>>[
      <String, dynamic>{'word': 'Mutter', 'translation_ar': 'أم'},
    ]);
    await tester.pump();
    expect(find.text('Verwandtschaft'), findsOneWidget);
    expect(find.text('Mutter'), findsNothing);
  });


  testWidgets('local topic search matches German and unvowelled Arabic only',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY'),
        cefr: 'A1',
        languageCode: 'de',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          <String, dynamic>{'word': 'Mutter', 'article': 'die', 'translation_ar': 'أُمّ'},
          <String, dynamic>{'word': 'Vater', 'article': 'der', 'translation_ar': 'أب'},
        ],
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('topic-search')), 'vAt');
    await tester.pump();
    expect(find.text('der Vater'), findsOneWidget);
    expect(find.text('die Mutter'), findsNothing);

    await tester.enterText(find.byKey(const Key('topic-search')), 'أم');
    await tester.pump();
    expect(find.text('die Mutter'), findsOneWidget);
    expect(find.text('der Vater'), findsNothing);
    expect(tester.widget<Text>(find.text('أُمّ')).textDirection,
        TextDirection.rtl);
  });

  testWidgets('search supports sharp-s spelling and honest no-match state',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: LocalTopicCatalog.sections.firstWhere((s) => s.id == 'TRANSPORT'),
        cefr: 'A1',
        languageCode: 'de',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          <String, dynamic>{'word': 'Straße', 'translation_ar': 'شارع'},
          <String, dynamic>{'word': 'Bus', 'translation_ar': 'حافلة'},
        ],
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('topic-search')), 'strasse');
    await tester.pump();
    expect(find.text('Straße'), findsOneWidget);
    expect(find.text('Bus'), findsNothing);

    await tester.enterText(find.byKey(const Key('topic-search')), 'not-in-pack');
    await tester.pump();
    expect(find.textContaining('لا توجد نتائج مطابقة'), findsOneWidget);
    expect(find.text('Straße'), findsNothing);

    await tester.enterText(find.byKey(const Key('topic-search')), '');
    await tester.pump();
    expect(find.text('Straße'), findsOneWidget);
    expect(find.text('Bus'), findsOneWidget);
  });


  testWidgets('changing level clears previous topic search before showing rows',
      (tester) async {
    final section = LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) async => <Map<String, dynamic>>[
      <String, dynamic>{
        'word': cefr == 'A1' ? 'Mutter' : 'Verwandtschaft',
        'translation_ar': cefr == 'A1' ? 'أم' : 'قرابة',
      },
    ];

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        loadWords: loader,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('topic-search')), 'Mutter');
    await tester.pump();
    expect(find.text('Mutter'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'B2',
        languageCode: 'de',
        loadWords: loader,
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const Key('topic-search')))
        .controller!.text, isEmpty);
    expect(find.text('Verwandtschaft'), findsOneWidget);
    expect(find.textContaining('لا توجد نتائج مطابقة'), findsNothing);
  });


  testWidgets('German umlaut digraphs and decomposed spellings find local rows',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: LocalTopicCatalog.sections.firstWhere((s) => s.id == 'HOME_KITCHEN'),
        cefr: 'A1',
        languageCode: 'de',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          <String, dynamic>{'word': 'Käse', 'translation_ar': 'جبن'},
          <String, dynamic>{'word': 'Brot', 'translation_ar': 'خبز'},
        ],
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('topic-search')), 'KAESE');
    await tester.pump();
    expect(find.text('Käse'), findsOneWidget);
    expect(find.text('Brot'), findsNothing);

    await tester.enterText(find.byKey(const Key('topic-search')), 'Ka\u0308se');
    await tester.pump();
    expect(find.text('Käse'), findsOneWidget);
    expect(find.text('Brot'), findsNothing);
  });

  testWidgets('search text direction follows Arabic versus German input',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: LocalTopicCatalog.sections.firstWhere((s) => s.id == 'HOME_LIVING'),
        cefr: 'A1',
        languageCode: 'de',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          <String, dynamic>{'word': 'Haus', 'translation_ar': 'بيت'},
        ],
      ),
    ));
    await tester.pumpAndSettle();
    final search = find.byKey(const Key('topic-search'));
    expect(tester.widget<TextField>(search).textDirection, TextDirection.ltr);

    await tester.enterText(search, 'Haus');
    await tester.pump();
    expect(tester.widget<TextField>(search).textDirection, TextDirection.ltr);
    expect(find.text('Haus'), findsOneWidget);

    await tester.enterText(search, 'بيت');
    await tester.pump();
    expect(tester.widget<TextField>(search).textDirection, TextDirection.rtl);
    expect(find.text('بيت'), findsOneWidget);
  });

  testWidgets('practice cards reveal only loaded translation and reset on next',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY'),
        cefr: 'A1',
        languageCode: 'de',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          <String, dynamic>{
            'word': 'Mutter',
            'article': 'die',
            'translation_ar': 'أم',
          },
          <String, dynamic>{
            'word': 'Vater',
            'article': 'der',
            'translation_ar': 'أب',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pump();
    expect(find.text('die Mutter'), findsOneWidget);
    expect(find.text('أم'), findsNothing);
    expect(find.textContaining('لا يُحفظ التقدم'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('study-source')))
        .textDirection, TextDirection.ltr);

    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('أم'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('study-answer')))
        .textDirection, TextDirection.rtl);

    await tester.tap(find.byKey(const Key('study-next')));
    await tester.pump();
    expect(find.text('der Vater'), findsOneWidget);
    expect(find.text('أم'), findsNothing);
    expect(find.text('أب'), findsNothing);
    expect(find.byKey(const Key('study-reveal')), findsOneWidget);
  });

  testWidgets('practice cards reset revealed answer when search changes',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY'),
        cefr: 'A1',
        languageCode: 'de',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          <String, dynamic>{'word': 'Mutter', 'translation_ar': 'أم'},
          <String, dynamic>{'word': 'Vater', 'translation_ar': 'أب'},
        ],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('أم'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('topic-search')), 'Vater');
    await tester.pump();
    expect(find.text('Vater'), findsOneWidget);
    expect(find.text('أم'), findsNothing);
    expect(find.text('أب'), findsNothing);
    expect(find.text('بطاقة 1 من 1'), findsOneWidget);
    expect(find.byKey(const Key('study-reveal')), findsOneWidget);
  });

  testWidgets('pair switch removes revealed card and blocks stale content',
      (tester) async {
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) async => <Map<String, dynamic>>[
      <String, dynamic>{'word': 'Mutter', 'translation_ar': 'أم'},
    ];
    final section = LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'ar',
        loadWords: loader,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('أم'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'en',
        loadWords: loader,
      ),
    ));
    await tester.pump();
    expect(find.textContaining('لا تتوفر مفردات موثقة لهذا الاتجاه'),
        findsOneWidget);
    expect(find.text('Mutter'), findsNothing);
    expect(find.text('أم'), findsNothing);
    expect(find.byKey(const Key('topic-study-toggle')), findsNothing);
  });

  testWidgets('missing translation is disclosed only after card reveal',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY'),
        cefr: 'A1',
        languageCode: 'de',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          <String, dynamic>{'word': 'Mutter'},
        ],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pump();
    expect(find.textContaining('لا توجد ترجمة عربية موثقة لهذا السجل'),
        findsNothing);
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.textContaining('لا توجد ترجمة عربية موثقة لهذا السجل'),
        findsOneWidget);
  });
}
