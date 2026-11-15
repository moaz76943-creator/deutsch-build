import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_a1_reading_exam_model.dart';

void main() {
  group('SimulatedA1ReadingExamModel Unit Tests (L041)', () {
    final model = SimulatedA1ReadingExamModel();

    test('Contains original ethical stimulus text and multiple choice questions', () {
      expect(SimulatedA1ReadingExamModel.stimulusText, contains('Stadtbibliothek Mitteilung'));
      expect(SimulatedA1ReadingExamModel.questions.length, equals(2));
    });

    test('Scores exam accurately and awards pass at 60% threshold', () {
      final perfectResult = model.scoreExam([1, 0]);
      expect(perfectResult['isComplete'], isTrue);
      expect(perfectResult['scorePercentage'], equals(100.0));
      expect(perfectResult['isPassed'], isTrue);

      final failedResult = model.scoreExam([0, 1]);
      expect(failedResult['scorePercentage'], equals(0.0));
      expect(failedResult['isPassed'], isFalse);
    });
  });
}
