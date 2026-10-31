import 'dart:math' as math;

class FuzzRange {
  final int minInterval;
  final int maxInterval;

  const FuzzRange(this.minInterval, this.maxInterval);
}

/// Offline mathematical engine applying deterministic interval fuzzing to prevent review avalanches.
/// Prevents cognitive overload by dispersing cards across neighboring days without cloud dependency.
class IntervalFuzzingEngine {
  /// احتساب الحد الأقصى للتشتيت بناءً على طول الفترة الزمنية
  int calculateMaxFuzz(int rawIntervalDays) {
    if (rawIntervalDays < 3) return 0; // الفترات القصيرة جداً لا تُشتت لضمان التثبيت الأولي
    if (rawIntervalDays < 7) return 1; // الفترات من 3 إلى 6 أيام: تشتيت بـ ±1 يوم
    if (rawIntervalDays < 30) return (rawIntervalDays * 0.10).round().clamp(1, 3);
    return (rawIntervalDays * 0.05).round().clamp(2, 7); // الفترات الطويلة: تشتيت حتى ±7 أيام
  }

  /// تطبيق التشتيت الحتمي المستند إلى معرف البطاقة لضمان التكرار والتناسق الأوفلاين
  int applyFuzz({
    required int rawIntervalDays,
    required String cardId,
  }) {
    final maxFuzz = calculateMaxFuzz(rawIntervalDays);
    if (maxFuzz <= 0) return rawIntervalDays;

    // استخدام hashCode للبطاقة لضمان أن التشتيت حتمي وثابت لنفس البطاقة في الجلسة
    final hash = cardId.hashCode.abs();
    final fuzzOffset = (hash % (2 * maxFuzz + 1)) - maxFuzz;

    final finalInterval = rawIntervalDays + fuzzOffset;
    return math.max(1, finalInterval);
  }

  /// إرجاع النطاق الزمني المسموح به للمراجعة (من وإلى)
  FuzzRange getFuzzBounds(int rawIntervalDays) {
    final maxFuzz = calculateMaxFuzz(rawIntervalDays);
    return FuzzRange(
      math.max(1, rawIntervalDays - maxFuzz),
      rawIntervalDays + maxFuzz,
    );
  }
}
