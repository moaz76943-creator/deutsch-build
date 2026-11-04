import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('bound bridge acknowledges only after canonical writer completes',
        () async {
      final events = <String>[];
      final bridge = SrsCompatBridge(
        durableWriter: (event) async {
          expect(event.rating, 2);
          expect(event.languagePairKey, 'de_ar');
          events.add(event.reviewEventId);
        },
      );
      await bridge.recordReviewCompat(
        contentKey: 'VOCAB-DE-001',
        rating: 2,
        sourceIso: 'de',
        targetIso: 'ar',
      );
      expect(events, hasLength(1));
    });
  });
}
