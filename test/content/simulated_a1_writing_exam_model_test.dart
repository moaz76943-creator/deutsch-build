import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_a1_writing_exam_model.dart';

void main() {
  group('SimulatedA1WritingExamModel Unit Tests (L042)', () {
    final model = SimulatedA1WritingExamModel();

    test('Contains standard A1 registration form fields with clear Arabic gloss', () {
      expect(SimulatedA1WritingExamModel.requiredFormFields.containsKey('Familienname'), isTrue);
      expect(SimulatedA1WritingExamModel.requiredFormFields.containsKey('Geburtsdatum'), isTrue);
    });

    test('Evaluates compliant A1 email response covering all 3 guidance points', () {
      const email =
          'Liebe Frau Sommer, vielen Dank für die Einladung zum Sprachcafé. '
          'Ich komme sehr gerne am Samstag. Soll ich etwas Saft oder Gebäck mitbringen? '
          'Herzliche Grüße.';

      final evaluation = model.evaluateEmailResponse(email);
      expect(evaluation['isPassed'], isTrue);
      expect(evaluation['totalScoreOutOf3'], equals(3));
      expect(evaluation['hasThanksGuidance'], isTrue);
      expect(evaluation['hasAcceptanceGuidance'], isTrue);
      expect(evaluation['hasOfferGuidance'], isTrue);
    });

    test('Rejects email missing key communicative guidance points', () {
      const poorEmail = 'Hallo, das Wetter ist schön.';
      final evaluation = model.evaluateEmailResponse(poorEmail);
      expect(evaluation['isPassed'], isFalse);
      expect(evaluation['totalScoreOutOf3'], equals(0));
    });
  });
}
