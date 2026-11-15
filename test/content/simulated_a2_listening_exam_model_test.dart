import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_a2_listening_exam_model.dart';

void main() {
  group('SimulatedA2ListeningExamModel Unit Tests (L047)', () {
    final model = SimulatedA2ListeningExamModel();

    test('Contains realistic multi-turn A2 phone dialogue scripts and comprehension questions', () {
      expect(SimulatedA2ListeningExamModel.a2AudioDialogues.length, equals(2));

      final bookDialog = SimulatedA2ListeningExamModel.a2AudioDialogues.first;
      expect(bookDialog.spokenTranscriptDe, contains('Buchbestellung'));
      expect(bookDialog.question.correctOptionIndex, equals(1));
    });

    test('Scores A2 listening accurately', () {
      expect(model.scoreA2Listening([1, 1]), equals(100.0));
      expect(model.scoreA2Listening([1, 0]), equals(50.0));
    });
  });
}
