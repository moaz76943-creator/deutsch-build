import 'dart:math';

/// Reading speed proficiency tier.
enum ReadingFluencyTier { beginner, intermediate, fluent, nativeLike }

/// Calculated reading speed metrics across scripts.
class ReadingSpeedMetrics {
  final double wordsPerMinute;
  final double charactersPerMinute;
  final ReadingFluencyTier tier;
  final String feedback;

  const ReadingSpeedMetrics({
    required this.wordsPerMinute,
    required this.charactersPerMinute,
    required this.tier,
    required this.feedback,
  });
}

/// Evaluates reading speed across Latin, Arabic, and CJK text.
class ReadingSpeedBenchmark {
  const ReadingSpeedBenchmark();

  /// Calculates reading metrics given elapsed duration and language script context.
  ReadingSpeedMetrics evaluate({
    required String text,
    required Duration timeSpent,
    bool isCjk = false,
  }) {
    final minutes = max(timeSpent.inMilliseconds / 60000.0, 0.01);
    final rawLength = text.trim().length;

    if (isCjk) {
      // In CJK, evaluate Characters Per Minute (CPM)
      final cpm = rawLength / minutes;
      ReadingFluencyTier tier;
      if (cpm >= 300) {
        tier = ReadingFluencyTier.nativeLike;
      } else if (cpm >= 180) {
        tier = ReadingFluencyTier.fluent;
      } else if (cpm >= 100) {
        tier = ReadingFluencyTier.intermediate;
      } else {
        tier = ReadingFluencyTier.beginner;
      }

      return ReadingSpeedMetrics(
        wordsPerMinute: double.parse((cpm / 2.0).toStringAsFixed(1)), // Approximated
        charactersPerMinute: double.parse(cpm.toStringAsFixed(1)),
        tier: tier,
        feedback: 'سرعة القراءة بالرموز CJK: ${cpm.toStringAsFixed(0)} رمز/دقيقة.',
      );
    } else {
      // Space-delimited languages (Arabic, German, English)
      final wordsCount = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      final wpm = wordsCount / minutes;
      final cpm = rawLength / minutes;

      ReadingFluencyTier tier;
      if (wpm >= 180) {
        tier = ReadingFluencyTier.nativeLike;
      } else if (wpm >= 120) {
        tier = ReadingFluencyTier.fluent;
      } else if (wpm >= 70) {
        tier = ReadingFluencyTier.intermediate;
      } else {
        tier = ReadingFluencyTier.beginner;
      }

      return ReadingSpeedMetrics(
        wordsPerMinute: double.parse(wpm.toStringAsFixed(1)),
        charactersPerMinute: double.parse(cpm.toStringAsFixed(1)),
        tier: tier,
        feedback: 'معدل القراءة: ${wpm.toStringAsFixed(0)} كلمة/دقيقة.',
      );
    }
  }
}
