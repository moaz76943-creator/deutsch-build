import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs_engine.dart';
import 'package:deutsch_bilarabi/services/srs_sm2_engine.dart';

void main() {
  test('legacy second success still follows 6-day schedule', () {
    final result = SrsEngine.calculateNextReview(
      grade: 4,
      repetitions: 1,
      previousEaseFactor: 2.5,
      previousInterval: 1,
    );
    expect(result['interval'], 6);
  });

  test('legacy SM-2 accepts an injected deterministic clock', () {
    final fixed = DateTime.utc(2026, 10, 13);
    final result = SrsSm2Engine.calculateNextReview(
      quality: 4,
      currentEaseFactor: 2.5,
      repetitions: 1,
      intervalDays: 1,
      currentTime: fixed,
    );
    expect(result.intervalDays, 6);
    expect(result.nextReviewDate, fixed.add(const Duration(days: 6)));
  });

  test('nonfinite, negative legacy inputs fail closed', () {
    expect(() => SrsEngine.calculateNextReview(
      grade: 3,
      repetitions: -1,
      previousEaseFactor: 2.5,
      previousInterval: 1,
    ), throwsArgumentError);
    expect(() => SrsEngine.calculateNextReview(
      grade: 4,
      repetitions: 2,
      previousEaseFactor: double.nan,
      previousInterval: 1,
    ), throwsArgumentError);
    expect(() => SrsSm2Engine.calculateNextReview(
      quality: 4,
      currentEaseFactor: double.infinity,
      repetitions: 1,
      intervalDays: 1,
    ), throwsArgumentError);
  });

  test('legacy counters and scheduled intervals saturate safely', () {
    final result = SrsEngine.calculateNextReview(
      grade: 5,
      repetitions: 999999999,
      previousEaseFactor: 99.0,
      previousInterval: 999999999,
      morphologicalMultiplier: 99.0,
    );
    expect(result['repetitions'], lessThanOrEqualTo(1000000));
    expect(result['interval'], lessThanOrEqualTo(36500));
  });
}
