import 'dart:async';

import 'package:deutsch_bilarabi/features/explore/data/local_topic_catalog.dart';
import 'package:deutsch_bilarabi/screens/curriculum_units_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('populated topic refreshes installed rows without losing search',
      (tester) async {
    var reads = 0;
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
        }) async {
          reads++;
          if (reads == 1) {
            return <Map<String, dynamic>>[
              <String, dynamic>{'word': 'Mutter', 'translation_ar': 'أم'},
              <String, dynamic>{'word': 'Vater', 'translation_ar': 'أب'},
            ];
          }
          return <Map<String, dynamic>>[
            <String, dynamic>{'word': 'Mutter', 'translation_ar': 'والدة'},
            <String, dynamic>{'word': 'Schwester', 'translation_ar': 'أخت'},
          ];
        },
      ),
    ));
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(find.text('أم'), findsOneWidget);
    final search = find.byKey(const Key('topic-search'));
    await tester.enterText(search, 'Mutter');
    await tester.pump();
    expect(find.text('Vater'), findsNothing);

    await tester.tap(find.byKey(const Key('topic-content-refresh')));
    await tester.pumpAndSettle();
    expect(reads, 2);
    expect(tester.widget<TextField>(search).controller!.text, 'Mutter');
    expect(find.text('والدة'), findsOneWidget);
    expect(find.text('أم'), findsNothing);
    expect(find.text('Schwester'), findsNothing);
    expect(tester.widget<Text>(find.text('Mutter')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('والدة')).textDirection,
        TextDirection.rtl);

    await tester.tap(find.byKey(const Key('topic-search-clear')));
    await tester.pump();
    expect(find.text('Schwester'), findsOneWidget);
    expect(find.text('Vater'), findsNothing);
  });

  testWidgets('contradictory nested pair aliases stay out of cards and search',
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
            'word': 'Mutter', 'translation_ar': 'أم',
            'pair_identity': <String, String>{
              'id': 'de->ar', 'source_language_code': 'ar',
            },
          },
          <String, dynamic>{
            'word': 'Vater', 'translation_ar': 'أب',
            'pair_identity': <String, String>{
              'id': 'de->ar', 'target_language_code': 'de',
            },
          },
          <String, dynamic>{
            'word': 'Frau', 'translation_ar': 'امرأة',
            'pair_identity': <String, String>{
              'id': 'de->ar', 'source': 'ar',
            },
          },
          <String, dynamic>{
            'word': 'Mann', 'translation_ar': 'رجل',
            'pair_identity': <String, String>{
              'id': 'de->ar', 'target': 'de',
            },
          },
          <String, dynamic>{
            'word': 'Kind', 'translation_ar': 'طفل',
            'pair_identity': <String, String>{
              'id': 'de->ar', 'translation_language_code': 'fr',
            },
          },
          <String, dynamic>{
            'word': 'Bruder', 'translation_ar': 'أخ',
            'pair_identity': <String, String>{
              'id': 'de->ar', 'source_language_code': 'de',
              'target_language_code': 'ar', 'source': 'de',
              'target': 'ar', 'translation_language_code': 'ar',
            },
          },
          <String, dynamic>{'word': 'Schwester', 'translation_ar': 'أخت'},
        ],
      ),
    ));
    await tester.pumpAndSettle();

    for (final rejected in <String>['Mutter', 'Vater', 'Frau', 'Mann', 'Kind']) {
      expect(find.text(rejected), findsNothing);
    }
    expect(find.text('Bruder'), findsOneWidget);
    expect(find.text('Schwester'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Bruder')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أخ')).textDirection,
        TextDirection.rtl);

    await tester.enterText(find.byKey(const Key('topic-search')), 'Mutter');
    await tester.pump();
    expect(find.text('Mutter'), findsNothing);
    expect(find.text('Bruder'), findsNothing);
    await tester.tap(find.byKey(const Key('topic-search-clear')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Bruder'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('أخ'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-next')));
    await tester.pump();
    expect(find.text('Schwester'), findsOneWidget);
    expect(find.text('أخت'), findsNothing);
  });

  testWidgets('changing parent pair closes an already pushed topic route',
      (tester) async {
    final target = ValueNotifier<String>('ar');
    addTearDown(target.dispose);
    var reads = 0;
    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<String>(
        valueListenable: target,
        builder: (_, selectedTarget, __) => CurriculumUnitsScreen(
          targetLanguageCode: selectedTarget,
          loadWords: ({
            required String sectionId,
            required String cefr,
            required String languageCode,
          }) async {
            reads++;
            return <Map<String, dynamic>>[
              <String, dynamic>{
                'word': 'Mutter',
                'translation_ar': 'أم',
                'cefr_level': 'A1',
              },
            ];
          },
        ),
      ),
    ));
    await tester.tap(find.textContaining('العائلة والأسرة'));
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('أم'), findsOneWidget);

    // The global pair can change while the nested topic route is still open.
    // Its old de->ar translation must not remain on screen.
    target.value = 'en';
    await tester.pumpAndSettle();
    expect(find.text('Mutter'), findsNothing);
    expect(find.text('أم'), findsNothing);
    expect(find.textContaining('لا تتوفر أقسام محلية موثقة'),
        findsOneWidget);
    expect(reads, 1);
  });

  testWidgets('stalled local read offers immediate retry and ignores late rows',
      (tester) async {
    final firstRead = Completer<List<Map<String, dynamic>>>();
    var reads = 0;
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
        }) {
          reads++;
          if (reads == 1) return firstRead.future;
          return Future<List<Map<String, dynamic>>>.value([
            <String, dynamic>{'word': 'Schwester', 'translation_ar': 'أخت'},
          ]);
        },
      ),
    ));
    await tester.pump();
    expect(reads, 1);
    expect(find.text('جارٍ قراءة المفردات المحلية...'), findsOneWidget);
    expect(find.byKey(const Key('topic-loading-retry')), findsOneWidget);

    // A stalled adapter must not force a 30-second wait before another read.
    await tester.tap(find.byKey(const Key('topic-loading-retry')));
    await tester.pumpAndSettle();
    expect(reads, 2);
    expect(find.text('Schwester'), findsOneWidget);
    expect(find.text('أخت'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Schwester')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أخت')).textDirection,
        TextDirection.rtl);

    // The original read may complete after the replacement has succeeded.
    firstRead.complete([
      <String, dynamic>{'word': 'Mutter', 'translation_ar': 'أم'},
    ]);
    await tester.pump();
    expect(find.text('Mutter'), findsNothing);
    expect(find.text('أم'), findsNothing);
    expect(find.text('Schwester'), findsOneWidget);
  });

  testWidgets('failed pack refresh retains last verified rows and permits retry',
      (tester) async {
    var reads = 0;
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
        }) async {
          reads++;
          if (reads == 2) throw StateError('transient offline read failure');
          return <Map<String, dynamic>>[
            <String, dynamic>{
              'word': reads == 1 ? 'Mutter' : 'Schwester',
              'translation_ar': reads == 1 ? 'أم' : 'أخت',
            },
          ];
        },
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Mutter'), findsOneWidget);
    await tester.tap(find.byKey(const Key('topic-content-refresh')));
    await tester.pumpAndSettle();
    expect(reads, 2);
    // A transient pack-read error must not erase already verified offline data.
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('أم'), findsOneWidget);
    expect(find.textContaining('تعذر تحديث'), findsOneWidget);
    await tester.tap(find.byKey(const Key('topic-content-refresh')));
    await tester.pumpAndSettle();
    expect(reads, 3);
    expect(find.text('Schwester'), findsOneWidget);
    expect(find.text('Mutter'), findsNothing);
    expect(tester.widget<Text>(find.text('Schwester')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أخت')).textDirection,
        TextDirection.rtl);
  });

  testWidgets('flat source and target aliases cannot leak reverse-pair words',
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
            'word': 'Mutter', 'translation_ar': 'أم',
            'source': 'ar', 'target': 'de',
          },
          <String, dynamic>{
            'word': 'Vater', 'translation_ar': 'أب', 'source': 'ar',
          },
          <String, dynamic>{
            'word': 'Kind', 'translation_ar': 'طفل', 'target': 'de',
          },
          <String, dynamic>{
            'word': 'Frau', 'translation_ar': 'امرأة',
            'translation_language': 'de',
          },
          <String, dynamic>{
            'word': 'Bruder', 'translation_ar': 'أخ',
            'source': 'de', 'target': 'ar', 'translation_language': 'ar',
          },
          <String, dynamic>{'word': 'Schwester', 'translation_ar': 'أخت'},
        ],
      ),
    ));
    await tester.pumpAndSettle();
    for (final rejected in <String>['Mutter', 'Vater', 'Kind', 'Frau']) {
      expect(find.text(rejected), findsNothing);
    }
    expect(find.text('Bruder'), findsOneWidget);
    expect(find.text('Schwester'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Bruder')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أخ')).textDirection,
        TextDirection.rtl);

    await tester.enterText(find.byKey(const Key('topic-search')), 'Mutter');
    await tester.pump();
    expect(find.text('Mutter'), findsNothing);
    await tester.tap(find.byKey(const Key('topic-search-clear')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Bruder'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('أخ'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-next')));
    await tester.pump();
    expect(find.text('Schwester'), findsOneWidget);
    expect(find.text('أخت'), findsNothing);
  });


  testWidgets('retry during stalled refresh retains previously verified words',
      (tester) async {
    final stalled = Completer<List<Map<String, dynamic>>>();
    var reads = 0;
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
        }) {
          reads++;
          if (reads == 2) return stalled.future;
          if (reads == 3) {
            return Future<List<Map<String, dynamic>>>.error(
                StateError('offline adapter unavailable'));
          }
          return Future<List<Map<String, dynamic>>>.value([
            <String, dynamic>{
              'word': reads == 1 ? 'Mutter' : 'Schwester',
              'translation_ar': reads == 1 ? 'أم' : 'أخت',
            },
          ]);
        },
      ),
    ));
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(find.text('Mutter'), findsOneWidget);

    // A refresh stalls after valid offline content was displayed.
    await tester.tap(find.byKey(const Key('topic-content-refresh')));
    await tester.pump();
    expect(reads, 2);
    await tester.tap(find.byKey(const Key('topic-loading-retry')));
    await tester.pumpAndSettle();
    expect(reads, 3);
    // The retry failed, but it must not discard the verified prior snapshot.
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('أم'), findsOneWidget);
    expect(find.textContaining('تعذر تحديث'), findsOneWidget);
    expect(find.byKey(const Key('topic-content-refresh')), findsOneWidget);
    expect(tester.widget<Text>(find.text('Mutter')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أم')).textDirection,
        TextDirection.rtl);

    // The stalled response is obsolete and must not replace retained rows.
    stalled.complete([
      <String, dynamic>{'word': 'Vater', 'translation_ar': 'أب'},
    ]);
    await tester.pump();
    expect(find.text('Vater'), findsNothing);
    expect(find.text('Mutter'), findsOneWidget);

    await tester.tap(find.byKey(const Key('topic-content-refresh')));
    await tester.pumpAndSettle();
    expect(reads, 4);
    expect(find.text('Schwester'), findsOneWidget);
    expect(find.text('Mutter'), findsNothing);
  });


  testWidgets('declared CEFR aliases cannot mix levels in topic search or cards',
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
            'word': 'Mutter', 'translation_ar': 'أم', 'cefr': 'B2',
          },
          <String, dynamic>{
            'word': 'Vater', 'translation_ar': 'أب', 'cefr_code': 'B1',
          },
          <String, dynamic>{
            'word': 'Frau', 'translation_ar': 'امرأة',
            'cefr_level': 'A1', 'cefr': 'B2',
          },
          <String, dynamic>{
            'word': 'Bruder', 'translation_ar': 'أخ', 'cefr': 'A1',
          },
          <String, dynamic>{
            'word': 'Schwester', 'translation_ar': 'أخت',
            'cefr_code': 'A1',
          },
          <String, dynamic>{
            'word': 'Kind', 'translation_ar': 'طفل',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    for (final rejected in <String>['Mutter', 'Vater', 'Frau']) {
      expect(find.text(rejected), findsNothing);
    }
    expect(find.text('Bruder'), findsOneWidget);
    expect(find.text('Schwester'), findsOneWidget);
    expect(find.text('Kind'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Bruder')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أخ')).textDirection,
        TextDirection.rtl);
    await tester.enterText(find.byKey(const Key('topic-search')), 'Mutter');
    await tester.pump();
    expect(find.text('Mutter'), findsNothing);
    await tester.tap(find.byKey(const Key('topic-search-clear')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Bruder'), findsOneWidget);
    expect(find.text('المستوى حسب الحزمة: A1 (ليس اعتماداً مستقلاً).'),
        findsOneWidget);
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('أخ'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-next')));
    await tester.pump();
    expect(find.text('Schwester'), findsOneWidget);
    expect(find.text('أخت'), findsNothing);
  });

  testWidgets('nested pair language aliases reject reverse content in list and cards',
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
            'word': 'Mutter', 'translation_ar': 'أم',
            'pair_identity': <String, String>{
              'id': 'de->ar', 'translation_language': 'de',
            },
          },
          <String, dynamic>{
            'word': 'Vater', 'translation_ar': 'أب',
            'pair_identity': <String, String>{
              'id': 'de->ar', 'language_code': 'ar',
            },
          },
          <String, dynamic>{
            'word': 'Bruder', 'translation_ar': 'أخ',
            'pair_identity': <String, String>{
              'id': 'de->ar', 'language_code': 'de',
              'translation_language': 'ar',
            },
          },
          <String, dynamic>{'word': 'Schwester', 'translation_ar': 'أخت'},
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Mutter'), findsNothing);
    expect(find.text('Vater'), findsNothing);
    expect(find.text('Bruder'), findsOneWidget);
    expect(find.text('Schwester'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Bruder')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أخ')).textDirection,
        TextDirection.rtl);

    await tester.enterText(find.byKey(const Key('topic-search')), 'Mutter');
    await tester.pump();
    expect(find.text('Mutter'), findsNothing);
    await tester.tap(find.byKey(const Key('topic-search-clear')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Bruder'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('أخ'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-next')));
    await tester.pump();
    expect(find.text('Schwester'), findsOneWidget);
    expect(find.text('أخت'), findsNothing);
  });

  testWidgets('untrusted CEFR aliases remain UNKNOWN in list cards and details',
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
            'word': 'Mutter', 'translation_ar': 'أم',
            'cefr_level': 'A1', 'cefr_code': 'B3',
          },
          <String, dynamic>{
            'word': 'Bruder', 'translation_ar': 'أخ',
            'cefr_level': 'A1', 'cefr': 'A1',
          },
          <String, dynamic>{
            'word': 'Vater', 'translation_ar': 'أب',
            'cefr_level': 'B2',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    // Malformed evidence must not be silently upgraded to confirmed A1.
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('UNKNOWN'), findsOneWidget);
    expect(find.text('Bruder'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);
    expect(find.text('Vater'), findsNothing);
    expect(tester.widget<Text>(find.text('Mutter')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أم')).textDirection,
        TextDirection.rtl);

    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.textContaining('المستوى UNKNOWN'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-word-details')));
    await tester.pumpAndSettle();
    expect(find.textContaining('UNKNOWN — لا يوجد تصنيف مستوى معتمد'),
        findsOneWidget);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('study-next')));
    await tester.pump();
    expect(find.text('Bruder'), findsOneWidget);
    expect(find.textContaining('المستوى حسب الحزمة: A1'), findsOneWidget);
  });

  testWidgets('normalized ISO pair codes keep topic content directed',
      (tester) async {
    final target = ValueNotifier<String>(' AR ');
    addTearDown(target.dispose);
    final requestedLanguages = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<String>(
        valueListenable: target,
        builder: (_, selectedTarget, __) => CurriculumUnitsScreen(
          languageCode: ' DE ',
          targetLanguageCode: selectedTarget,
          loadWords: ({
            required String sectionId,
            required String cefr,
            required String languageCode,
          }) async {
            requestedLanguages.add(languageCode);
            return <Map<String, dynamic>>[
              <String, dynamic>{
                'word': 'Mutter',
                'translation_ar': 'أم',
                'language_code': 'DE',
                'target_language_code': 'AR',
                'pair_id': 'DE->AR',
                'cefr_level': 'A1',
              },
            ];
          },
        ),
      ),
    ));
    await tester.tap(find.textContaining('العائلة والأسرة'));
    await tester.pumpAndSettle();
    expect(requestedLanguages, <String>['de']);
    expect(find.text('Mutter'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Mutter')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أم')).textDirection,
        TextDirection.rtl);
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('أم'), findsOneWidget);

    // Changing the directed pair must not reuse the previous de->ar snapshot.
    target.value = ' DE ';
    await tester.pumpAndSettle();
    expect(find.text('Mutter'), findsNothing);
    expect(find.textContaining('لا تتوفر أقسام محلية موثقة'), findsOneWidget);
    expect(requestedLanguages, <String>['de']);
  });


  testWidgets('Arabic and Persian keyboard variants search only selected pair',
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
            'word': 'Buch', 'translation_ar': 'كتاب',
            'source_language': 'de', 'target_language': 'ar',
          },
          <String, dynamic>{
            'word': 'Bruder', 'translation_ar': 'أخي',
            'pair_id': 'de->ar',
          },
          <String, dynamic>{
            'word': 'Maison', 'translation_ar': 'بيت',
            'source_language': 'fr', 'target_language': 'ar',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    final search = find.byKey(const Key('topic-search'));

    // Persian kaf on an Arabic keyboard must find the attested Arabic kaf.
    await tester.enterText(search, 'کتاب');
    await tester.pump();
    expect(find.text('Buch'), findsOneWidget);
    expect(find.text('Bruder'), findsNothing);
    expect(find.text('Maison'), findsNothing);
    expect(tester.widget<Text>(find.text('Buch')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('كتاب')).textDirection,
        TextDirection.rtl);

    // Persian yeh must also match Arabic yeh without changing the source pair.
    await tester.enterText(search, 'أخی');
    await tester.pump();
    expect(find.text('Bruder'), findsOneWidget);
    expect(find.text('Buch'), findsNothing);
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Bruder'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('أخي'), findsOneWidget);
    expect(find.text('Maison'), findsNothing);
  });
  testWidgets('Arabic-Indic numeral search keeps Western words and pair isolation',
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
            'word': '16',
            'translation_ar': 'ستة عشر',
            'source_language': 'de',
            'target_language': 'ar',
          },
          <String, dynamic>{
            'word': '70',
            'translation_ar': 'سبعون',
            'source_language': 'de',
            'target_language': 'ar',
          },
          <String, dynamic>{
            'word': '99',
            'translation_ar': 'تسعة وتسعون',
            'source_language': 'fr',
            'target_language': 'ar',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    final search = find.byKey(const Key('topic-search'));

    // Both Arabic-Indic digit sets must match the same actual Western row.
    for (final query in <String>['١٦', '۱۶', '16']) {
      await tester.enterText(search, query);
      await tester.pump();
      expect(find.text('16'), findsOneWidget);
      expect(find.text('70'), findsNothing);
      expect(find.text('99'), findsNothing);
      expect(tester.widget<Text>(find.text('16')).textDirection,
          TextDirection.ltr);
      expect(tester.widget<Text>(find.text('ستة عشر')).textDirection,
          TextDirection.rtl);
    }

    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('16'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('ستة عشر'), findsOneWidget);
    expect(find.text('99'), findsNothing);
  });


  testWidgets('bidi marks in pasted search do not hide verified directed rows',
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
            'word': 'Mutter', 'translation_ar': 'أم',
            'source_language': 'de', 'target_language': 'ar',
          },
          <String, dynamic>{
            'word': 'Vater', 'translation_ar': '\u200Fأب\u200F',
            'source_language': 'de', 'target_language': 'ar',
          },
          <String, dynamic>{
            'word': 'Mother', 'translation_ar': 'أم',
            'source_language': 'en', 'target_language': 'ar',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    final search = find.byKey(const Key('topic-search'));

    // Isolate marks frequently accompany Arabic text copied from RTL apps.
    await tester.enterText(search, '\u2067أم\u2069');
    await tester.pump();
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('Vater'), findsNothing);
    expect(find.text('Mother'), findsNothing);
    expect(tester.widget<Text>(find.text('Mutter')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('أم')).textDirection,
        TextDirection.rtl);

    // The reverse case also matters: stored display text may contain RLM.
    await tester.enterText(search, 'أب');
    await tester.pump();
    expect(find.text('Vater'), findsOneWidget);
    expect(find.text('Mutter'), findsNothing);
    expect(find.text('\u200Fأب\u200F'), findsOneWidget);

    // German pasted with LRM/RLM must search the same selected de->ar pair.
    await tester.enterText(search, '\u200EMutter\u200F');
    await tester.pump();
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('Mother'), findsNothing);
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('أم'), findsOneWidget);
  });

  testWidgets('pasted mixed Unicode spaces find verified words and cards',
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
            'word': 'Guten Morgen', 'translation_ar': 'صباح الخير',
            'source_language': 'de', 'target_language': 'ar',
          },
          <String, dynamic>{
            'word': 'Gute Nacht', 'translation_ar': 'ليلة سعيدة',
            'source_language': 'de', 'target_language': 'ar',
          },
          <String, dynamic>{
            'word': 'Wrong pair', 'translation_ar': 'صباح الخير',
            'source_language': 'en', 'target_language': 'ar',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    final search = find.byKey(const Key('topic-search'));

    // NBSP, narrow NBSP, tabs and zero-width spaces arrive via copy/paste.
    for (final query in <String>[
      'Guten\u00A0\u00A0Morgen',
      '\u200BGuten\tMorgen\u200B',
      'صباح\u202F\u202Fالخير',
    ]) {
      await tester.enterText(search, query);
      await tester.pump();
      expect(find.text('Guten Morgen'), findsOneWidget);
      expect(find.text('Gute Nacht'), findsNothing);
      expect(find.text('Wrong pair'), findsNothing);
      expect(tester.widget<Text>(find.text('Guten Morgen')).textDirection,
          TextDirection.ltr);
      expect(tester.widget<Text>(find.text('صباح الخير')).textDirection,
          TextDirection.rtl);
    }

    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Guten Morgen'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('صباح الخير'), findsOneWidget);
    expect(find.text('Wrong pair'), findsNothing);
  });

  testWidgets('attested scalar forms and examples remain searchable in details',
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
            'word': 'gehen',
            'translation_ar': 'يذهب',
            'forms': 'ich gehe',
            'examples': 'Ich gehe nach Hause.',
            'source_language': 'de',
            'target_language': 'ar',
          },
          <String, dynamic>{
            'word': 'go',
            'translation_ar': 'يذهب',
            'forms': 'I go',
            'examples': 'I go home.',
            'source_language': 'en',
            'target_language': 'ar',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    final search = find.byKey(const Key('topic-search'));

    await tester.enterText(search, 'ich gehe');
    await tester.pump();
    expect(find.text('gehen'), findsOneWidget);
    expect(find.text('go'), findsNothing);
    expect(tester.widget<Text>(find.text('gehen')).textDirection,
        TextDirection.ltr);
    expect(tester.widget<Text>(find.text('يذهب')).textDirection,
        TextDirection.rtl);

    await tester.tap(find.text('gehen'));
    await tester.pumpAndSettle();
    expect(find.text('ich gehe'), findsOneWidget);
    expect(find.text('Ich gehe nach Hause.'), findsOneWidget);
    expect(find.text('I go home.'), findsNothing);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();

    await tester.enterText(search, 'Ich gehe nach Hause.');
    await tester.pump();
    expect(find.text('gehen'), findsOneWidget);
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('study-reveal')));
    await tester.pump();
    expect(find.text('يذهب'), findsOneWidget);
    expect(find.text('go'), findsNothing);
  });

  testWidgets('quiz shows textual comparison only for the selected directed pair',
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
          {'word': 'Mutter', 'translation_ar': 'أم',
           'source_language': 'de', 'target_language': 'ar'},
          {'word': 'Mother', 'translation_ar': 'أم',
           'source_language': 'en', 'target_language': 'ar'},
        ],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('topic-study-toggle')));
    await tester.pump();
    expect(find.text('Mother'), findsNothing);
    expect(tester.widget<Text>(find.byKey(const Key('study-source')))
        .textDirection, TextDirection.ltr);
    await tester.tap(find.byKey(const Key('study-quiz-toggle')));
    await tester.pump();
    final input = find.byKey(const Key('study-quiz-input'));
    expect(tester.widget<TextField>(input).textDirection, TextDirection.rtl);
    await tester.enterText(input, 'ام');
    await tester.pump();
    await tester.tap(find.byKey(const Key('study-quiz-compare')));
    await tester.pump();
    expect(find.textContaining('مطابقة نصية'), findsOneWidget);
    expect(find.text('أم'), findsOneWidget);
    await tester.enterText(input, 'أبي');
    await tester.pump();
    expect(find.byKey(const Key('study-quiz-text-match')), findsNothing);
    await tester.tap(find.byKey(const Key('study-quiz-compare')));
    await tester.pump();
    expect(find.textContaining('قد تكون صحيحة بصياغة أخرى'), findsOneWidget);
    expect(find.text('Mother'), findsNothing);
  });
}
