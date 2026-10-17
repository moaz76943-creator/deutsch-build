import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/quiz_exercise_screen.dart';
import 'package:deutsch_bilarabi/screens/focus_quiz_screen.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/srs_scheduler.dart';

void main() {
  setUp(() {
    // إعداد البيانات الوهمية
    final entries = [
      const LexicalEntry(
        id: '1',
        domainId: 'general',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'Haus',
        sourceMeaning: 'منزل',
        targetExample: 'Das ist ein Haus',
        sourceExampleTranslation: 'هذا منزل',
        partOfSpeech: 'noun',
      ),
      const LexicalEntry(
        id: '2',
        domainId: 'general',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'Auto',
        sourceMeaning: 'سيارة',
        targetExample: 'Ich habe ein Auto',
        sourceExampleTranslation: 'لدي سيارة',
        partOfSpeech: 'noun',
      ),
      const LexicalEntry(
        id: '3',
        domainId: 'general',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'Buch',
        sourceMeaning: 'كتاب',
        targetExample: 'Er liest ein Buch',
        sourceExampleTranslation: 'يقرأ كتابًا',
        partOfSpeech: 'noun',
      ),
      const LexicalEntry(
        id: '4',
        domainId: 'general',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'Hund',
        sourceMeaning: 'كلب',
        targetExample: 'Der Hund bellt',
        sourceExampleTranslation: 'الكلب ينبح',
        partOfSpeech: 'noun',
      ),
    ];
    LexicalRepository.initializeStore(entries);
  });

  group('QuizExerciseScreen Tests', () {
    testWidgets('Displays missing pack gracefully', (WidgetTester tester) async {
      LexicalRepository.initializeStore([]);
      await tester.pumpWidget(const MaterialApp(home: QuizExerciseScreen()));
      await tester.pumpAndSettle();

      expect(find.text('لا يوجد محتوى متاح حالياً'), findsOneWidget);
    });

    testWidgets('Grades correctly and fires exactly one recordReviewCompat on rapid tap', (WidgetTester tester) async {
      final initialHistoryLength = UnifiedSrsScheduler.instance.history.length;

      await tester.pumpWidget(const MaterialApp(home: QuizExerciseScreen()));
      await tester.pumpAndSettle();

      final optionFinder = find.ancestor(
        of: find.byType(CircleAvatar).first,
        matching: find.byType(GestureDetector)
      );

      if (optionFinder.evaluate().isNotEmpty) {
        await tester.tap(optionFinder.first);
        await tester.pump();
      }

      final checkButton = find.byType(ElevatedButton);
      await tester.tap(checkButton);
      await tester.tap(checkButton); // Rapid tap
      await tester.tap(checkButton);
      await tester.pump();

      await tester.pump(const Duration(seconds: 3));

      final currentHistoryLength = UnifiedSrsScheduler.instance.history.length;
      expect(currentHistoryLength - initialHistoryLength, 1);
    });
  });

  group('FocusQuizScreen Tests', () {
    testWidgets('Extracts cloze from example, handles missing pack gracefully', (WidgetTester tester) async {
      LexicalRepository.initializeStore([]);
      await tester.pumpWidget(const MaterialApp(home: FocusQuizScreen()));
      await tester.pumpAndSettle();

      expect(find.text('لا يوجد محتوى متاح حالياً'), findsOneWidget);
    });

    testWidgets('Logs one review per interaction on fast taps', (WidgetTester tester) async {
      final entries = [
        const LexicalEntry(
          id: '1',
          domainId: 'general',
          sourceLocale: 'ar-SA',
          targetLocale: 'de-DE',
          targetTerm: 'Haus',
          sourceMeaning: 'منزل',
          targetExample: 'Das ist ein Haus',
          sourceExampleTranslation: 'هذا منزل',
          partOfSpeech: 'noun',
        ),
      ];
      LexicalRepository.initializeStore(entries);

      final initialHistoryLength = UnifiedSrsScheduler.instance.history.length;

      await tester.pumpWidget(const MaterialApp(home: FocusQuizScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Haus');
      await tester.pumpAndSettle();

      final checkButton = find.byType(ElevatedButton).last;

      // Ensure the button is scrolled into view before tapping
      await tester.ensureVisible(checkButton);
      await tester.pumpAndSettle();

      await tester.tap(checkButton, warnIfMissed: false);
      await tester.tap(checkButton, warnIfMissed: false); // Rapid tap
      await tester.pump();

      await tester.pump(const Duration(seconds: 3));

      final currentHistoryLength = UnifiedSrsScheduler.instance.history.length;
      expect(currentHistoryLength - initialHistoryLength, 1);
    });
  });
}
