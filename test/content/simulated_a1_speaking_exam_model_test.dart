import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_a1_speaking_exam_model.dart';

void main() {
  group('SimulatedA1SpeakingExamModel Unit Tests (L044)', () {
    test('Contains standard 7-point self-introduction scaffolding', () {
      expect(SimulatedA1SpeakingExamModel.selfIntroductionPoints.length, equals(7));
      expect(SimulatedA1SpeakingExamModel.selfIntroductionPoints.first, contains('Ich heiße'));
    });

    test('Contains polite, ethical speaking cue cards for daily interactions', () {
      expect(SimulatedA1SpeakingExamModel.cueCards.length, equals(3));

      final waterCard = SimulatedA1SpeakingExamModel.cueCards.last;
      expect(waterCard.theme, equals('Alltag'));
      expect(waterCard.expectedQuestionDe, contains('Könnten Sie mir bitte'));
      expect(waterCard.pedagogicalExplanationAr, contains('رجاء مهذب'));
    });
  });
}
