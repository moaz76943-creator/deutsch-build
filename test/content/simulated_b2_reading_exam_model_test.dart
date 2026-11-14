import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_b2_reading_exam_model.dart';

void main() {
  group('SimulatedB2ReadingExamModel Unit Tests (L053)', () {
    final model = SimulatedB2ReadingExamModel();

    test('Contains rich original B2 essay on sustainable urban architecture and analytical questions', () {
      expect(SimulatedB2ReadingExamModel.b2ArticleText, contains('Nachhaltige Stadtentwicklung'));
      expect(SimulatedB2ReadingExamModel.b2Questions.length, equals(2));
    });

    test('Accurately evaluates B2 reading answers', () {
      final res = model.scoreB2Reading([1, 0]);
      expect(res['scorePercentage'], equals(100.0));
      expect(res['isPassed'], isTrue);
    });
  });
}
