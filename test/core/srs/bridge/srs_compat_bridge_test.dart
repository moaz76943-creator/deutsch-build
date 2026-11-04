import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/spaced_repetition.dart';

void main() {
  group('SRS Authority Unification Tests', () {
    test('legacy review cannot acknowledge success without durable storage',
        () async {
      final service = SpacedRepetitionService.instance;

      await expectLater(
        service.submitResult(
          cardId: 'VOCAB-DE-001',
          isCorrect: true,
          difficulty: 2,
        ),
        throwsStateError,
      );
    });
  });
}
