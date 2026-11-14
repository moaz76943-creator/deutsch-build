import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_a2_reading_exam_model.dart';

void main() {
  group('SimulatedA2ReadingExamModel Unit Tests (L045)', () {
    final model = SimulatedA2ReadingExamModel();

    test('Contains rich original A2 news article stimulus and inference questions', () {
      expect(SimulatedA2ReadingExamModel.newsArticle, contains('Neuer Stadtpark'));
      expect(SimulatedA2ReadingExamModel.a2Questions.length, equals(2));
    });

    test('Accurately evaluates A2 exam score', () {
      final res = model.evaluateA2Reading([1, 2]);
      expect(res['isComplete'], isTrue);
      expect(res['scorePercentage'], equals(100.0));
      expect(res['isPassed'], isTrue);
    });
  });
}
