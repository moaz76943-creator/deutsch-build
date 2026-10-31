import 'package:test/test.dart';
import '../../lib/src/core/multimodal_dialogue/facial_emotion_synthesizer.dart';

void main() {
  group('FacialEmotionSynthesizer Unit Tests (N065)', () {
    final synthesizer = FacialEmotionSynthesizer();

    test('Generates approving smile and nod when learner is correct', () {
      final expression = synthesizer.synthesizeExpression(
        isLearnerCorrect: true,
        isListeningAttentively: false,
        isExplainingGrammar: false,
      );

      expect(expression.smileIntensity, greaterThanOrEqualTo(0.80));
      expect(expression.nodAmplitude, greaterThan(0.50));
    });

    test('Generates attentive tilt during user speech', () {
      final expression = synthesizer.synthesizeExpression(
        isLearnerCorrect: false,
        isListeningAttentively: true,
        isExplainingGrammar: false,
      );

      expect(expression.attentiveTilt, greaterThan(0.50));
      expect(expression.smileIntensity, inInclusiveRange(0.20, 0.50));
    });

    test('Neutral baseline outputs minimal blendshape coefficients', () {
      final expression = synthesizer.synthesizeExpression(
        isLearnerCorrect: false,
        isListeningAttentively: false,
        isExplainingGrammar: false,
      );

      expect(expression.browRaise, equals(0.0));
      expect(expression.nodAmplitude, equals(0.0));
    });
  });
}
