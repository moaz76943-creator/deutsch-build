import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/multimodal_dialogue/shadowing_teleprompter_scroller.dart';

void main() {
  group('ShadowingTeleprompterScroller Unit Tests (N070)', () {
    final scroller = ShadowingTeleprompterScroller();

    setUp(() {
      scroller.setScript([
        const MapEntry('Gu-', 0.5),
        const MapEntry('ten ', 1.0),
        const MapEntry('Mor-', 1.5),
        const MapEntry('gen!', 2.0),
      ]);
    });

    test('Tracks active syllable precisely matching playhead time', () {
      expect(scroller.getActiveSyllableIndex(0.6), equals(0)); // 'Gu-'
      expect(scroller.getActiveSyllableIndex(1.2), equals(1)); // 'ten '
      expect(scroller.getActiveSyllableIndex(1.8), equals(2)); // 'Mor-'
      expect(scroller.getActiveSyllableIndex(2.5), equals(3)); // 'gen!'
    });

    test('Calculates smooth scroll progression percentage', () {
      expect(scroller.getScrollProgress(1.0), equals(50.0));
      expect(scroller.getScrollProgress(2.0), equals(100.0));
      expect(scroller.getScrollProgress(3.0), equals(100.0)); // Clamped
    });

    test('Empty script handles safely', () {
      final emptyScroller = ShadowingTeleprompterScroller();
      expect(emptyScroller.getActiveSyllableIndex(1.0), equals(-1));
      expect(emptyScroller.getScrollProgress(1.0), equals(0.0));
    });
  });
}
