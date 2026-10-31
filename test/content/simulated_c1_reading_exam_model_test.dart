import 'package:test/test.dart';
import '../../lib/src/content/simulated_c1_reading_exam_model.dart';

void main() {
  group('SimulatedC1ReadingExamModel Unit Tests (L057)', () {
    final model = SimulatedC1ReadingExamModel();

    test('Contains advanced C1 academic essay on epistemology and artificial intelligence', () {
      expect(SimulatedC1ReadingExamModel.c1TextStimulus, contains('Erkenntnistheoretische Reflexionen'));
      expect(SimulatedC1ReadingExamModel.c1Questions.length, equals(2));
    });

    test('Evaluates complex C1 reading comprehension answers accurately', () {
      final res = model.scoreC1Reading([1, 0]);
      expect(res['scorePercentage'], equals(100.0));
      expect(res['isPassed'], isTrue);
    });
  });
}
