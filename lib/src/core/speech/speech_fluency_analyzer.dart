import 'dart:math';

/// Timing metrics for an individual spoken segment.
class SpeechSegmentDuration {
  final String text;
  final int durationMs;
  final bool isSilenceOrPause;

  const SpeechSegmentDuration({
    required this.text,
    required this.durationMs,
    this.isSilenceOrPause = false,
  });
}

/// Fluency assessment metrics for spoken sentence or continuous reading.
class FluencyReport {
  final double wordsPerMinute;
  final double phonationRatio; // Active speaking time vs total time (0.0 to 1.0)
  final int hesitationPausesCount; // Pauses > 250ms
  final double fluencyScore; // 0.0 to 100.0%
  final String feedback;

  const FluencyReport({
    required this.wordsPerMinute,
    required this.phonationRatio,
    required this.hesitationPausesCount,
    required this.fluencyScore,
    required this.feedback,
  });
}

/// Analyzes speaking rate, hesitations, and continuous speech flow.
class SpeechFluencyAnalyzer {
  final int hesitationThresholdMs; // Default 250ms

  const SpeechFluencyAnalyzer({this.hesitationThresholdMs = 250});

  /// Evaluates speech fluency across a timeline of words and pauses.
  FluencyReport evaluateFluency({
    required List<SpeechSegmentDuration> timeline,
    required int expectedWordsCount,
  }) {
    if (timeline.isEmpty || expectedWordsCount == 0) {
      return const FluencyReport(
        wordsPerMinute: 0.0,
        phonationRatio: 0.0,
        hesitationPausesCount: 0,
        fluencyScore: 0.0,
        feedback: 'لا توجد بيانات نطق كافية للتحليل.',
      );
    }

    int totalTimeMs = 0;
    int activePhonationMs = 0;
    int hesitationCount = 0;

    for (final seg in timeline) {
      totalTimeMs += seg.durationMs;
      if (seg.isSilenceOrPause) {
        if (seg.durationMs >= hesitationThresholdMs) {
          hesitationCount++;
        }
      } else {
        activePhonationMs += seg.durationMs;
      }
    }

    final double totalMinutes = max(totalTimeMs / 60000.0, 0.01);
    final double wpm = expectedWordsCount / totalMinutes;
    final double phonationRatio = totalTimeMs > 0 ? (activePhonationMs / totalTimeMs) : 0.0;

    // Normal conversational reading range: 100 - 150 WPM
    final double tempoScore = (1.0 - (wpm - 120.0).abs() / 120.0).clamp(0.2, 1.0) * 50.0;
    final double rhythmScore = (phonationRatio * 30.0);
    final double pausePenalty = max(0.0, hesitationCount * 4.0);

    final double totalScore = (tempoScore + rhythmScore + 20.0 - pausePenalty).clamp(0.0, 100.0);

    String feedback;
    if (totalScore >= 80) {
      feedback = 'ممتاز! طلاقة كلامية طبيعية وتدفق صوتي مسترسل وثابت.';
    } else if (totalScore >= 60) {
      feedback = 'جيد. السرعة مناسبة ولكن حاول تقليل وقفات التردد بين الكلمات.';
    } else {
      feedback = 'يحتاج لتحسين: هناك بطء ملحوظ أو وقفات توقف طويلة أثناء القراءة.';
    }

    return FluencyReport(
      wordsPerMinute: double.parse(wpm.toStringAsFixed(1)),
      phonationRatio: double.parse(phonationRatio.toStringAsFixed(2)),
      hesitationPausesCount: hesitationCount,
      fluencyScore: double.parse(totalScore.toStringAsFixed(1)),
      feedback: feedback,
    );
  }
}
