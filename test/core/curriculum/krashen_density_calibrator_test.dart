import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/krashen_density_calibrator.dart';

void main() {
  group('KrashenDensityCalibrator Unit Tests (N021)', () {
    const calibrator = KrashenDensityCalibrator(
      minOptimalRatio: 0.90,
      maxOptimalRatio: 0.96,
    );

    test('Identifies optimal 95% Krashen i+1 comprehension ratio', () {
      final known = Set<String>.from(List.generate(19, (i) => 'word$i'));
      final passage = List.generate(19, (i) => 'word$i')..add('novelword');

      final report = calibrator.calibrate(
        passageTokens: passage,
        knownVocabulary: known,
      );

      expect(report.totalTokens, equals(20));
      expect(report.knownTokensCount, equals(19));
      expect(report.unknownTokensCount, equals(1));
      expect(report.comprehensionRatio, equals(0.95));
      expect(report.isOptimalZone, isTrue);
      expect(report.targetNovelTokens, contains('novelword'));
    });

    test('Flags overwhelming passages below minimum comprehensible threshold', () {
      final known = {'der', 'die', 'das'};
      final passage = ['der', 'hund', 'frisst', 'einen', 'apfel'];

      final report = calibrator.calibrate(
        passageTokens: passage,
        knownVocabulary: known,
      );

      expect(report.isOptimalZone, isFalse);
      expect(report.comprehensionRatio, lessThan(0.90));
      expect(report.scaffoldingAdvice, contains('Overwhelming'));
    });

    test('Gracefully handles empty input passage', () {
      final report = calibrator.calibrate(passageTokens: [], knownVocabulary: {'gut'});
      expect(report.totalTokens, equals(0));
      expect(report.isOptimalZone, isFalse);
    });
  });
}
