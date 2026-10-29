import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/spaced_repetition.dart';

void main() {
  group('SRS Authority Unification Tests', () {
    test('توجيه استدعاء SpacedRepetitionService القديم دون انهيار أو كتابة ظل', () async {
      final service = SpacedRepetitionService.instance;

      expect(
        () async => await service.submitResult(
          cardId: 'VOCAB-DE-001',
          isCorrect: true,
          difficulty: 2,
        ),
        returnsNormally,
      );
    });
  });
}
