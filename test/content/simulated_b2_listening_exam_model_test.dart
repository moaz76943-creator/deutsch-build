import 'package:test/test.dart';
import '../../lib/src/content/simulated_b2_listening_exam_model.dart';

void main() {
  group('SimulatedB2ListeningExamModel Unit Tests (L055)', () {
    final model = SimulatedB2ListeningExamModel();

    test('Contains authentic academic panel discussion transcript and critical comprehension question', () {
      expect(SimulatedB2ListeningExamModel.b2ColloquiumAudio.length, equals(1));

      final panel = SimulatedB2ListeningExamModel.b2ColloquiumAudio.first;
      expect(panel.spokenTranscriptDe, contains('Prof. Dr. Hartmann'));
      expect(panel.question.correctOptionIndex, equals(1));
    });

    test('Scores B2 listening response accurately', () {
      expect(model.scoreB2Listening([1]), equals(100.0));
      expect(model.scoreB2Listening([0]), equals(0.0));
    });
  });
}
