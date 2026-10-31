import 'package:deutsch_build/core/srs/interval_fuzzing_engine.dart';

void main() {
  final engine = IntervalFuzzingEngine();

  // 1. الفترات القصيرة جداً (< 3 أيام) لا تتغير: 1 يوم يظل 1 يوم، 2 يوم يظل 2 يوم
  assert(engine.applyFuzz(rawIntervalDays: 1, cardId: 'c1') == 1);
  assert(engine.applyFuzz(rawIntervalDays: 2, cardId: 'c2') == 2);
  assert(engine.calculateMaxFuzz(2) == 0);

  // 2. الفترات المتوسطة (مثال: 5 أيام): تتراوح بين 4 و 6 أيام
  final bounds5 = engine.getFuzzBounds(5);
  assert(bounds5.minInterval == 4 && bounds5.maxInterval == 6);
  final fuzzed5 = engine.applyFuzz(rawIntervalDays: 5, cardId: 'card_xyz');
  assert(fuzzed5 >= bounds5.minInterval && fuzzed5 <= bounds5.maxInterval);

  // 3. الفترات الطويلة (مثال: 60 يوماً): التشتيت ضمن النطاق
  final bounds60 = engine.getFuzzBounds(60);
  assert(bounds60.minInterval >= 53 && bounds60.maxInterval <= 67);

  // 4. الحتمية: نفس البطاقة ونفس الفترة يجب أن تعطي دائماً نفس الناتج التشتيتي
  final firstCall = engine.applyFuzz(rawIntervalDays: 14, cardId: 'unique_card_id');
  final secondCall = engine.applyFuzz(rawIntervalDays: 14, cardId: 'unique_card_id');
  assert(firstCall == secondCall, 'Failed: Deterministic fuzzing produced inconsistent values');

  print('Interval fuzzing and anti-clustering unit assertions passed.');
}
