import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/simulated_b2_speaking_exam_model.dart';

void main() {
  group('SimulatedB2SpeakingExamModel Unit Tests (L056)', () {
    test('Contains structured B2 dialectical debate topic with pro/contra arguments and connectors', () {
      final topic = SimulatedB2SpeakingExamModel.homeofficeDebate;
      expect(topic.proArgumentsDe.length, equals(3));
      expect(topic.contraArgumentsDe.length, equals(2));
      expect(topic.conversationalRedemittelDe.length, greaterThanOrEqualTo(3));
      expect(topic.conversationalRedemittelDe[1], contains('Einerseits'));
    });
  });
}
