import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/study_session/domain/study_session.dart';
import 'package:deutsch_bilarabi/features/study_session/domain/models.dart';
import 'package:deutsch_bilarabi/features/study_session/domain/cognitive_overload_shield.dart';
import 'package:deutsch_bilarabi/features/study_session/controller/study_session_controller.dart';

void main() {
  group('StudySessionController Tests', () {
    test('Controller handles normal session flow without pausing when accuracy is high', () {
      final session = StudySession(
        sessionId: 'test-session',
        startTime: DateTime.now(),
      );
      final shield = CognitiveOverloadShield(
        thresholdAccuracy: 0.60,
        minimumAnswersBeforeCheck: 3,
      );
      final controller = StudySessionController(
        session: session,
        shield: shield,
      );

      final cards = [
        const Flashcard(
          id: '1',
          conceptId: 'c1',
          german: 'Hallo',
          arabic: 'مرحبا',
        ),
        const Flashcard(
          id: '2',
          conceptId: 'c2',
          german: 'Tschüss',
          arabic: 'وداعا',
        ),
        const Flashcard(
          id: '3',
          conceptId: 'c3',
          german: 'Bitte',
          arabic: 'رجاء',
        ),
      ];

      controller.startSession(dueCards: cards, newCards: []);

      expect(controller.isPaused, isFalse);
      expect(controller.interventionPrompt, isNull);

      controller.submitAnswer(Rating.good); // 1 correct, 1 total
      expect(controller.isPaused, isFalse);

      controller.submitAnswer(Rating.good); // 2 correct, 2 total
      expect(controller.isPaused, isFalse);

      controller.submitAnswer(
        Rating.good,
      ); // 3 correct, 3 total (100% accuracy)
      expect(controller.isPaused, isFalse);
    });

    test('Controller auto-pauses and shows calming prompt when accuracy drops below threshold', () {
      final session = StudySession(
        sessionId: 'test-session-2',
        startTime: DateTime.now(),
      );
      final shield = CognitiveOverloadShield(
        thresholdAccuracy: 0.60,
        minimumAnswersBeforeCheck: 3,
      );
      final controller = StudySessionController(
        session: session,
        shield: shield,
      );

      final cards = [
        const Flashcard(
          id: '1',
          conceptId: 'c1',
          german: 'Hallo',
          arabic: 'مرحبا',
        ),
        const Flashcard(
          id: '2',
          conceptId: 'c2',
          german: 'Tschüss',
          arabic: 'وداعا',
        ),
        const Flashcard(
          id: '3',
          conceptId: 'c3',
          german: 'Bitte',
          arabic: 'رجاء',
        ),
        const Flashcard(
          id: '4',
          conceptId: 'c4',
          german: 'Danke',
          arabic: 'شكرا',
        ),
      ];

      controller.startSession(dueCards: cards, newCards: []);

      controller.submitAnswer(Rating.again); // 0 correct, 1 total
      expect(controller.isPaused, isFalse); // Below minimum checks (3)

      controller.submitAnswer(Rating.again); // 0 correct, 2 total
      expect(controller.isPaused, isFalse); // Below minimum checks (3)

      controller.submitAnswer(Rating.again); // 0 correct, 3 total

      // Now minimum checks reached and accuracy is 0% (below 60%)
      expect(controller.isPaused, isTrue);
      expect(controller.interventionPrompt, isNotNull);
      expect(
        controller.interventionPrompt,
        contains('Let\'s take a short break'),
      );
    });

    test('resumeSession unpauses the controller and clears the prompt', () {
      final session = StudySession(
        sessionId: 'test-session-3',
        startTime: DateTime.now(),
      );
      final shield = CognitiveOverloadShield(
        thresholdAccuracy: 0.60,
        minimumAnswersBeforeCheck: 1,
      );
      final controller = StudySessionController(
        session: session,
        shield: shield,
      );

      final cards = [
        const Flashcard(
          id: '1',
          conceptId: 'c1',
          german: 'Hallo',
          arabic: 'مرحبا',
        ),
      ];

      controller.startSession(dueCards: cards, newCards: []);

      controller.submitAnswer(Rating.again); // 0 correct, 1 total (accuracy 0%)
      expect(controller.isPaused, isTrue);

      controller.resumeSession();
      expect(controller.isPaused, isFalse);
      expect(controller.interventionPrompt, isNull);
    });
  });
}
