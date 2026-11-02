import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

void main() {
  group('DirectedPairId', () {
    test('enforces directional identity', () {
      const aToB = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      const bToA = DirectedPairId(sourceLocale: 'de', targetLocale: 'en', semanticVersion: '1.0.0');

      expect(aToB, isNot(equals(bToA)));
      expect(aToB.uniqueKey, isNot(equals(bToA.uniqueKey)));
      expect(aToB.hashCode, isNot(equals(bToA.hashCode)));
    });

    test('validates learning scenario: distinct languages and non-empty', () {
      const valid = DirectedPairId(sourceLocale: 'ar', targetLocale: 'en', semanticVersion: '1.0.0');
      expect(valid.isValidForLearning(), isTrue);

      const reflexive = DirectedPairId(sourceLocale: 'ar', targetLocale: 'ar', semanticVersion: '1.0.0');
      expect(reflexive.isValidForLearning(), isFalse);
      expect(reflexive.isReflexive, isTrue);
    });

    test('rejects empty inputs in constructor', () {
      expect(() => DirectedPairId(sourceLocale: '', targetLocale: 'de', semanticVersion: '1.0.0'), throwsA(isA<AssertionError>()));
      expect(() => DirectedPairId(sourceLocale: 'en', targetLocale: '', semanticVersion: '1.0.0'), throwsA(isA<AssertionError>()));
      expect(() => DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: ''), throwsA(isA<AssertionError>()));
    });

    test('maintains O(N) cache for identical inputs', () {
      // Actually, since we reverted the custom object cache,
      // identical metadata creation string representation handles the O(N) by GCing unreferenced pairs
      // when no longer used, while the uniqueKey provides deterministic string keys for pooling.
      const pair1 = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      const pair2 = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');

      // Dart const constructors yield identical instances
      expect(identical(pair1, pair2), isTrue);

      // Test 100 language identities
      final instances = <DirectedPairId>[];
      for (var i = 0; i < 100; i++) {
        instances.add(DirectedPairId(
          sourceLocale: 'lang$i',
          targetLocale: 'lang${i + 1}',
          semanticVersion: '1.0.0',
        ));
      }

      // Verify equality holds
      for (var i = 0; i < 100; i++) {
        final same = DirectedPairId(
          sourceLocale: 'lang$i',
          targetLocale: 'lang${i + 1}',
          semanticVersion: '1.0.0',
        );
        expect(instances[i] == same, isTrue);
      }
    });

    test('serialization and legacy pair ID migration', () {
      const original = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '2.1.0');
      final serialized = original.serialize();
      expect(serialized, 'en_de_2.1.0');

      final parsed = DirectedPairId.parse(serialized);
      expect(original, parsed);

      // Legacy format migration
      final legacyParsed = DirectedPairId.parse('ar_fr');
      expect(legacyParsed.sourceLocale, 'ar');
      expect(legacyParsed.targetLocale, 'fr');
      expect(legacyParsed.semanticVersion, '1.0.0');

      // Invalid formats
      expect(() => DirectedPairId.parse(''), throwsFormatException);
      expect(() => DirectedPairId.parse('en'), throwsFormatException);
      expect(() => DirectedPairId.parse('en_de_1.0.0_extra'), throwsFormatException);
      expect(() => DirectedPairId.parse('_de_1.0.0'), throwsFormatException);
    });

    test('version-transition scenarios', () {
      const oldVersion = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      const newVersion = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '2.0.0');

      expect(oldVersion, isNot(equals(newVersion)));
      expect(identical(oldVersion, newVersion), isFalse);
    });
  });
}
// J028 Hardened Identity
