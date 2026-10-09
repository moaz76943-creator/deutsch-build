class AppRatingEvaluator {
  static bool isGoldenMomentForReview({
    required int consecutiveStreakDays,
    required int masteredWordsCount,
    required bool alreadyPrompted,
  }) {
    if (alreadyPrompted) return false;
    // طلب التقييم فقط عند وصول المتعلم لنشوة الإنجاز
    return consecutiveStreakDays >= 7 || masteredWordsCount >= 100;
  }
}
