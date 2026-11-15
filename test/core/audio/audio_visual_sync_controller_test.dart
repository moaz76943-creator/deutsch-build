import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/audio/audio_visual_sync_controller.dart';

void main() {
  group('AudioVisualSyncController Tests', () {
    late AudioVisualSyncController controller;

    setUp(() {
      controller = AudioVisualSyncController(
        totalDuration: const Duration(milliseconds: 1000),
        syllables: const [
          SyllableTimestamp(text: 'Kühl', startMs: 0, endMs: 450, isStressed: true),
          SyllableTimestamp(text: 'schrank', startMs: 451, endMs: 1000),
        ],
      );
    });

    test('Identifies active syllable index based on playback milliseconds', () {
      expect(controller.getActiveSyllableIndex(200), equals(0)); // In "Kühl"
      expect(controller.getActiveSyllableIndex(450), equals(0)); // Boundary of "Kühl"
      expect(controller.getActiveSyllableIndex(500), equals(1)); // In "schrank"
      expect(controller.getActiveSyllableIndex(900), equals(1)); // In "schrank"
    });

    test('Generates normalized waveform envelope bars', () {
      final bars = controller.generateWaveformEnvelope(barCount: 20, activeIndex: 0);

      expect(bars.length, equals(20));
      expect(bars.every((b) => b >= 0.1 && b <= 1.0), isTrue);
    });
  });
}
