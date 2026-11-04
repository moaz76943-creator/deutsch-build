class CefrA1WritingPart2ShortLetterScorer {
  int evaluateLetter(String text) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (words >= 30) return 15;
    if (words >= 20) return 10;
    return 5;
  }
}
