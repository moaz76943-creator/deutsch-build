class ReadingWpmBenchmarkEngine {
  const ReadingWpmBenchmarkEngine();

  double calculateCompoundAdjustedWpm({
    required String text,
    required int elapsedSeconds,
  }) {
    if (elapsedSeconds <= 0) return 0.0;
    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    int characterCount = 0;
    for (final w in words) {
      characterCount += w.length;
    }
    final double standardWords = characterCount / 5.0;
    final double minutes = elapsedSeconds / 60.0;
    return double.parse((standardWords / minutes).toStringAsFixed(1));
  }
}
