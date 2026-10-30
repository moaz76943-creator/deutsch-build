import 'package:test/test.dart';
import '../../lib/src/core/curriculum/pragmatic_register_matrix.dart';

void main() {
  group('PragmaticRegisterMatrix Unit Tests (N029)', () {
    final matrix = PragmaticRegisterMatrix();

    test('Catches informal duzen slip in formal workplace dialogue', () {
      final report = matrix.auditUtterance(
        utterance: 'Kannst du mir bitte den Vertrag schicken?',
        targetContext: FormalityLevel.formal,
      );

      expect(report.isAppropriate, isFalse);
      expect(report.detectedRegister, equals(FormalityLevel.casual));
      expect(report.flaggedMarkers, contains('du'));
      expect(report.recommendation, contains('Social Faux-Pas Warning'));
    });

    test('Validates polite Siezen in formal interview or official setting', () {
      final report = matrix.auditUtterance(
        utterance: 'Könnten Sie mir bitte helfen?',
        targetContext: FormalityLevel.formal,
      );

      expect(report.isAppropriate, isTrue);
      expect(report.flaggedMarkers, isEmpty);
      expect(report.recommendation, contains('Register Alignment Verified'));
    });

    test('Flags stiff formality when speaking in casual peer context', () {
      final report = matrix.auditUtterance(
        utterance: 'Wie geht es Ihnen heute?',
        targetContext: FormalityLevel.casual,
      );

      expect(report.isAppropriate, isFalse);
      expect(report.flaggedMarkers, contains('ihnen'));
      expect(report.recommendation, contains('Overly Distant'));
    });
  });
}
