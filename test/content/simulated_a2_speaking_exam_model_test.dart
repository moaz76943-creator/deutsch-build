import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_a2_speaking_exam_model.dart';

void main() {
  group('SimulatedA2SpeakingExamModel Unit Tests (L048)', () {
    test('Contains structured joint planning task with 4 authentic discussion points', () {
      final task = SimulatedA2SpeakingExamModel.parkCleanUpPlan;
      expect(task.discussionPoints.length, equals(4));
      expect(task.suggestedPhrasesDe.length, greaterThanOrEqualTo(4));
      expect(task.suggestedPhrasesDe.first, contains('Ich schlage vor'));
      expect(task.pedagogicalGuidanceAr, contains('التفاعل والمبادرة'));
    });
  });
}
