import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_a1_listening_exam_model.dart';

void main() {
  group('SimulatedA1ListeningExamModel Unit Tests (L043)', () {
    final model = SimulatedA1ListeningExamModel();

    test('Contains realistic station and clinic audio prompts with transcripts', () {
      expect(SimulatedA1ListeningExamModel.listeningExercises.length, equals(2));

      final train = SimulatedA1ListeningExamModel.listeningExercises.first;
      expect(train.spokenTranscriptDe, contains('zehn Minuten Verspätung'));
      expect(train.question.correctOptionIndex, equals(1));
    });

    test('Evaluates perfect and partial listening scores accurately', () {
      expect(model.evaluateScore([1, 1]), equals(100.0));
      expect(model.evaluateScore([1, 0]), equals(50.0));
      expect(model.evaluateScore([0, 0]), equals(0.0));
    });
  });
}
