class CognitiveMetricRecord {
  final String sessionEventId;
  final String contentKey;
  final Duration responseLatency; // زمن الإجابة بدقة
<<<<<<< HEAD
  final int hesitationTaps; // عدد مرات التردد أو تغيير الخيار
  final bool isCorrect;
  final DateTime recordedAt;
  final String? targetLanguageCode;
=======
  final int hesitationTaps;        // عدد مرات التردد أو تغيير الخيار
  final bool isCorrect;
  final DateTime recordedAt;
>>>>>>> origin/staging/v2-full-platform-1792367411258400957

  const CognitiveMetricRecord({
    required this.sessionEventId,
    required this.contentKey,
    required this.responseLatency,
    this.hesitationTaps = 0,
    required this.isCorrect,
    required this.recordedAt,
<<<<<<< HEAD
    this.targetLanguageCode,
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
  });

  /// حساب مؤشر الجهد الإدراكي (من 0.0 إلى 1.0)
  double get cognitiveStrainIndex {
    double strain = 0.0;
<<<<<<< HEAD

    // Normalize negative values safely
    final latencyMs =
        responseLatency.inMilliseconds < 0 ? 0 : responseLatency.inMilliseconds;
    final taps = hesitationTaps < 0 ? 0 : hesitationTaps;

    // استجابة بطيئة تزيد عن 5 ثوانٍ تشير إلى إجهاد أو صعوبة
    if (latencyMs > 5000) {
      strain += 0.4;
    } else if (latencyMs > 3000) {
=======
    // استجابة بطيئة تزيد عن 5 ثوانٍ تشير إلى إجهاد أو صعوبة
    if (responseLatency.inMilliseconds > 5000) {
      strain += 0.4;
    } else if (responseLatency.inMilliseconds > 3000) {
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
      strain += 0.2;
    }

    // التردد أثناء الإجابة
<<<<<<< HEAD
    if (taps > 1) {
=======
    if (hesitationTaps > 1) {
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
      strain += 0.3;
    }

    // الخطأ في الإجابة
    if (!isCorrect) {
      strain += 0.3;
    }

<<<<<<< HEAD
    // Check for NaN if strain was a double from other calcs, but here it's simple addition.
    // .clamp natively handles basic bounds.
    if (strain.isNaN) {
      return 1.0; // Fail-safe fallback to high strain on NaN
    }

=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    return strain.clamp(0.0, 1.0);
  }
}
