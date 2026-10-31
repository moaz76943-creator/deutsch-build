import 'package:deutsch_build/core/srs/fsrs5_scheduler_engine.dart';

void main() {
  const engine = Fsrs5SchedulerEngine(requestRetention: 0.90);
  final card = SrsCardState.initial();

  // 1. أول تقييم بـ Good: يجب أن يبدأ الاستقرار وتزيد الفترات
  final outcomeGood = engine.evaluateReview(
    current: card,
    rating: SrsRating.good,
    reviewTime: DateTime.now(),
  );
  assert(outcomeGood.updatedState.stability >= 1.0);
  assert(outcomeGood.nextIntervalDays >= 1);
  assert(outcomeGood.updatedState.reps == 1);

  // 2. تقييم متتال بـ Easy: زيادة أسرع في الاستقرار وتراجع الصعوبة
  final outcomeEasy = engine.evaluateReview(
    current: outcomeGood.updatedState,
    rating: SrsRating.easy,
    reviewTime: DateTime.now().add(const Duration(days: 1)),
  );
  assert(outcomeEasy.updatedState.difficulty < outcomeGood.updatedState.difficulty);
  assert(outcomeEasy.nextIntervalDays > outcomeGood.nextIntervalDays);

  // 3. النسيان بـ Again: زيادة عدد lapses وهبوط الاستقرار
  final outcomeAgain = engine.evaluateReview(
    current: outcomeEasy.updatedState,
    rating: SrsRating.again,
    reviewTime: DateTime.now().add(const Duration(days: 5)),
  );
  assert(outcomeAgain.updatedState.lapses == 1);
  assert(outcomeAgain.updatedState.stability < outcomeEasy.updatedState.stability);
  assert(outcomeAgain.updatedState.reps == 0);

  // 4. فحص معادلة Retrievability: بعد انقضاء ضعف الاستقرار يجب أن تنخفض النسبة
  final rHigh = engine.computeRetrievability(0.5, 2.0);
  final rLow = engine.computeRetrievability(10.0, 2.0);
  assert(rHigh > rLow);

  print('FSRS-5 DSR memory scheduler unit assertions passed.');
}
