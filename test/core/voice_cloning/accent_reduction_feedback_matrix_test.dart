import 'package:test/test.dart';
import '../../lib/src/core/voice_cloning/accent_reduction_feedback_matrix.dart';

void main() {
  test('N007: AccentReductionFeedbackMatrix evaluates phonemes', () {
    final matrix = AccentReductionFeedbackMatrix();
    expect(matrix.getArticulatoryCorrection('p', 'b'), contains('Ziel: b'));
  });
}
