import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/study_session/domain/models.dart';
import 'package:deutsch_bilarabi/features/study_session/domain/study_session.dart';

void main() {
  group('StudySession Domain Tests', () {
    test('Session lifecycle - start to end-of-queue', () {
      final session = StudySession(
        sessionId: 'test-1',
        startTime: DateTime.now(),
      );

      final newCards = [
        const Flashcard(id: '1', conceptId: 'c1', german: 'Hallo', arabic: 'مرحبا'),
        const Flashcard(id: '2', conceptId: 'c2', german: 'Tschüss', arabic: 'وداعا'),
      ];

      session.startSession(dueCards: [], newCards: newCards);

      expect(session.activeQueue.length, 2);
      expect(session.currentCardIndex, 0);

      // Answer first card - incorrect
      final nextCard1 = session.submitAnswer(card: newCards[0], rating: Rating.again);
      expect(nextCard1, newCards[1]);
      // The incorrect card should be added to the end of the queue
      expect(session.activeQueue.length, 3);
      expect(session.completedCards.length, 0);

      // Answer second card - correct
      final nextCard2 = session.submitAnswer(card: newCards[1], rating: Rating.good);
      expect(nextCard2, newCards[0]); // Returns to the first card that was added to the end
      expect(session.completedCards.length, 1);

      // Answer the re-queued first card - correct
      final nextCard3 = session.submitAnswer(card: newCards[0], rating: Rating.easy);
      expect(nextCard3, isNull); // Session finished
      expect(session.completedCards.length, 2);

      // Verify result
      final result = session.calculateSessionResult();
      expect(result.totalReviewed, 3); // 3 total reviews (c1, c2, c1)
      expect(result.accuracyPercentage, (2 / 3) * 100);
    });

    test('Quota enforcement - capping daily cards', () {
      final session = StudySession(
        sessionId: 'test-2',
        startTime: DateTime.now(),
        dailyNewCardsQuota: 2,
        dailyReviewLimit: 3,
      );

      final dueCards = List.generate(10, (index) => Flashcard(id: 'due_$index', conceptId: 'c_$index', german: 'G', arabic: 'A'));
      final newCards = List.generate(5, (index) => Flashcard(id: 'new_$index', conceptId: 'n_$index', german: 'G', arabic: 'A'));

      session.startSession(dueCards: dueCards, newCards: newCards);

      // Should take 3 due cards and 2 new cards
      expect(session.activeQueue.length, 5);

      final queuedDue = session.activeQueue.where((c) => c.id.startsWith('due_')).toList();
      final queuedNew = session.activeQueue.where((c) => c.id.startsWith('new_')).toList();

      expect(queuedDue.length, 3);
      expect(queuedNew.length, 2);
    });
  });
}
