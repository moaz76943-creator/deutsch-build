import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/anti_cramming_fsrs_filter.dart';

void main() {
  group('AntiCrammingFsrsFilter Tests', () {
    final baseTime = DateTime(2026, 10, 15, 10, 0);

    test('1. كشف جلسة التكديس خلال أقل من يوم واحد مع الإخفاق (rating 1 / Again)', () {
      final reviewTime = baseTime.add(const Duration(minutes: 30));
      final result = AntiCrammingFsrsFilter.processReview(
        currentStability: 10.0,
        lastReview: baseTime,
        currentReview: reviewTime,
        rating: 1,
      );

      expect(result['isCramming'], isTrue);
      expect(result['interval'], equals(0)); // مراجعة فورية في نفس اليوم
      expect(result['stability'], closeTo(8.0, 0.001)); // خفض جزئي بنسبة 20% وليس تصفير كامل
    });

    test('2. كشف جلسة التكديس مع النجاح (rating 3 / Good) وتخميد النمو الخطي', () {
      // 12 ساعة = 0.5 يوم
      final reviewTime = baseTime.add(const Duration(hours: 12));
      final result = AntiCrammingFsrsFilter.processReview(
        currentStability: 10.0,
        lastReview: baseTime,
        currentReview: reviewTime,
        rating: 3,
      );

      expect(result['isCramming'], isTrue);
      expect(result['interval'], equals(1)); // حظر قفز الفاصل الزمني لأكثر من يوم واحد قبل النوم
      // dampedIncrement = 0.15 * 0.5 = 0.075
      expect(result['stability'], closeTo(10.075, 0.001));
    });

    test('3. جلسة التكديس السريعة المتتالية بعد ساعتين (rating 4 / Easy)', () {
      final reviewTime = baseTime.add(const Duration(hours: 2));
      final result = AntiCrammingFsrsFilter.processReview(
        currentStability: 5.0,
        lastReview: baseTime,
        currentReview: reviewTime,
        rating: 4,
      );

      expect(result['isCramming'], isTrue);
      expect(result['interval'], equals(1));
      final expectedElapsedDays = 120 / (24.0 * 60.0); // 2 / 24 = 0.08333
      final expectedStability = 5.0 + (0.15 * expectedElapsedDays);
      expect(result['stability'], closeTo(expectedStability, 0.001));
    });

    test('4. المراجعة المتباعدة الطبيعية المكتملة بعد يومين (Inter-Day Consolidation - Good)', () {
      final reviewTime = baseTime.add(const Duration(days: 2));
      final result = AntiCrammingFsrsFilter.processReview(
        currentStability: 10.0,
        lastReview: baseTime,
        currentReview: reviewTime,
        rating: 3,
      );

      expect(result['isCramming'], isFalse);
      // newS = 10.0 * 2.4 = 24.0
      expect(result['stability'], closeTo(24.0, 0.001));
      expect(result['interval'], equals(24));
    });

    test('5. المراجعة المتباعدة الطبيعية المكتملة مع الإخفاق (Inter-Day Consolidation - Again)', () {
      final reviewTime = baseTime.add(const Duration(days: 3));
      final result = AntiCrammingFsrsFilter.processReview(
        currentStability: 10.0,
        lastReview: baseTime,
        currentReview: reviewTime,
        rating: 1,
      );

      expect(result['isCramming'], isFalse);
      // newS = 10.0 * 0.4 = 4.0
      expect(result['stability'], closeTo(4.0, 0.001));
      expect(result['interval'], equals(4));
    });

    test('6. حماية اضطراب الساعة المحلية والتراجع الزمني (Clock Skew)', () {
      // currentReview قبل lastReview
      final skewTime = baseTime.subtract(const Duration(minutes: 15));
      final result = AntiCrammingFsrsFilter.processReview(
        currentStability: 4.0,
        lastReview: baseTime,
        currentReview: skewTime,
        rating: 3,
      );

      expect(result['isCramming'], isTrue);
      expect(result['interval'], equals(1));
      expect(result['stability'], closeTo(4.0, 0.001)); // no negative decrement
    });

    test('7. احترام حدود الاستقرار الدنيا والقصوى (Clamp Bounds)', () {
      final reviewTime = baseTime.add(const Duration(minutes: 10));
      final resultLow = AntiCrammingFsrsFilter.processReview(
        currentStability: 0.05,
        lastReview: baseTime,
        currentReview: reviewTime,
        rating: 1,
      );
      expect(resultLow['stability'], equals(AntiCrammingFsrsFilter.minStability));

      final interDayTime = baseTime.add(const Duration(days: 5));
      final resultHigh = AntiCrammingFsrsFilter.processReview(
        currentStability: 20000.0,
        lastReview: baseTime,
        currentReview: interDayTime,
        rating: 3,
      );
      expect(resultHigh['stability'], equals(AntiCrammingFsrsFilter.maxStability));
    });

    test('8. اختبار الواجهة النوعية القوية AntiCrammingFsrsFilter.evaluate', () {
      final reviewTime = baseTime.add(const Duration(hours: 6));
      final typedResult = AntiCrammingFsrsFilter.evaluate(
        currentStability: 8.0,
        lastReview: baseTime,
        currentReview: reviewTime,
        rating: 3,
      );

      expect(typedResult, isA<AntiCrammingResult>());
      expect(typedResult.isCramming, isTrue);
      expect(typedResult.interval, equals(1));
      expect(typedResult.toMap()['isCramming'], isTrue);
    });
  });
}
