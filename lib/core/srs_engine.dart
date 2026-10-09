/// تطبيق خوارزمية SuperMemo-2 (SM-2) القياسية الرياضية الموثقة
/// q: التقييم من 0 إلى 5 (0-2: فشل / إعادة، 3: مقبول، 4: جيد، 5: ممتاز)
/// EF: معامل السهولة (Ease Factor) - الحد الأدنى 1.3
/// I: الفاصل الزمني بالأيام (Interval)
class SrsEngine {
  static Map<String, dynamic> calculateNextReview({
    required int grade, // 0 to 5
    required int repetitions,
    required double previousEaseFactor,
    required int previousInterval,
  }) {
    int nextRepetitions = repetitions;
    int nextInterval = previousInterval;
    double nextEaseFactor = previousEaseFactor;

    if (grade >= 3) {
      if (repetitions == 0) {
        nextInterval = 1;
      } else if (repetitions == 1) {
        nextInterval = 6;
      } else {
        nextInterval = (previousInterval * previousEaseFactor).round();
      }
      nextRepetitions += 1;
    } else {
      nextRepetitions = 0;
      nextInterval = 1;
    }

    // معادلة SM-2 الرسمية لتحديث معامل السهولة
    nextEaseFactor = previousEaseFactor + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02));
    if (nextEaseFactor < 1.3) {
      nextEaseFactor = 1.3;
    }

    return {
      'repetitions': nextRepetitions,
      'interval': nextInterval,
      'easeFactor': double.parse(nextEaseFactor.toStringAsFixed(2)),
    };
  }
}
