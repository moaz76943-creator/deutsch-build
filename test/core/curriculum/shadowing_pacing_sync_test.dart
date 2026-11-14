import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/shadowing_pacing_sync.dart';

void main() {
  group('ShadowingPacingSynchronizer Unit Tests (N035)', () {
    const synchronizer = ShadowingPacingSynchronizer(targetLeadTimeSec: 0.25);

    test('Evaluates near-perfect shadowing sync and maintains 1.0x playback', () {
      final anchors = [
        const AlignmentAnchor(phoneme: 'm', referenceTimeSec: 1.00, learnerTimeSec: 1.26, pitchDeltaHz: 2.1),
        const AlignmentAnchor(phoneme: 'a', referenceTimeSec: 1.20, learnerTimeSec: 1.45, pitchDeltaHz: 3.5),
        const AlignmentAnchor(phoneme: 'n', referenceTimeSec: 1.40, learnerTimeSec: 1.66, pitchDeltaHz: 1.8),
      ];

      final metrics = synchronizer.synchronizeCadence(anchors);
      expect(metrics['isSynchronous'], isTrue);
      expect(metrics['cadenceSyncScore'], greaterThan(85.0));
      expect(metrics['recommendedPlaybackSpeed'], inInclusiveRange(0.95, 1.05));
    });

    test('Learner severe lag triggers dynamic slowing of model playback', () {
      final laggingAnchors = [
        const AlignmentAnchor(phoneme: 'g', referenceTimeSec: 1.0, learnerTimeSec: 1.95, pitchDeltaHz: 15.0),
        const AlignmentAnchor(phoneme: 'u', referenceTimeSec: 1.3, learnerTimeSec: 2.30, pitchDeltaHz: 12.0),
      ];

      final metrics = synchronizer.synchronizeCadence(laggingAnchors);
      expect(metrics['isSynchronous'], isFalse);
      expect(metrics['recommendedPlaybackSpeed'], lessThan(1.0));
      expect(metrics['recommendedPlaybackSpeed'], greaterThanOrEqualTo(0.80));
    });

    test('Empty anchors handles safely', () {
      final metrics = synchronizer.synchronizeCadence([]);
      expect(metrics['isSynchronous'], isFalse);
      expect(metrics['recommendedPlaybackSpeed'], equals(1.0));
    });
  });
}
