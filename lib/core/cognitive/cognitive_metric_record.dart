class CognitiveMetricRecord {
  final String sessionEventId;
  final String contentKey;
  final Duration responseLatency; // زمن الإجابة بدقة
  final int hesitationTaps;        // عدد مرات التردد أو تغيير الخيار
  final bool isCorrect;
  final DateTime recordedAt;

  const CognitiveMetricRecord({
    required this.sessionEventId,
    required this.contentKey,
    required this.responseLatency,
    this.hesitationTaps = 0,
    required this.isCorrect,
    required this.recordedAt,
  });

  /// حساب مؤشر الجهد الإدراكي (من 0.0 إلى 1.0)
  double get cognitiveStrainIndex {
    double strain = 0.0;
    // استجابة بطيئة تزيد عن 5 ثوانٍ تشير إلى إجهاد أو صعوبة
    if (responseLatency.inMilliseconds > 5000) {
      strain += 0.4;
    } else if (responseLatency.inMilliseconds > 3000) {
      strain += 0.2;
    }

    // التردد أثناء الإجابة
    if (hesitationTaps > 1) {
      strain += 0.3;
    }

    // الخطأ في الإجابة
    if (!isCorrect) {
      strain += 0.3;
    }

    return strain.clamp(0.0, 1.0);
  }
}
