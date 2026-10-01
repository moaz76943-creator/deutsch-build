import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/study_session/domain/cognitive_overload_shield.dart';

void main() {
  group('CognitiveOverloadShield Tests', () {
    test('isOverloaded returns false if totalAnswers is below minimum', () {
      const shield = CognitiveOverloadShield(thresholdAccuracy: 0.60, minimumAnswersBeforeCheck: 10);

      expect(shield.isOverloaded(totalAnswers: 5, correctAnswers: 1), isFalse);
      expect(shield.isOverloaded(totalAnswers: 9, correctAnswers: 2), isFalse);
    });

    test('isOverloaded returns true if accuracy is below threshold', () {
      const shield = CognitiveOverloadShield(thresholdAccuracy: 0.60, minimumAnswersBeforeCheck: 10);

      // 5 correct out of 10 is 50%, below 60% threshold
      expect(shield.isOverloaded(totalAnswers: 10, correctAnswers: 5), isTrue);
      // 4 correct out of 10 is 40%, below 60% threshold
      expect(shield.isOverloaded(totalAnswers: 10, correctAnswers: 4), isTrue);
    });

    test('isOverloaded returns false if accuracy is at or above threshold', () {
      const shield = CognitiveOverloadShield(thresholdAccuracy: 0.60, minimumAnswersBeforeCheck: 10);

      // 6 correct out of 10 is 60%, at threshold (not below)
      expect(shield.isOverloaded(totalAnswers: 10, correctAnswers: 6), isFalse);
      // 9 correct out of 10 is 90%, above threshold
      expect(shield.isOverloaded(totalAnswers: 10, correctAnswers: 9), isFalse);
    });
  });
}
