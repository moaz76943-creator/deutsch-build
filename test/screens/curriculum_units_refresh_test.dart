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
}
