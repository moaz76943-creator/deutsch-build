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
}
