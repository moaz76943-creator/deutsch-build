import 'dart:async';

import 'package:deutsch_bilarabi/features/flashcards/learning_review_coordinator.dart';
import 'package:deutsch_bilarabi/screens/focus_quiz_screen.dart';
import 'package:deutsch_bilarabi/features/wordbit/ui/wordbit_carousel_screen.dart';
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

  testWidgets('WordBit final review ends session without active grade buttons',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var writes = 0;
    final coordinator = LearningReviewCoordinator(
      writer: ({
        required learnerContentId,
        required targetLanguageCode,
        required grade,
      }) async {
        writes++;
      },
    );
    await tester.pumpWidget(MaterialApp(
      home: WordBitCarouselScreen(
        sourceLanguageCode: 'ar',
        targetLanguageCode: 'de',
        reviewCoordinator: coordinator,
        cardLoader: (_) async => <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'lex.de.1',
            'surface': 'Haus',
            'language_code': 'de',
            'translation_ar': 'منزل',
            'translation_language_code': 'ar',
          },
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('سهل'), findsOneWidget);
    await tester.tap(find.text('سهل'));
    await tester.pumpAndSettle();
    expect(writes, 1);
    expect(find.text('سهل'), findsNothing);
    expect(find.textContaining('اكتملت البطاقات'), findsOneWidget);
  });

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
