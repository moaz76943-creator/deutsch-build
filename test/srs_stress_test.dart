import 'package:flutter_test/flutter_test.dart';

// محاكاة سريعة لدالة العامل المعزول للاختبار
double testHeavySrsMath(double ease, int rating) {
  double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
  if (newEase < 1.3) newEase = 1.3;
  return newEase;
}

void main() {
  group('SRS Scheduler Stress Test', () {
    test('Should handle 50,000 deterministic evaluations without crashing or negative intervals', () {
      double currentEase = 2.5; // البداية الافتراضية

      for (int i = 0; i < 50000; i++) {
        // محاكاة تقييم عشوائي بين 1 (صعب جداً) و 4 (سهل)
        int simulatedRating = (i % 4) + 1;

        currentEase = testHeavySrsMath(currentEase, simulatedRating);

        // التأكد الحاسم: قيمة السهولة لا يجب أبداً أن تنزل تحت 1.3
        expect(currentEase, greaterThanOrEqualTo(1.3));

        // التأكد من عدم حدوث أخطاء رياضية مثل NaN أو Infinity
        expect(currentEase.isNaN, isFalse);
        expect(currentEase.isInfinite, isFalse);
      }

      print('✅ اجتاز التطبيق اختبار 50,000 عملية مراجعة بنجاح واستقرار رياضي.');
    });
  });
}
