import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/dictation_trainer_screen.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';

void main() {
  setUp(() {
    LexicalRepository.initializeStore([
      const LexicalEntry(
        id: 'dict_test_01',
        domainId: 'domain_01',
        sourceLocale: 'ar',
        targetLocale: 'de',
        targetTerm: 'Verantwortung',
        sourceMeaning: 'المسؤولية',
        targetExample: 'Ich übernehme die Verantwortung.',
        sourceExampleTranslation: 'أنا أتحمل المسؤولية.',
        partOfSpeech: 'noun',
      ),
      const LexicalEntry(
        id: 'dict_test_02',
        domainId: 'domain_01',
        sourceLocale: 'en',
        targetLocale: 'ar',
        targetTerm: 'مَرْحَبًا',
        sourceMeaning: 'Hello',
        targetExample: 'مرحبا بك',
        sourceExampleTranslation: 'Welcome',
        partOfSpeech: 'noun',
      ),
    ]);
  });

  Widget buildScreen({String source = 'ar', String target = 'de'}) {
    return MaterialApp(
      home: DictationTrainerScreen(
        sourceLocale: source,
        targetLocale: target,
      ),
    );
  }

  testWidgets('Screen shows missing state when no entries', (tester) async {
    await tester.pumpWidget(buildScreen(source: 'fr', target: 'es'));
    await tester.pumpAndSettle();

    expect(find.text('لا توجد مفردات متاحة للتدريب حالياً.'), findsOneWidget);
  });

  testWidgets('Screen shows entry and falls back gracefully when TTS is missing', (tester) async {
    await tester.pumpWidget(buildScreen(source: 'ar', target: 'de'));
    await tester.pumpAndSettle();

    expect(find.text('المعنى المساعد: المسؤولية'), findsOneWidget);
  });

  testWidgets('Entering correct answer displays success and disables input', (tester) async {
    await tester.pumpWidget(buildScreen(source: 'ar', target: 'de'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'verantwortung');
    await tester.pumpAndSettle();

    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pumpAndSettle();

    expect(find.text('إجابة صحيحة تماماً! أحسنت 🚀'), findsOneWidget);

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);
  });

  testWidgets('Entering incorrect answer displays fail state', (tester) async {
    await tester.pumpWidget(buildScreen(source: 'ar', target: 'de'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Verantwordung');
    await tester.pumpAndSettle();

    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pumpAndSettle();

    expect(find.textContaining('خطأ تهجئي بسيط'), findsOneWidget);
  });

  testWidgets('Supports non-Latin scripts properly with normalization', (tester) async {
    await tester.pumpWidget(buildScreen(source: 'en', target: 'ar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'مرحبا');
    await tester.pumpAndSettle();

    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pumpAndSettle();

    expect(find.text('إجابة صحيحة تماماً! أحسنت 🚀'), findsOneWidget);
  });

  testWidgets('Rapid actions do not allow multiple submissions', (tester) async {
    await tester.pumpWidget(buildScreen(source: 'ar', target: 'de'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Verantwortung');
    await tester.pumpAndSettle();

    final submitButton = find.text('تحقق من التهجئة');

    await tester.tap(submitButton);
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('Interrupted navigation cleans up safely without crashing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DictationTrainerScreen(),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(DictationTrainerScreen), findsOneWidget);

    Navigator.pop(tester.element(find.byType(DictationTrainerScreen)));
    await tester.pumpAndSettle();

    expect(find.byType(DictationTrainerScreen), findsNothing);
  });
}
