import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/dictation_trainer_screen.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';

void main() {
  setUpAll(() {
    LexicalRepository.initializeStore([
      const LexicalEntry(
        id: 'test_dict_1',
        domainId: 'dictation_practice',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'Schule',
        sourceMeaning: 'مدرسة',
        targetExample: 'Die Schule ist groß.',
        sourceExampleTranslation: 'المدرسة كبيرة.',
        partOfSpeech: 'noun',
      ),
      const LexicalEntry(
        id: 'test_dict_2',
        domainId: 'dictation_practice',
        sourceLocale: 'ar-SA',
        targetLocale: 'ru-RU',
        targetTerm: 'Школа',
        sourceMeaning: 'مدرسة',
        targetExample: 'Школа большая.',
        sourceExampleTranslation: 'المدرسة كبيرة.',
        partOfSpeech: 'noun',
      ),
    ]);
  });

  testWidgets('DictationTrainerScreen initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DictationTrainerScreen()));
    expect(find.text('مدرب الاستماع والتهجئة (Dictation)'), findsOneWidget);
    expect(find.textContaining('مدرسة'), findsOneWidget); // Shows meaning of first entry
  });

  testWidgets('Correct answer flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DictationTrainerScreen()));

    // Type correct answer
    await tester.enterText(find.byType(TextField), 'Schule');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pump();

    expect(find.text('إجابة صحيحة تماماً! أحسنت 🚀'), findsOneWidget);
  });

  testWidgets('Incorrect answer flow and max attempts', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DictationTrainerScreen()));

    // Attempt 1
    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pump();
    expect(find.text('خطأ تهجئي، حاول مرة أخرى. الكلمة المطلوبة: Schule'), findsOneWidget);

    // Attempt 2
    await tester.enterText(find.byType(TextField), 'wrong2');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pump();

    // Attempt 3
    await tester.enterText(find.byType(TextField), 'wrong3');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pump();

    expect(find.text('لقد استنفدت المحاولات. الكلمة هي: Schule'), findsOneWidget);

    // Verify textfield is disabled
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);
  });

  testWidgets('Offline audio absence behavior', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DictationTrainerScreen()));

    // Tap play
    await tester.tap(find.byIcon(Icons.play_circle_fill_rounded));
    await tester.pumpAndSettle();

    // Assuming play works or fails silently, we just need to ensure the screen doesn't crash
    expect(find.byType(DictationTrainerScreen), findsOneWidget);
  });

  testWidgets('Non-Latin script input (Russian)', (WidgetTester tester) async {
    // We clear the store and set it to only Russian to force loading the Russian entry
    LexicalRepository.initializeStore([
      const LexicalEntry(
        id: 'test_dict_2',
        domainId: 'dictation_practice',
        sourceLocale: 'ar-SA',
        targetLocale: 'ru-RU',
        targetTerm: 'Школа',
        sourceMeaning: 'مدرسة',
        targetExample: 'Школа большая.',
        sourceExampleTranslation: 'المدرسة كبيرة.',
        partOfSpeech: 'noun',
      ),
    ]);

    await tester.pumpWidget(const MaterialApp(home: DictationTrainerScreen()));

    // Type correct answer in Cyrillic
    await tester.enterText(find.byType(TextField), 'Школа');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pump();

    expect(find.text('إجابة صحيحة تماماً! أحسنت 🚀'), findsOneWidget);
  });
}
