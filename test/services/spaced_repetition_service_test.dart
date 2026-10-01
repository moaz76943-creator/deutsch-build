import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/spaced_repetition_service.dart';

void main() {
  group('SpacedRepetitionService Tests', () {
    test('Initial review with good quality sets initial values', () {
      final item = SpacedRepetitionService.calculateNextReview(
        itemId: 'lesson1',
        quality: 4,
      );

      expect(item.id, 'lesson1');
      expect(item.repetitions, 1);
      expect(item.intervalDays, 1);
      // EF = 2.5 + (0.1 - (5 - 4) * (0.08 + (5 - 4) * 0.02))
      // EF = 2.5 + (0.1 - 1 * 0.1) = 2.5
      expect(item.ef, 2.5);

      final diff = item.nextReviewAt.difference(DateTime.now().toUtc());
      expect(diff.inDays, 0); // ~1 day depending on precision, but since it's exactly 1 day and difference rounds down, we check >= 23
      expect(diff.inHours, greaterThanOrEqualTo(23));
    });

    test('EF does not drop below 1.3', () {
      // Simulate low quality to drop EF
      var item = SpacedRepetitionService.calculateNextReview(
        itemId: 'lesson1',
        quality: 0,
      );

      // Keep dropping EF
      for (var i = 0; i < 10; i++) {
        item = SpacedRepetitionService.calculateNextReview(
          item: item,
          itemId: 'lesson1',
          quality: 0,
        );
      }

      expect(item.ef, 1.3);
    });

    test('Failed recall resets repetitions and interval to 1 day', () {
      // Setup an item with some successful history
      var item = SpacedRepetitionItem(
        id: 'lesson1',
        ef: 2.5,
        repetitions: 3,
        intervalDays: 10,
        nextReviewAt: DateTime.now().toUtc(),
      );

      // Failed recall (quality < 3)
      item = SpacedRepetitionService.calculateNextReview(
        item: item,
        itemId: 'lesson1',
        quality: 2,
      );

      expect(item.repetitions, 0);
      expect(item.intervalDays, 1);
    });

    test('Consecutive successful recalls multiply intervals', () {
      var item = SpacedRepetitionService.calculateNextReview(
        itemId: 'lesson1',
        quality: 4, // 1st rep -> interval 1
      );
      expect(item.intervalDays, 1);

      item = SpacedRepetitionService.calculateNextReview(
        item: item,
        itemId: 'lesson1',
        quality: 4, // 2nd rep -> interval 6
      );
      expect(item.intervalDays, 6);

      // ef is 2.5 after quality 4
      item = SpacedRepetitionService.calculateNextReview(
        item: item,
        itemId: 'lesson1',
        quality: 4, // 3rd rep -> interval 6 * 2.5 = 15
      );
      expect(item.intervalDays, 15);
    });

    test('Throws argument error for invalid quality', () {
      expect(
        () => SpacedRepetitionService.calculateNextReview(
          itemId: 'lesson1',
          quality: 6,
        ),
        throwsArgumentError,
      );

      expect(
        () => SpacedRepetitionService.calculateNextReview(
          itemId: 'lesson1',
          quality: -1,
        ),
        throwsArgumentError,
      );
    });
  });
}
