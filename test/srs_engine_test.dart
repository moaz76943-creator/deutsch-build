import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs_engine.dart';

void main() {
  test('Standard SM-2 Algorithm Exact Mathematical Verification', () {
    // اختبار التكرار الأول بدرجة ممتازة 5
    var result = SrsEngine.calculateNextReview(
      grade: 5,
      repetitions: 0,
      previousEaseFactor: 2.5,
      previousInterval: 0,
    );
    expect(result['repetitions'], 1);
    expect(result['interval'], 1);
    expect(result['easeFactor'], 2.6);

    // اختبار التكرار الثاني
    result = SrsEngine.calculateNextReview(
      grade: 4,
      repetitions: 1,
      previousEaseFactor: 2.6,
      previousInterval: 1,
    );
    expect(result['repetitions'], 2);
    expect(result['interval'], 4);

    // اختبار الإخفاق وتصفير العداد
    result = SrsEngine.calculateNextReview(
      grade: 2,
      repetitions: 3,
      previousEaseFactor: 2.5,
      previousInterval: 15,
    );
    expect(result['repetitions'], 0);
    expect(result['interval'], 1);
  });
}
