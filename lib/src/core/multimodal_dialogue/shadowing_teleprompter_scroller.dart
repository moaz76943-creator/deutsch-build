/// Syllable-level highlight coordinate for UI teleprompter rendering.
class SyllableAnchor {
  final String text;
  final double timestampSec;
  final bool isHighlighted;

  const SyllableAnchor({
    required this.text,
    required this.timestampSec,
    required this.isHighlighted,
  });
}

/// Computes dynamic scrolling position and active syllable highlighting for shadowing drills.
class ShadowingTeleprompterScroller {
  final List<SyllableAnchor> _anchors = [];

  void setScript(List<MapEntry<String, double>> syllablesWithTimes) {
    _anchors.clear();
    for (final entry in syllablesWithTimes) {
      _anchors.add(SyllableAnchor(text: entry.key, timestampSec: entry.value, isHighlighted: false));
    }
  }

  int get syllableCount => _anchors.length;

  /// Updates current playback progress and returns active syllable index.
  int getActiveSyllableIndex(double currentPlayheadSec) {
    if (_anchors.isEmpty) return -1;

    int activeIdx = 0;
    for (int i = 0; i < _anchors.length; i++) {
      if (currentPlayheadSec >= _anchors[i].timestampSec) {
        activeIdx = i;
      } else {
        break;
      }
    }
    return activeIdx;
  }

  /// Calculates scroll progress percentage (0.0 to 100.0).
  double getScrollProgress(double currentPlayheadSec) {
    if (_anchors.isEmpty) return 0.0;
    final lastTime = _anchors.last.timestampSec;
    if (lastTime <= 0) return 100.0;
    return ((currentPlayheadSec / lastTime) * 100.0).clamp(0.0, 100.0);
  }
}
