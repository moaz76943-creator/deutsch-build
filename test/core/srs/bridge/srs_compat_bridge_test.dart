import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SRS compatibility persistence contract', () {
    test('unbound compatibility bridge cannot acknowledge a review', () async {
      final bridge = SrsCompatBridge();
      await expectLater(
        bridge.recordReviewCompat(
          contentKey: 'VOCAB-DE-001',
          rating: 2,
          sourceIso: 'de',
          targetIso: 'ar',
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
