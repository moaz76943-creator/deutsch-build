import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

void main() {
  group('DirectedPairId', () {
    test('Identity and Directionality', () {
      const pair1 = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      const pair2 = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      const pair3 = DirectedPairId(sourceLocale: 'de', targetLocale: 'en', semanticVersion: '1.0.0');
      const pair4 = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.1.0');

      expect(pair1, equals(pair2));
      expect(pair1.hashCode, equals(pair2.hashCode));
      expect(pair1, isNot(equals(pair3)));
      expect(pair1.hashCode, isNot(equals(pair3.hashCode)));
      expect(pair1, isNot(equals(pair4)));
      expect(pair1.uniqueKey, 'en_de_1.0.0');
    });

    test('Validation Logic', () {
      const validPair = DirectedPairId(sourceLocale: 'en_US', targetLocale: 'de', semanticVersion: '1.2.3');
      expect(validPair.hasValidLocales, isTrue);
      expect(validPair.hasValidVersion, isTrue);
      expect(validPair.isValidForLearning(), isTrue);

      const invalidVersion = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');
      expect(invalidVersion.hasValidVersion, isFalse);

      const invalidLocale = DirectedPairId(sourceLocale: 'english', targetLocale: 'de', semanticVersion: '1.0.0');
      expect(invalidLocale.hasValidLocales, isFalse);
      expect(invalidLocale.isValidForLearning(), isFalse);

      const reflexivePair = DirectedPairId(sourceLocale: 'en', targetLocale: 'en', semanticVersion: '1.0.0');
      expect(reflexivePair.isReflexive, isTrue);
      expect(reflexivePair.isValidForLearning(), isFalse);
    });

    test('Serialization and Legacy Migration', () {
      final json = {'sourceLocale': 'ar', 'targetLocale': 'de', 'semanticVersion': '2.0.0'};
      final pair = DirectedPairId.fromJson(json);
      expect(pair.sourceLocale, 'ar');
      expect(pair.targetLocale, 'de');
      expect(pair.semanticVersion, '2.0.0');
      expect(pair.toJson(), equals(json));

      final legacy2 = DirectedPairId.fromString('ar_de');
      expect(legacy2.sourceLocale, 'ar');
      expect(legacy2.targetLocale, 'de');
      expect(legacy2.semanticVersion, '1.0.0');

      final legacy3 = DirectedPairId.fromString('en_fr_1.5.0');
      expect(legacy3.sourceLocale, 'en');
      expect(legacy3.targetLocale, 'fr');
      expect(legacy3.semanticVersion, '1.5.0');
    });

    test('Test 100 language identities instantiations', () {
      final ids = <DirectedPairId>{};
      for (int i = 0; i < 100; i++) {
        ids.add(DirectedPairId(
          sourceLocale: 'l$i',
          targetLocale: 't$i',
          semanticVersion: '1.0.0'
        ));
      }
      expect(ids.length, 100);

      // they should have invalid locales according to regex but the object should instantiate fine
      for (final id in ids) {
         expect(id.hasValidLocales, isFalse);
      }
    });
  });
}
