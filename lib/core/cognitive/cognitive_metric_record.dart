class CognitiveMetricRecord {
  final String sessionEventId;
  final String contentKey;
  final Duration responseLatency; // زمن الإجابة بدقة
  final int hesitationTaps;        // عدد مرات التردد أو تغيير الخيار
  final bool isCorrect;
  final DateTime recordedAt;

  // New optional fields
  final String pairKey;
  final int? srsGrade;
  final String? cefrLevel;
  final bool cefrVerified;

  const CognitiveMetricRecord({
    required this.sessionEventId,
    required this.contentKey,
    required this.responseLatency,
    this.hesitationTaps = 0,
    required this.isCorrect,
    required this.recordedAt,
    this.pairKey = 'default',
    this.srsGrade,
    this.cefrLevel,
    this.cefrVerified = false,
  });

  bool get isMalformed {
    if (responseLatency.inMilliseconds < 0) return true;
    if (hesitationTaps < 0) return true;
    if (srsGrade != null && (srsGrade! < 0 || srsGrade! > 3)) return true;
    return false;
  }

  /// حساب مؤشر الجهد الإدراكي (من 0.0 إلى 1.0)
  double get cognitiveStrainIndex {
    if (isMalformed) return 1.0;

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

    // تأثير تقييم التكرار المتباعد
    if (srsGrade != null) {
      if (srsGrade == 0) {
        strain += 0.4;
      } else if (srsGrade == 1) {
        strain += 0.2;
      } else if (srsGrade == 2) {
        strain -= 0.1;
      } else if (srsGrade == 3) {
        strain -= 0.2;
      }
    }

    return strain.clamp(0.0, 1.0);
  }
}
