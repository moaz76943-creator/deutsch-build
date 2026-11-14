import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/collocation_mwe_extractor.dart';

void main() {
  group('CollocationMweExtractor Unit Tests (N027)', () {
    final extractor = CollocationMweExtractor();

    test('Accurately flags strongly governed German verb-preposition bundle', () {
      final result = extractor.evaluateVerbPreposition(
        verb: 'warten',
        preposition: 'auf',
        coOccurrences: 850,
        verbCount: 1200,
        prepCount: 15000,
        corpusTokens: 1000000,
      );

      expect(result.phrase, equals('warten auf'));
      expect(result.isStrongCollocation, isTrue);
      expect(result.pmiScore, greaterThan(3.0));
      expect(result.diceCoefficient, greaterThan(0.05));
    });

    test('Rejects arbitrary unbonded word pairs with zero co-occurrence', () {
      final result = extractor.evaluateVerbPreposition(
        verb: 'fliegen',
        preposition: 'trotz',
        coOccurrences: 0,
        verbCount: 500,
        prepCount: 200,
      );

      expect(result.pmiScore, equals(0.0));
      expect(result.diceCoefficient, equals(0.0));
      expect(result.isStrongCollocation, isFalse);
    });
  });
}
