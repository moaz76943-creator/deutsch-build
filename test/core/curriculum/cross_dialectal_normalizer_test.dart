import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/cross_dialectal_normalizer.dart';

void main() {
  group('CrossDialectalNormalizer Unit Tests (N033)', () {
    final normalizer = CrossDialectalNormalizer();

    test('Identifies Austrian culinary variants for standard German words', () {
      final results = normalizer.resolveVariants('Tomate', dialectCode: 'de-AT');
      expect(results.length, equals(1));
      expect(results.first.regionalVariant, equals('Paradeiser'));
      expect(results.first.targetDialect, equals('de-AT'));
    });

    test('Identifies Swiss Velo for Fahrrad', () {
      final results = normalizer.resolveVariants('Fahrrad', dialectCode: 'de-CH');
      expect(results.length, equals(1));
      expect(results.first.regionalVariant, equals('Velo'));
    });

    test('Normalizes regional terms back to standard Hochdeutsch', () {
      const austrianSentence = 'Ich kaufe Paradeiser und Marille.';
      final standard = normalizer.normalizeToStandard(austrianSentence);
      expect(standard, equals('Ich kaufe Tomate und Aprikose.'));
    });
  });
}
