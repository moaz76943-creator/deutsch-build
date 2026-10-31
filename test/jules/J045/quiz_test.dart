import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/quiz_exercise_screen.dart';
import 'package:deutsch_bilarabi/screens/focus_quiz_screen.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/srs_scheduler.dart';

void main() {
  setUp(() {
    // Clear SRS history by re-initializing or just relying on length checks relative to start
    // We will clear LexicalRepository
    LexicalRepository.initializeStore([]);
  });

  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      home: child,
      // Suppress debug banner
      debugShowCheckedModeBanner: false,
    );
  }

  group('J045 - Universal Interactive Quiz Runtime', () {
    testWidgets('QuizExerciseScreen shows empty state when missing packs', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const QuizExerciseScreen()));
      await tester.pumpAndSettle();

      expect(find.text('لا يوجد محتوى كافٍ (4 مفردات على الأقل)'), findsOneWidget);
    });

    testWidgets('FocusQuizScreen shows empty state when missing packs', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const FocusQuizScreen()));
      await tester.pumpAndSettle();

      expect(find.text('لا يوجد محتوى متاح'), findsOneWidget);
    });

    testWidgets('QuizExerciseScreen - Grading and duplicate tap prevention', (WidgetTester tester) async {
      final entries = [
        const LexicalEntry(id: '1', domainId: 'd1', sourceLocale: 'ar', targetLocale: 'de', targetTerm: 'Haus', sourceMeaning: 'منزل', targetExample: '', sourceExampleTranslation: '', partOfSpeech: 'noun'),
        const LexicalEntry(id: '2', domainId: 'd1', sourceLocale: 'ar', targetLocale: 'de', targetTerm: 'Auto', sourceMeaning: 'سيارة', targetExample: '', sourceExampleTranslation: '', partOfSpeech: 'noun'),
        const LexicalEntry(id: '3', domainId: 'd1', sourceLocale: 'ar', targetLocale: 'de', targetTerm: 'Katze', sourceMeaning: 'قطة', targetExample: '', sourceExampleTranslation: '', partOfSpeech: 'noun'),
        const LexicalEntry(id: '4', domainId: 'd1', sourceLocale: 'ar', targetLocale: 'de', targetTerm: 'Hund', sourceMeaning: 'كلب', targetExample: '', sourceExampleTranslation: '', partOfSpeech: 'noun'),
      ];
      LexicalRepository.initializeStore(entries);

      final initialHistoryLength = UnifiedSrsScheduler.instance.history.length;

      await tester.pumpWidget(createWidgetUnderTest(const QuizExerciseScreen()));
      await tester.pumpAndSettle();

      // Find the first option and tap it
      final firstOption = find.byType(CircleAvatar).first;
      await tester.tap(firstOption);
      await tester.pump();

      // Tap submit rapidly multiple times
      final submitButton = find.text('تحقق من الإجابة');
      await tester.tap(submitButton);
      await tester.tap(submitButton);
      await tester.tap(submitButton);

      // Verify only 1 review transaction was recorded
      expect(UnifiedSrsScheduler.instance.history.length, initialHistoryLength + 1);

      // Verify the rating is either 0 or 2 (depending on if they got it right, which is random here)
      final review = UnifiedSrsScheduler.instance.history.last;
      expect([0, 2].contains(review.rating), isTrue);

      // Wait for delay and advance
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('FocusQuizScreen - Grading, Typing, and duplicate tap prevention', (WidgetTester tester) async {
      final entries = [
        const LexicalEntry(id: '1', domainId: 'd1', sourceLocale: 'ar', targetLocale: 'de', targetTerm: 'Apfel', sourceMeaning: 'تفاحة', targetExample: 'Ich esse einen Apfel', sourceExampleTranslation: '', partOfSpeech: 'noun'),
      ];
      LexicalRepository.initializeStore(entries);

      final initialHistoryLength = UnifiedSrsScheduler.instance.history.length;

      await tester.pumpWidget(createWidgetUnderTest(const FocusQuizScreen()));
      await tester.pumpAndSettle();

      // Type the correct answer
      await tester.enterText(find.byType(TextField), 'Apfel');
      await tester.pump();

      // Tap submit multiple times
      final submitButton = find.text('تحقق من الإجابة بهدوء');
      await tester.tap(submitButton);
      await tester.tap(submitButton);

      // Verify only 1 review transaction
      expect(UnifiedSrsScheduler.instance.history.length, initialHistoryLength + 1);
      final review = UnifiedSrsScheduler.instance.history.last;
      expect(review.rating, 2); // Should be correct

      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('RTL and LTR Directionality applied correctly for pairs', (WidgetTester tester) async {
      final entries = [
        const LexicalEntry(id: '1', domainId: 'd1', sourceLocale: 'de', targetLocale: 'ar', targetTerm: 'سيارة', sourceMeaning: 'Auto', targetExample: '', sourceExampleTranslation: '', partOfSpeech: 'noun'),
      ];
      LexicalRepository.initializeStore(entries);

      await tester.pumpWidget(createWidgetUnderTest(const FocusQuizScreen(sourceLocale: 'de', targetLocale: 'ar')));
      await tester.pumpAndSettle();

      // Find the TextField, its ancestor Directionality should be RTL
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      final directionality = tester.widget<Directionality>(
        find.ancestor(of: textField, matching: find.byType(Directionality)).first
      );

      expect(directionality.textDirection, TextDirection.rtl);
    });
  });
}
