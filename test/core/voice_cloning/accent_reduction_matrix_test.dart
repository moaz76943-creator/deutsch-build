import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/voice_cloning/accent_reduction_matrix.dart';

void main() {
  test('Diagnoses P vs B transfer error accurately with targeted motor tip', () {
    const matrix = AccentReductionMatrix();
    final fb = matrix.evaluatePronunciationError('p', 'b');
    expect(fb.phoneme, equals('p'));
    expect(fb.diagnosedMotherTongueTransfer, contains('Arabic lack of unvoiced bilabial'));
    expect(fb.targetMotorTip, contains('burst of air'));
  });
}
