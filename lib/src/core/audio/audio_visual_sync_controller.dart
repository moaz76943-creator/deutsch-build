import 'dart:math';

/// Timing boundary for an individual syllable or phoneme segment.
class SyllableTimestamp {
  final String text;
  final int startMs;
  final int endMs;
  final bool isStressed;

  const SyllableTimestamp({
    required this.text,
    required this.startMs,
    required this.endMs,
    this.isStressed = false,
  });

  bool containsPosition(int positionMs) {
    return positionMs >= startMs && positionMs <= endMs;
  }
}

/// Coordinates real-time synchronization between audio playback progress and visual highlights.
class AudioVisualSyncController {
  final List<SyllableTimestamp> syllables;
  final Duration totalDuration;

  AudioVisualSyncController({
    required this.syllables,
    required this.totalDuration,
  });

  /// Finds the currently active syllable index given playback position in milliseconds.
  int getActiveSyllableIndex(int positionMs) {
    if (syllables.isEmpty) return -1;

    for (int i = 0; i < syllables.length; i++) {
      if (syllables[i].containsPosition(positionMs)) {
        return i;
      }
    }

    // Fallback: If position is past the last syllable, highlight the last one
    if (positionMs >= syllables.last.endMs) {
      return syllables.length - 1;
    }

    return 0;
  }

  /// Generates normalized amplitude bars (0.1 to 1.0) for visualizer.
  List<double> generateWaveformEnvelope({int barCount = 24, int? activeIndex}) {
    final bars = <double>[];
    for (int i = 0; i < barCount; i++) {
      final double progress = i / barCount;
      final double baseHeight = 0.3 + 0.6 * sin(progress * pi);
      final double activeBoost = (activeIndex != null && (i / barCount * syllables.length).floor() == activeIndex)
          ? 0.3
          : 0.0;
      bars.add((baseHeight + activeBoost).clamp(0.1, 1.0));
    }
    return bars;
  }
}
