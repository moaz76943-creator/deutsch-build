import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs_engine.dart';
import 'package:deutsch_bilarabi/services/srs_sm2_engine.dart';

void main() {
  group('legacy SRS contracts', () {
    test('retains established six-day second interval', () {
      final legacy = SrsEngine.calculateNextReview(
        grade: 4, repetitions: 1, previousEaseFactor: 2.5,
        previousInterval: 1);
      expect(legacy['interval'], 6);

      final service = SrsSm2Engine.calculateNextReview(
        quality: 4, currentEaseFactor: 2.5,
        repetitions: 1, intervalDays: 1,
        currentTime: DateTime.utc(2026, 10, 13));
      expect(service.intervalDays, 6);
      expect(service.nextReviewDate, DateTime.utc(2026, 10, 19));
    });

    test('rejects nonfinite ease factors and multipliers', () {
      for (final bad in [double.nan, double.infinity, double.negativeInfinity]) {
        expect(() => SrsEngine.calculateNextReview(
          grade: 5, repetitions: 2,
          previousEaseFactor: bad, previousInterval: 10),
          throwsArgumentError);
        expect(() => SrsEngine.calculateNextReview(
          grade: 5, repetitions: 2,
          previousEaseFactor: 2.5, previousInterval: 10,
          morphologicalMultiplier: bad),
          throwsArgumentError);
        expect(() => SrsSm2Engine.calculateNextReview(
          quality: 4, currentEaseFactor: bad,
          repetitions: 2, intervalDays: 10),
          throwsArgumentError);
      }
    });

    test('rejects negative and unbounded prior state', () {
      expect(() => SrsEngine.calculateNextReview(
        grade: 5, repetitions: -1,
        previousEaseFactor: 2.5, previousInterval: 1),
        throwsArgumentError);
      expect(() => SrsSm2Engine.calculateNextReview(
        quality: 4, currentEaseFactor: 2.5,
        repetitions: 2, intervalDays: -50),
        throwsArgumentError);
    });

    test('extreme but finite review data never overflows due interval', () {
      final r = SrsSm2Engine.calculateNextReview(
        quality: 5, currentEaseFactor: 2.5,
        repetitions: 999999, intervalDays: 36500,
        currentTime: DateTime.utc(2026));
      expect(r.intervalDays, lessThanOrEqualTo(36500));
      expect(r.repetitions, 1000000);
    });
  });
}
