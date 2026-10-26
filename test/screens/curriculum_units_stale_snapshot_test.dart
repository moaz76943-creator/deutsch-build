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
}
