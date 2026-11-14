import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_a2_writing_exam_model.dart';

void main() {
  group('SimulatedA2WritingExamModel Unit Tests (L046)', () {
    final model = SimulatedA2WritingExamModel();

    test('Contains standard A2 semi-formal absence prompt', () {
      expect(SimulatedA2WritingExamModel.a2EmailPrompt, contains('Herrn Bergmann'));
      expect(SimulatedA2WritingExamModel.a2EmailPrompt, contains('Hausaufgaben'));
    });

    test('Validates well-structured A2 email covering apology, reason, and homework request', () {
      const email =
          'Sehr geehrter Herr Bergmann,\n'
          'ich entschuldige mich, dass ich am Montag leider nicht zum Deutschkurs kommen kann. '
          'Ich habe einen wichtigen Arzttermin am Vormittag. '
          'Könnten Sie mir bitte die Hausaufgaben per E-Mail zusenden?\n'
          'Mit freundlichen Grüßen,\n'
          'Tariq';

      final result = model.evaluateA2Email(email);
      expect(result['isPassed'], isTrue);
      expect(result['contentPointsScore'], equals(3));
      expect(result['formalStructureScore'], equals(2));
      expect(result['isLengthValid'], isTrue);
    });
  });
}
