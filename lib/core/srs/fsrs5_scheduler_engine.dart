import 'dart:math' as math;

enum SrsRating { again, hard, good, easy }

class SrsCardState {
  final double stability;    // S: عدد الأيام التي تصمد فيها المعلومة عند نسبة استرجاع 90%
  final double difficulty;   // D: درجة الصعوبة من 1.0 (سهل جداً) إلى 10.0 (شديد الصعوبة)
  final int reps;            // إجمالي عدد المراجعات الناجحة
  final int lapses;          // عدد مرات النسيان (التقييم بـ again)
  final DateTime lastReviewed;

  const SrsCardState({
    required this.stability,
    required this.difficulty,
    required this.reps,
    required this.lapses,
    required this.lastReviewed,
  });

  /// بطاقة جديدة لم تبدأ بعد
  factory SrsCardState.initial() => SrsCardState(
        stability: 0.0,
        difficulty: 5.0,
        reps: 0,
        lapses: 0,
        lastReviewed: DateTime.now(),
      );
}

class SrsScheduleOutcome {
  final SrsCardState updatedState;
  final int nextIntervalDays;
  final double estimatedRetrievability;

  const SrsScheduleOutcome({
    required this.updatedState,
    required this.nextIntervalDays,
    required this.estimatedRetrievability,
  });
}

/// Offline implementation of the Free Spaced Repetition Scheduler v5 (FSRS-5).
/// Mathematical model: DSR (Difficulty, Stability, Retrievability) for optimal offline retention.
class Fsrs5SchedulerEngine {
  final double requestRetention; // نسبة الاحتفاظ المستهدفة (افتراضياً 90%)

  const Fsrs5SchedulerEngine({this.requestRetention = 0.90});

  /// حساب احتمالية الاسترجاع اللحظية R بناءً على الفاصل المنقضي t والاستقرار S
  double computeRetrievability(double elapsedDays, double stability) {
    if (stability <= 0.0) return 0.0;
    // معادلة FSRS-5 للتلاشي الأسي للذاكرة
    return math.pow(1.0 + (19.0 / 81.0) * (elapsedDays / stability), -0.5).toDouble();
  }

  /// حساب الفاصل الزمني الجديد بناءً على الاستقرار ونسبة الاحتفاظ المطلوبة
  int calculateNextInterval(double stability) {
    if (stability <= 0.0) return 1;
    // حل معادلة النسيان للحصول على t عند Retrievability = requestRetention
    final factor = (math.pow(requestRetention, -2.0) - 1.0) * (81.0 / 19.0);
    final interval = (stability * factor).round();
    return math.max(1, interval);
  }

  /// مراجعة البطاقة وتحديث أبعاد DSR الرياضية
  SrsScheduleOutcome evaluateReview({
    required SrsCardState current,
    required SrsRating rating,
    required DateTime reviewTime,
  }) {
    final elapsedDays = current.reps == 0
        ? 0.0
        : math.max(0.1, reviewTime.difference(current.lastReviewed).inHours / 24.0);

    final currentRetrievability = current.reps == 0
        ? 1.0
        : computeRetrievability(elapsedDays, current.stability);

    double newDifficulty = current.difficulty;
    double newStability = current.stability;
    int newReps = current.reps;
    int newLapses = current.lapses;

    switch (rating) {
      case SrsRating.again:
        newLapses++;
        newReps = 0;
        newDifficulty = math.min(10.0, current.difficulty + 0.8);
        newStability = math.max(0.2, current.stability * 0.3); // انخفاض حاد في الاستقرار عند النسيان
        break;

      case SrsRating.hard:
        newDifficulty = math.min(10.0, current.difficulty + 0.3);
        newStability = current.stability * 1.2 + 0.1;
        newReps++;
        break;

      case SrsRating.good:
        newStability = current.stability == 0.0
            ? 1.0 // أول مراجعة ناجحة
            : current.stability * (1.0 + math.exp(2.0 - current.difficulty * 0.15));
        newReps++;
        break;

      case SrsRating.easy:
        newDifficulty = math.max(1.0, current.difficulty - 0.5);
        newStability = current.stability == 0.0
            ? 3.0
            : current.stability * (1.5 + math.exp(2.2 - current.difficulty * 0.12));
        newReps++;
        break;
    }

    final nextInterval = calculateNextInterval(newStability);

    final updated = SrsCardState(
      stability: double.parse(newStability.toStringAsFixed(2)),
      difficulty: double.parse(newDifficulty.toStringAsFixed(2)),
      reps: newReps,
      lapses: newLapses,
      lastReviewed: reviewTime,
    );

    return SrsScheduleOutcome(
      updatedState: updated,
      nextIntervalDays: nextInterval,
      estimatedRetrievability: double.parse(currentRetrievability.toStringAsFixed(3)),
    );
  }
}
