import 'dart:async';

import 'package:deutsch_bilarabi/features/explore/data/local_topic_catalog.dart';
import 'package:deutsch_bilarabi/screens/curriculum_units_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('future loaders cannot overrun the 50-card local UI bound',
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
        }) async => List<Map<String, dynamic>>.generate(
          60,
          (i) => <String, dynamic>{
            'word': 'Item$i',
            'translation_ar': 'ترجمة',
            'cefr_level': 'A1',
          },
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pump();
    expect(find.text('بطاقة 1 من 50'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('topic-search')), 'Item59');
    await tester.pump();
    expect(find.textContaining('لا توجد نتائج مطابقة'), findsOneWidget);
  });
  testWidgets('switching target while details are open removes stale translation',
      (tester) async {
    final section = LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) async => <Map<String, dynamic>>[
      <String, dynamic>{
        'word': 'Mutter',
        'translation_ar': 'أم',
        'forms': <String>['Mütter'],
      },
    ];

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
    await tester.tap(find.text('Mutter'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المفردة'), findsOneWidget);
    expect(find.text('Mütter'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'en',
        loadWords: loader,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المفردة'), findsNothing);
    expect(find.text('Mütter'), findsNothing);
    expect(find.text('أم'), findsNothing);
    expect(find.textContaining('لا تتوفر مفردات موثقة لهذا الاتجاه'),
        findsOneWidget);
  });

  testWidgets('switching level closes old detail route and loads new level',
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
        'cefr_level': cefr,
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
    await tester.tap(find.text('Mutter'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المفردة'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'B2',
        languageCode: 'de',
        loadWords: loader,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المفردة'), findsNothing);
    expect(find.text('Mutter'), findsNothing);
    expect(find.text('Verwandtschaft'), findsOneWidget);
    expect(find.text('قرابة'), findsOneWidget);
  });

  testWidgets('topic search finds verified inflections, senses and examples',
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
            'translation_ar': 'أم',
            'sense_gloss': 'والدة الطفل',
            'forms': <String>['Mütter'],
            'examples': <String>['Die Mutter liest.'],
          },
          <String, dynamic>{'word': 'Vater', 'translation_ar': 'أب'},
        ],
      ),
    ));
    await tester.pumpAndSettle();
    final search = find.byKey(const Key('topic-search'));

    await tester.enterText(search, 'Muetter');
    await tester.pump();
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('Vater'), findsNothing);

    await tester.enterText(search, 'والدة');
    await tester.pump();
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('Vater'), findsNothing);

    await tester.enterText(search, 'liest');
    await tester.pump();
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('Vater'), findsNothing);
  });

  testWidgets('malformed optional search metadata never becomes a match',
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
            'translation_ar': 'أم',
            'sense_gloss': <String, String>{'gloss': 'ghostneedle'},
            'forms': <Object>[42, <String, String>{'form': 'ghostneedle'}],
            'examples': 'ghostneedle',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    final search = find.byKey(const Key('topic-search'));

    await tester.enterText(search, 'ghostneedle');
    await tester.pump();
    expect(find.textContaining('لا توجد نتائج مطابقة'), findsOneWidget);
    expect(find.text('Mutter'), findsNothing);

    await tester.enterText(search, 'Mutter');
    await tester.pump();
    expect(find.text('Mutter'), findsOneWidget);
  });

  testWidgets('stalled topic load shows retry and never resurrects late rows',
      (tester) async {
    final stalled = Completer<List<Map<String, dynamic>>>();
    var calls = 0;
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) {
      calls++;
      if (calls == 1) return stalled.future;
      return Future.value(<Map<String, dynamic>>[
        <String, dynamic>{
          'word': 'Vater',
          'translation_ar': 'أب',
          'cefr_level': 'A1',
        },
      ]);
    }

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY'),
        cefr: 'A1',
        languageCode: 'de',
        loadWords: loader,
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 31));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('تعذر قراءة المحتوى المحلي'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);

    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Vater'), findsOneWidget);
    expect(find.text('أب'), findsOneWidget);

    stalled.complete(<Map<String, dynamic>>[
      <String, dynamic>{
        'word': 'Mutter',
        'translation_ar': 'أم',
        'cefr_level': 'A1',
      },
    ]);
    await tester.pump();
    expect(find.text('Vater'), findsOneWidget);
    expect(find.text('Mutter'), findsNothing);
  });

  testWidgets('timeout of obsolete request cannot replace unsupported pair state',
      (tester) async {
    final stalled = Completer<List<Map<String, dynamic>>>();
    var calls = 0;
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) {
      calls++;
      return stalled.future;
    }
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
    await tester.pump(const Duration(seconds: 31));
    await tester.pump();
    expect(find.textContaining('لا تتوفر مفردات موثقة لهذا الاتجاه'),
        findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    stalled.complete(<Map<String, dynamic>>[
      <String, dynamic>{'word': 'Mutter', 'translation_ar': 'أم'},
    ]);
    await tester.pump();
    expect(find.text('Mutter'), findsNothing);
    expect(calls, 1);
  });


  testWidgets('explicit foreign section rows never enter list search or cards',
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
            'section_id': 'HOME_LIVING',
            'word': 'Haus',
            'translation_ar': 'منزل',
            'cefr_level': 'A1',
          },
          <String, dynamic>{
            'section_id': 'FAMILY',
            'word': 'Mutter',
            'translation_ar': 'أم',
            'cefr_level': 'A1',
          },
          <String, dynamic>{
            // Legacy bundled de->ar rows have no section_id.
            'word': 'Bruder',
            'translation_ar': 'أخ',
            'cefr_level': 'A1',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Haus'), findsNothing);
    expect(find.text('منزل'), findsNothing);
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('Bruder'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Mutter')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أم')).textDirection,
        TextDirection.rtl);

    await tester.enterText(find.byKey(const Key('topic-search')), 'Haus');
    await tester.pump();
    expect(find.textContaining('لا توجد نتائج مطابقة'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('topic-search')), '');
    await tester.pump();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pump();
    expect(find.text('Mutter'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-next')));
    await tester.pump();
    expect(find.text('Bruder'), findsOneWidget);
    expect(find.text('Haus'), findsNothing);
  });

  testWidgets('switching topic ignores late rows from the prior section',
      (tester) async {
    final pending = Completer<List<Map<String, dynamic>>>();
    final family = LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');
    final home = LocalTopicCatalog.sections.firstWhere((s) => s.id == 'HOME_LIVING');
    var calls = 0;
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) {
      calls++;
      if (sectionId == 'FAMILY') return pending.future;
      return Future.value(<Map<String, dynamic>>[
        <String, dynamic>{
          'section_id': 'HOME_LIVING',
          'word': 'Haus',
          'translation_ar': 'منزل',
          'cefr_level': 'A1',
        },
      ]);
    }

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: family,
        cefr: 'A1',
        languageCode: 'de',
        loadWords: loader,
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: home,
        cefr: 'A1',
        languageCode: 'de',
        loadWords: loader,
      ),
    ));
    await tester.pump();
    expect(find.text('Haus'), findsOneWidget);
    pending.complete(<Map<String, dynamic>>[
      <String, dynamic>{
        'section_id': 'FAMILY',
        'word': 'Mutter',
        'translation_ar': 'أم',
        'cefr_level': 'A1',
      },
    ]);
    await tester.pump();
    expect(calls, 2);
    expect(find.text('Haus'), findsOneWidget);
    expect(find.text('Mutter'), findsNothing);
    expect(find.text('أم'), findsNothing);
  });

  testWidgets('oversized verified forms and examples stay bounded in details',
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
            'section_id': 'FAMILY',
            'word': 'Mutter',
            'translation_ar': 'أم',
            'cefr_level': 'A1',
            'forms': List<String>.generate(80, (i) => 'form-$i'),
            'examples': List<String>.generate(80, (i) => 'مثال-$i'),
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mutter'));
    await tester.pumpAndSettle();

    expect(find.text('form-0'), findsOneWidget);
    expect(find.text('form-31'), findsOneWidget);
    expect(find.text('form-32'), findsNothing);
    expect(find.text('مثال-0'), findsOneWidget);
    expect(find.text('مثال-31'), findsOneWidget);
    expect(find.text('مثال-32'), findsNothing);
    expect(find.textContaining('أول 32'), findsNWidgets(2));
    expect(
      tester.widget<Text>(find.text('form-0')).textDirection,
      TextDirection.ltr,
    );
    expect(
      tester.widget<Text>(find.text('مثال-0')).textDirection,
      TextDirection.rtl,
    );
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();
    expect(find.text('Mutter'), findsOneWidget);
  });


  testWidgets('clear search restores bounded local results after no match',
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
    final search = find.byKey(const Key('topic-search'));
    expect(find.byKey(const Key('topic-search-clear')), findsNothing);

    await tester.enterText(search, 'غائب');
    await tester.pump();
    expect(tester.widget<TextField>(search).textDirection, TextDirection.rtl);
    expect(find.textContaining('لا توجد نتائج مطابقة'), findsOneWidget);
    expect(find.textContaining('حتى 50 كلمة'), findsOneWidget);
    final clear = find.byKey(const Key('topic-search-clear'));
    expect(clear, findsOneWidget);
    expect(tester.widget<IconButton>(clear).tooltip,
        'مسح البحث وإظهار المفردات');

    await tester.tap(clear);
    await tester.pump();
    expect(tester.widget<TextField>(search).controller!.text, isEmpty);
    expect(tester.widget<TextField>(search).textDirection, TextDirection.ltr);
    expect(find.byKey(const Key('topic-search-clear')), findsNothing);
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('Vater'), findsOneWidget);
  });

  testWidgets('clearing filtered practice resets index and revealed answer',
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
    await tester.enterText(find.byKey(const Key('topic-search')), 'Vater');
    await tester.pump();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('study-source'))).data,
        'Vater');
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('أب'), findsOneWidget);

    await tester.tap(find.byKey(const Key('topic-search-clear')));
    await tester.pump();
    expect(find.text('بطاقة 1 من 2'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('study-source'))).data,
        'Mutter');
    expect(find.text('أب'), findsNothing);
    expect(find.text('أم'), findsNothing);
    expect(find.byKey(const Key('study-reveal')), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('topic-search')))
        .controller!.text, isEmpty);
  });


  testWidgets('rapid double tap opens only one word detail route',
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
        ],
      ),
    ));
    await tester.pumpAndSettle();
    // Two taps before the first dialog's frame has been rendered.
    await tester.tap(find.text('Mutter'));
    await tester.tap(find.text('Mutter'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المفردة'), findsOneWidget);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المفردة'), findsNothing);
    expect(find.text('Mutter'), findsOneWidget);
  });

  testWidgets('rapid taps cannot leave old-pair details after switching',
      (tester) async {
    final section = LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) async => <Map<String, dynamic>>[
      <String, dynamic>{
        'word': 'Mutter',
        'translation_ar': 'أم',
        'forms': <String>['Mütter'],
      },
    ];

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
    await tester.tap(find.text('Mutter'));
    await tester.tap(find.text('Mutter'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'en',
        loadWords: loader,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المفردة'), findsNothing);
    expect(find.text('Mütter'), findsNothing);
    expect(find.text('أم'), findsNothing);
    expect(find.textContaining('لا تتوفر مفردات موثقة لهذا الاتجاه'),
        findsOneWidget);
  });


  testWidgets('practice opens selected card forms and examples, not prior card',
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
            'translation_ar': 'أم',
            'sense_gloss': 'الأم',
            'forms': <String>['Mütter'],
            'examples': <String>['Die Mutter liest.'],
          },
          <String, dynamic>{
            'word': 'Vater',
            'translation_ar': 'أب',
            'sense_gloss': 'الأب',
            'forms': <String>['Väter'],
            'examples': <String>['Der Vater arbeitet.'],
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('study-next')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('study-source'))).data,
        'Vater');
    expect(find.text('أب'), findsNothing);

    final details = find.byKey(const Key('study-word-details'));
    expect(details, findsOneWidget);
    await tester.ensureVisible(details);
    await tester.tap(details);
    await tester.pumpAndSettle();
    expect(find.text('Väter'), findsOneWidget);
    expect(find.text('Der Vater arbeitet.'), findsOneWidget);
    expect(find.text('الأب'), findsOneWidget);
    expect(find.text('Mütter'), findsNothing);
    expect(find.text('Die Mutter liest.'), findsNothing);
    expect(tester.widget<Text>(find.text('Väter')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('الأب')).textDirection,
        TextDirection.rtl);

    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المفردة'), findsNothing);
    expect(tester.widget<Text>(find.byKey(const Key('study-source'))).data,
        'Vater');
  });

  testWidgets('practice details close on directed-pair change', (tester) async {
    final section = LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) async => <Map<String, dynamic>>[
      <String, dynamic>{
        'word': 'Mutter',
        'translation_ar': 'أم',
        'forms': <String>['Mütter'],
      },
    ];
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
    final details = find.byKey(const Key('study-word-details'));
    await tester.ensureVisible(details);
    await tester.tap(details);
    await tester.pumpAndSettle();
    expect(find.text('Mütter'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'en',
        loadWords: loader,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المفردة'), findsNothing);
    expect(find.text('Mütter'), findsNothing);
    expect(find.text('أم'), findsNothing);
    expect(find.byKey(const Key('study-word-details')), findsNothing);
    expect(find.textContaining('لا تتوفر مفردات موثقة لهذا الاتجاه'),
        findsOneWidget);
  });


  testWidgets('removing learning page dismisses its root word details dialog',
      (tester) async {
    final showLearning = ValueNotifier<bool>(true);
    addTearDown(showLearning.dispose);
    final section =
        LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');

    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<bool>(
        valueListenable: showLearning,
        builder: (context, visible, child) => visible
            ? TopicWordsScreen(
                section: section,
                cefr: 'A1',
                languageCode: 'de',
                targetLanguageCode: 'ar',
                loadWords: ({
                  required String sectionId,
                  required String cefr,
                  required String languageCode,
                }) async => <Map<String, dynamic>>[
                  <String, dynamic>{
                    'word': 'Mutter',
                    'translation_ar': 'أم',
                    'forms': <String>['Mütter'],
                  },
                ],
              )
            : const Scaffold(body: Text('شاشة الزوج الجديد')),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mutter'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المفردة'), findsOneWidget);
    expect(find.text('Mütter'), findsOneWidget);

    // Replacing the page is not equivalent to changing TopicWordsScreen's
    // props: didUpdateWidget never runs, and the root dialog must still go.
    showLearning.value = false;
    await tester.pumpAndSettle();
    expect(find.text('شاشة الزوج الجديد'), findsOneWidget);
    expect(find.text('تفاصيل المفردة'), findsNothing);
    expect(find.text('Mütter'), findsNothing);
    expect(find.text('أم'), findsNothing);
  });

  testWidgets('pair change with an open dialog never mutates Navigator during build',
      (tester) async {
    final section =
        LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');
    Future<List<Map<String, dynamic>>> loader({
      required String sectionId,
      required String cefr,
      required String languageCode,
    }) async => <Map<String, dynamic>>[
          <String, dynamic>{
            'word': 'Mutter',
            'translation_ar': 'أم',
            'forms': <String>['Mütter'],
          },
        ];

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
    await tester.tap(find.text('Mutter'));
    await tester.pumpAndSettle();
    expect(find.text('Mütter'), findsOneWidget);

    // didUpdateWidget is invoked while the new tree is being built.
    // A synchronous removeRoute here can assert and leave stale translation.
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'en',
        loadWords: loader,
      ),
    ));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('تفاصيل المفردة'), findsNothing);
    expect(find.text('Mütter'), findsNothing);
    expect(find.text('أم'), findsNothing);
    expect(find.textContaining('لا تتوفر مفردات موثقة لهذا الاتجاه'),
        findsOneWidget);
  });
  testWidgets('nested pair identity rejects reverse rows without hiding legacy rows',
      (tester) async {
    final section =
        LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'ar',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          <String, dynamic>{
            'word': 'Mutter',
            'translation_ar': 'أم',
            'pair_identity': <String, String>{
              'id': 'ar->de',
              'source_language': 'ar',
              'target_language': 'de',
            },
          },
          <String, dynamic>{
            'word': 'Vater',
            'translation_ar': 'أب',
            'pair_identity': <String, String>{
              'id': 'de->ar',
              'source_language': 'de',
              'target_language': 'ar',
            },
          },
          <String, dynamic>{
            'word': 'Kind',
            'translation_ar': 'طفل',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Mutter'), findsNothing);
    expect(find.text('أم'), findsNothing);
    expect(find.text('Vater'), findsOneWidget);
    expect(find.text('Kind'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Vater')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أب')).textDirection,
        TextDirection.rtl);
  });

  testWidgets('malformed or contradictory nested pair metadata fails closed',
      (tester) async {
    final section =
        LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY');
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: section,
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'ar',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          <String, dynamic>{
            'word': 'Frau',
            'translation_ar': 'امرأة',
            'pair_identity': <String, String>{'id': 'de->ar', 'target_language': 'en'},
          },
          <String, dynamic>{
            'word': 'Mann',
            'translation_ar': 'رجل',
            'pair_identity': <String, String>{'source_language': 'de'},
          },
          <String, dynamic>{
            'word': 'Bruder',
            'translation_ar': 'أخ',
            'pair_identity': 'de->ar',
          },
          <String, dynamic>{
            'word': 'Schwester',
            'translation_ar': 'أخت',
            'pair_identity': <String, String>{'id': ' DE->AR '},
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Frau'), findsNothing);
    expect(find.text('Mann'), findsNothing);
    expect(find.text('Bruder'), findsNothing);
    expect(find.text('Schwester'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Schwester')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أخت')).textDirection,
        TextDirection.rtl);
  });
  testWidgets('flat pair identity rejects reverse rows but keeps valid and legacy',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TopicWordsScreen(
        section: LocalTopicCatalog.sections.firstWhere((s) => s.id == 'FAMILY'),
        cefr: 'A1',
        languageCode: 'de',
        targetLanguageCode: 'ar',
        loadWords: ({
          required String sectionId,
          required String cefr,
          required String languageCode,
        }) async => <Map<String, dynamic>>[
          <String, dynamic>{
            'word': 'Vater', 'translation_ar': 'أب',
            'source_language': 'ar', 'target_language': 'de',
          },
          <String, dynamic>{
            'word': 'Mutter', 'translation_ar': 'أم',
            'pair_id': 'ar->de',
          },
          <String, dynamic>{
            'word': 'Frau', 'translation_ar': 'امرأة',
            'pair_id': 42,
          },
          <String, dynamic>{
            'word': 'Kind', 'translation_ar': 'طفل',
            'source_language': 'de', 'target_language': 'ar',
            'pair_id': 'de->ar',
          },
          <String, dynamic>{
            'word': 'Bruder', 'translation_ar': 'أخ',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Vater'), findsNothing);
    expect(find.text('Mutter'), findsNothing);
    expect(find.text('Frau'), findsNothing);
    expect(find.text('Kind'), findsOneWidget);
    expect(find.text('Bruder'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Kind')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('طفل')).textDirection,
        TextDirection.rtl);
  });
}
