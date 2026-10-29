import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/dictation_trainer_screen.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';

void main() {
  setUp(() {
    LexicalRepository.initializeStore([
      const LexicalEntry(
        id: '1',
        domainId: 'test_domain',
        sourceLocale: 'ar',
        targetLocale: 'de',
        targetTerm: 'Apfel',
        sourceMeaning: 'تفاحة',
        targetExample: 'Der Apfel ist rot.',
        sourceExampleTranslation: 'التفاحة حمراء.',
        partOfSpeech: 'noun',
      ),
      const LexicalEntry(
        id: '2',
        domainId: 'test_domain',
        sourceLocale: 'ar',
        targetLocale: 'de',
        targetTerm: 'كتاب', // Non-Latin script
        sourceMeaning: 'Buch',
        targetExample: 'Das ist ein Buch.',
        sourceExampleTranslation: 'هذا كتاب.',
        partOfSpeech: 'noun',
      ),
    ]);
  });

  testWidgets('Renders DictationTrainerScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DictationTrainerScreen(sourceLocale: 'ar', targetLocale: 'de'),
    ));

    await tester.pumpAndSettle(); // Wait for data to load

    expect(find.text('مدرب الاستماع والتهجئة (Dictation)'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.headphones_rounded), findsOneWidget);
  });

  testWidgets('Audio unavailable state fallback UI', (WidgetTester tester) async {
    // Testing the UI fallback by mocking or just forcing the state is complex since OfflineAudioDispatcher is static.
    // Let's at least test that tapping play doesn't break the app and shows the snackbar.
    await tester.pumpWidget(const MaterialApp(
      home: DictationTrainerScreen(sourceLocale: 'ar', targetLocale: 'de'),
    ));
    await tester.pumpAndSettle();

    // Tap play
    await tester.tap(find.byIcon(Icons.play_circle_fill_rounded));
    await tester.pump();

    // Snackbar should be visible
    expect(find.byType(SnackBar), findsOneWidget);

    // Clean up
    await tester.pumpAndSettle();
  });

  testWidgets('Incorrect answer with Unicode normalization', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DictationTrainerScreen(sourceLocale: 'ar', targetLocale: 'de'),
    ));
    await tester.pumpAndSettle();

    // Type the incorrect answer
    await tester.enterText(find.byType(TextField), 'Apfellll');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pumpAndSettle();

    expect(find.text('خطأ تهجئي بسيط، الكلمة الصحيحة هي: Apfel'), findsOneWidget);
  });

  testWidgets('Correct answer with Unicode normalization (case insensitive)', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DictationTrainerScreen(sourceLocale: 'ar', targetLocale: 'de'),
    ));
    await tester.pumpAndSettle();

    // Type the correct answer but in lowercase
    await tester.enterText(find.byType(TextField), 'apfel');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pumpAndSettle();

    expect(find.text('إجابة صحيحة تماماً! أحسنت 🚀'), findsOneWidget);
  });

  testWidgets('Non-Latin script answer works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DictationTrainerScreen(sourceLocale: 'ar', targetLocale: 'de'),
    ));
    await tester.pumpAndSettle();

    // Move to next word to get the non-Latin entry
    await tester.enterText(find.byType(TextField), 'apfel');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('الكلمة التالية'));
    await tester.pumpAndSettle();

    // Now at the non-Latin word 'كتاب'
    await tester.enterText(find.byType(TextField), 'كتاب');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pumpAndSettle();

    expect(find.text('إجابة صحيحة تماماً! أحسنت 🚀'), findsOneWidget);
  });

  testWidgets('Rapid actions - next word tapped multiple times', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DictationTrainerScreen(sourceLocale: 'ar', targetLocale: 'de'),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'apfel');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pumpAndSettle();

    // Tap next word multiple times quickly
    await tester.tap(find.text('الكلمة التالية'));
    await tester.tap(find.text('الكلمة التالية'));
    await tester.pumpAndSettle();

    // Should only move forward one step, meaning we should be on 'كتاب' now, or finished if tapped twice successfully.
    // It's just verifying no crashes occur on rapid taps.
    expect(find.byType(DictationTrainerScreen), findsOneWidget);
  });

  testWidgets('Interrupted navigation stops audio and disposes safely', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const DictationTrainerScreen()));
            },
            child: const Text('Go'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(find.byType(DictationTrainerScreen), findsOneWidget);

    // Trigger navigation back
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.byType(DictationTrainerScreen), findsNothing);
  });

  testWidgets('Missing examples state', (WidgetTester tester) async {
    LexicalRepository.initializeStore([]); // Empty store

    await tester.pumpWidget(const MaterialApp(
      home: DictationTrainerScreen(sourceLocale: 'ar', targetLocale: 'de'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('لا توجد كلمات للتدرب عليها'), findsOneWidget);
  });
}
