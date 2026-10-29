import 'package:flutter/foundation.dart';

/// عامل المعالجة المعزول لضمان عدم تجميد الواجهة أثناء حسابات SRS
class PersistentCpuWorker {
  static final PersistentCpuWorker instance = PersistentCpuWorker._init();

  PersistentCpuWorker._init();

  /// تنفيذ العمليات الحسابية الثقيلة خارج مسار الواجهة (UI Isolate)
  Future<double> calculateNewEaseFactor(double currentEase, int rating) async {
    // نقل الحسابات الثقيلة إلى Isolate مستقل باستخدام compute
    return await compute(_heavySrsMath, {'ease': currentEase, 'rating': rating});
  }

  // دالة رياضية معزولة تماماً (SM-2 Logic)
  static double _heavySrsMath(Map<String, dynamic> data) {
    double ease = data['ease'] as double;
    int rating = data['rating'] as int;

    // معادلة الحفظ والمراجعة المتباعدة
    double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (newEase < 1.3) newEase = 1.3;

    return newEase;
  }
}
