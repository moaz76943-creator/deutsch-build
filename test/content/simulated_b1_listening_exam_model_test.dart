import 'package:test/test.dart';
import '../../lib/src/content/simulated_b1_listening_exam_model.dart';

void main() {
  group('SimulatedB1ListeningExamModel Unit Tests (L051)', () {
    final model = SimulatedB1ListeningExamModel();

    test('Contains authentic radio interview transcript and scientific comprehension question', () {
      expect(SimulatedB1ListeningExamModel.b1BroadcastAudio.length, equals(1));

      final broadcast = SimulatedB1ListeningExamModel.b1BroadcastAudio.first;
      expect(broadcast.spokenTranscriptDe, contains('Wissenschaft am Nachmittag'));
      expect(broadcast.question.correctOptionIndex, equals(1));
    });

    test('Scores B1 broadcast listening correctly', () {
      expect(model.scoreB1Listening([1]), equals(100.0));
      expect(model.scoreB1Listening([0]), equals(0.0));
    });
  });
}
