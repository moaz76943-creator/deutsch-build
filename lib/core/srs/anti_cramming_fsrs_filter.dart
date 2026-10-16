import 'dart:math' as math;

/// نتيجة تقييم مراجعة التكديس بصيغة مهيكلة قوية النوع
class AntiCrammingResult {
  final double stability;
  final int interval;
  final bool isCramming;

  const AntiCrammingResult({
    required this.stability,
    required this.interval,
    required this.isCramming,
  });

  Map<String, dynamic> toMap() => {
        'stability': stability,
        'interval': interval,
        'isCramming': isCramming,
      };

  @override
  String toString() =>
      'AntiCrammingResult(stability: $stability, interval: $interval, isCramming: $isCramming)';
}

/// مرشح حماية الاستقرار العصبي من فخ التكديس (Anti-Cramming FSRS Filter)
///
/// يحمي خوارزمية التكرار المتباعد (SRS / FSRS-5) من التضخم الوهمي للاستقرار (Stability Inflation)
/// الناتج عن التكرار المتتالي في نفس اليوم دون مرور مرحلة النوم المشبكي والترسيخ العصبي
/// (Synaptic Sleep Consolidation).
class AntiCrammingFsrsFilter {
  static const double minStability = 0.1;
  static const double maxStability = 36500.0;

  /// معالجة مراجعة البطاقة مع حماية الاستقرار العصبي من فخ التكديس
  ///
  /// - [currentStability]: الاستقرار العصبي الحالي للذاكرة بالأيام
  /// - [lastReview]: الطابع الزمني لآخر مراجعة معتمدة
  /// - [currentReview]: الطابع الزمني للمراجعة الجارية
  /// - [rating]: درجة التقييم (1: Again, 2: Hard, 3: Good, 4: Easy)
  static Map<String, dynamic> processReview({
    required double currentStability,
    required DateTime lastReview,
    required DateTime currentReview,
    required int rating, // 1: Again, 2: Hard, 3: Good, 4: Easy
  }) {
    final diffMinutes = currentReview.difference(lastReview).inMinutes;
    // حماية التراجع الزمني واضطراب الساعة المحلية
    final elapsedDays = diffMinutes <= 0 ? 0.0 : diffMinutes / (24.0 * 60.0);

    // 1. كشف جلسات التكديس المكثف خلال أقل من يوم واحد (Intra-Day Session)
    if (elapsedDays < 1.0) {
      if (rating == 1) {
        // الإخفاق أثناء التكديس يخفض الاستقرار جزئياً ولا يصفره تماماً لتفادي العقاب الخاطئ
        return {
          'stability': (currentStability * 0.8).clamp(minStability, maxStability),
          'interval': 0, // مراجعة أخرى في نفس اليوم
          'isCramming': true,
        };
      }
      // النجاح خلال التكديس: نمو خطي مخمد (Damped Increment) مع سقف أقصى يوم واحد قبل النوم
      final dampedIncrement = 0.15 * elapsedDays;
      return {
        'stability': (currentStability + dampedIncrement).clamp(minStability, maxStability),
        'interval': 1, // حظر قفز الفاصل الزمني لأكثر من يوم واحد قبل النوم المشبكي
        'isCramming': true,
      };
    }

    // 2. المراجعة المتباعدة الطبيعية المكتملة (Normal FSRS-5 Inter-Day Consolidation)
    final newS = (currentStability * (rating == 1 ? 0.4 : 2.4)).clamp(minStability, maxStability);
    return {
      'stability': newS,
      'interval': math.max(1, newS.round()),
      'isCramming': false,
    };
  }

  /// واجهة نوعية مهيكلة تعيد [AntiCrammingResult]
  static AntiCrammingResult evaluate({
    required double currentStability,
    required DateTime lastReview,
    required DateTime currentReview,
    required int rating,
  }) {
    final res = processReview(
      currentStability: currentStability,
      lastReview: lastReview,
      currentReview: currentReview,
      rating: rating,
    );
    return AntiCrammingResult(
      stability: (res['stability'] as num).toDouble(),
      interval: (res['interval'] as num).toInt(),
      isCramming: res['isCramming'] as bool,
    );
  }
}
