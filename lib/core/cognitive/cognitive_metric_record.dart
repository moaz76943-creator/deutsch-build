class CognitiveMetricRecord {
  final String sessionEventId;
  final String contentKey;
  final Duration responseLatency; // زمن الإجابة بدقة
  final int hesitationTaps;        // عدد مرات التردد أو تغيير الخيار
  final bool isCorrect;
  final DateTime recordedAt;

  final String languagePair;
  final String? cefrLevel;
  final bool isCefrVerified;
  final double reviewDifficulty;

  const CognitiveMetricRecord({
    required this.sessionEventId,
    required this.contentKey,
    required this.responseLatency,
    this.hesitationTaps = 0,
    required this.isCorrect,
    required this.recordedAt,
    this.languagePair = 'default',
    this.cefrLevel,
    this.isCefrVerified = false,
    this.reviewDifficulty = 0.0,
  });

  /// حساب مؤشر الجهد الإدراكي (من 0.0 إلى 1.0)
  double get cognitiveStrainIndex {
    double strain = 0.0;

    int latencyMs = responseLatency.inMilliseconds;
    if (latencyMs < 0) latencyMs = 0;

    int taps = hesitationTaps;
    if (taps < 0) taps = 0;

    // استجابة بطيئة تزيد عن 5 ثوانٍ تشير إلى إجهاد أو صعوبة
    if (latencyMs > 5000) {
      strain += 0.4;
    } else if (latencyMs > 3000) {
      strain += 0.2;
    }

    // التردد أثناء الإجابة
    if (taps > 1) {
      strain += 0.3;
    }

    // الخطأ في الإجابة
    if (!isCorrect) {
      strain += 0.3;
    }

    double difficulty = reviewDifficulty;
    if (difficulty.isNaN) {
      difficulty = 0.0;
    } else if (difficulty < 0.0) {
      difficulty = 0.0;
    }

    strain += (difficulty * 0.2); // Incorporate review difficulty safely

    return strain.clamp(0.0, 1.0);
  }
}
