class CognitiveMetricRecord {
  final String sessionEventId;
  final String contentKey;
  final Duration responseLatency; // زمن الإجابة بدقة
  final int hesitationTaps; // عدد مرات التردد أو تغيير الخيار
  final bool isCorrect;
  final DateTime recordedAt;
  final String? targetLanguageCode;
  final bool isCefrVerified;
  final double reviewDifficulty;

  const CognitiveMetricRecord({
    required this.sessionEventId,
    required this.contentKey,
    required this.responseLatency,
    this.hesitationTaps = 0,
    required this.isCorrect,
    required this.recordedAt,
    this.targetLanguageCode,
    this.isCefrVerified = false,
    this.reviewDifficulty = 0.0,
  });

  /// حساب مؤشر الجهد الإدراكي (من 0.0 إلى 1.0)
  double get cognitiveStrainIndex {
    double strain = 0.0;

    // Normalize negative values safely
    final latencyMs =
        responseLatency.inMilliseconds < 0 ? 0 : responseLatency.inMilliseconds;
    final taps = hesitationTaps < 0 ? 0 : hesitationTaps;
    final safeReviewDifficulty = reviewDifficulty.isNaN || reviewDifficulty < 0 ? 0.0 : reviewDifficulty;

    // استجابة بطيئة تزيد عن 5 ثوانٍ تشير إلى إجهاد أو صعوبة
    if (latencyMs > 5000) {
      strain += 0.4;
    } else if (latencyMs > 3000) {
      strain += 0.2;
    }

    // إضافة تأثير صعوبة المراجعة
    strain += (safeReviewDifficulty.clamp(0.0, 1.0) * 0.2);

    // التردد أثناء الإجابة
    if (taps > 1) {
      strain += 0.3;
    }

    // الخطأ في الإجابة
    if (!isCorrect) {
      strain += 0.3;
    }

    // Check for NaN if strain was a double from other calcs, but here it's simple addition.
    // .clamp natively handles basic bounds.
    if (strain.isNaN) {
      return 1.0; // Fail-safe fallback to high strain on NaN
    }

    return strain.clamp(0.0, 1.0);
  }
}
