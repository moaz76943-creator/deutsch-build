import 'package:shared_preferences/shared_preferences.dart';

class AppRatingEvaluator {
  static const String _kPromptedKey = 'app_rating_already_prompted';

  /// فحص معيار اللحظة الذهبية (7 أيام التزام أو إتقان 100 مفردة)
  static bool isGoldenMomentForReview({
    required int consecutiveStreakDays,
    required int masteredWordsCount,
    required bool alreadyPrompted,
  }) {
    if (alreadyPrompted) return false;
    return consecutiveStreakDays >= 7 || masteredWordsCount >= 100;
  }

  /// فحص ذاتي يقرأ التخزين المحلي لتحديد ما إذا حان وقت إظهار التقييم
  static Future<bool> shouldPromptReview({
    required int consecutiveStreakDays,
    required int masteredWordsCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final prompted = prefs.getBool(_kPromptedKey) ?? false;
    return isGoldenMomentForReview(
      consecutiveStreakDays: consecutiveStreakDays,
      masteredWordsCount: masteredWordsCount,
      alreadyPrompted: prompted,
    );
  }

  /// تسجيل عرض التقييم لمنع إزعاج المستخدم مجدداً
  static Future<void> markReviewPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPromptedKey, true);
  }
}
