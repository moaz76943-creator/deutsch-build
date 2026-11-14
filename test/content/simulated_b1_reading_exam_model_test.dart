import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_b1_reading_exam_model.dart';

void main() {
  group('SimulatedB1ReadingExamModel Unit Tests (L049)', () {
    final model = SimulatedB1ReadingExamModel();

    test('Contains authentic original B1 forum text stimulus and comprehension questions', () {
      expect(SimulatedB1ReadingExamModel.blogPostText, contains('Zukunft des Lernens'));
      expect(SimulatedB1ReadingExamModel.b1Questions.length, equals(2));
    });

    test('Scores B1 reading accurately', () {
      final res = model.scoreB1Reading([1, 1]);
      expect(res['isComplete'], isTrue);
      expect(res['scorePercentage'], equals(100.0));
      expect(res['isPassed'], isTrue);
    });
  });
}
