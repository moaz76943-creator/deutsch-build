import 'dart:async';

import 'package:deutsch_bilarabi/features/flashcards/learning_review_coordinator.dart';
import 'package:deutsch_bilarabi/screens/focus_quiz_screen.dart';
import 'package:deutsch_bilarabi/screens/quiz_exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LearningReviewCoordinator fakeCoordinator() {
    return LearningReviewCoordinator(
      writer: ({
        required learnerContentId,
        required targetLanguageCode,
        required grade,
      }) async {},
    );
  }

  testWidgets('quiz shows a non-blank verified-content fallback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QuizExerciseScreen(
          sourceLanguageCode: 'ar',
          targetLanguageCode: 'de',
          reviewCoordinator: fakeCoordinator(),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('موثّق'), findsOneWidget);
  });

  testWidgets('quiz ignores stale loader completion after disposal', (tester) async {
    final pending = Completer<List<Map<String, dynamic>>>();
    await tester.pumpWidget(
      MaterialApp(
        home: QuizExerciseScreen(
          conceptId: 'concept.home',
          sourceLanguageCode: 'ar',
          targetLanguageCode: 'de',
          exerciseLoader: (_, __) => pending.future,
          reviewCoordinator: fakeCoordinator(),
        ),
      ),
    );
    await tester.pump();

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    pending.complete(<Map<String, dynamic>>[
      <String, dynamic>{
        'prompt': 'Artikel für Haus',
        'correct_answer': 'das',
        'distractors_json': '["der","die"]',
      },
    ]);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('focus quiz never falls back to fabricated cloze content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FocusQuizScreen(
          sourceLanguageCode: 'ar',
          targetLanguageCode: 'fr',
          reviewCoordinator: fakeCoordinator(),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('موثّق'), findsOneWidget);
    expect(find.text('Ich ___ ein Buch.'), findsNothing);
  });
}
