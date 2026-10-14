import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

void main() {
  group('DirectedPairId', () {
    test('directional identity (A->B != B->A)', () {
      const id1 = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      const id2 = DirectedPairId(sourceLocale: 'de', targetLocale: 'en', semanticVersion: '1.0.0');

      expect(id1, isNot(equals(id2)));
      expect(id1.uniqueKey, isNot(equals(id2.uniqueKey)));
      expect(id1.hashCode, isNot(equals(id2.hashCode)));
    });

    test('forLearning validation', () {
      expect(
        () => DirectedPairId.forLearning(
            sourceLocale: 'en', targetLocale: 'en', semanticVersion: '1.0.0'),
        throwsArgumentError,
      );

      final validId = DirectedPairId.forLearning(
          sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      expect(validId.sourceLocale, 'en');
      expect(validId.targetLocale, 'de');
    });

    test('validates non-empty properties on const instantiation', () {
      expect(
        () => DirectedPairId(sourceLocale: '', targetLocale: 'de', semanticVersion: '1.0.0'),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DirectedPairId(sourceLocale: 'en', targetLocale: '', semanticVersion: '1.0.0'),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: ''),
        throwsA(isA<AssertionError>()),
      );
    });

    test('100 language identities generation via loop', () {
      final ids = <DirectedPairId>{};
      for (int i = 0; i < 100; i++) {
        ids.add(DirectedPairId(
          sourceLocale: 'lang$i',
          targetLocale: 'lang${i + 1}',
          semanticVersion: '1.0.$i',
        ));
      }
      expect(ids.length, 100);

      // Verify a subset
      expect(
        ids.contains(const DirectedPairId(sourceLocale: 'lang50', targetLocale: 'lang51', semanticVersion: '1.0.50')),
        isTrue,
      );
    });

    test('legacy string parsing', () {
      final legacyIdStr = 'en_de_1.0.0';
      final parsed = DirectedPairId.parse(legacyIdStr);
      expect(parsed.sourceLocale, 'en');
      expect(parsed.targetLocale, 'de');
      expect(parsed.semanticVersion, '1.0.0');

      // Test parsing with underscores in version
      final legacyIdStr2 = 'en_de_1.0.0_beta_1';
      final parsed2 = DirectedPairId.parse(legacyIdStr2);
      expect(parsed2.sourceLocale, 'en');
      expect(parsed2.targetLocale, 'de');
      expect(parsed2.semanticVersion, '1.0.0_beta_1');

      expect(() => DirectedPairId.parse('en_de'), throwsFormatException);
    });

    test('equality and hashing', () {
      const id1 = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0');
      const id2 = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0');

      expect(id1, equals(id2));
      expect(id1.hashCode, equals(id2.hashCode));
    });

    test('serialization (toMap / fromMap)', () {
      const id1 = DirectedPairId(sourceLocale: 'fr', targetLocale: 'it', semanticVersion: '2.1.0');
      final map = id1.toMap();

      expect(map['sourceLocale'], 'fr');
      expect(map['targetLocale'], 'it');
      expect(map['semanticVersion'], '2.1.0');

      final id2 = DirectedPairId.fromMap(map);
      expect(id1, equals(id2));
    });

    test('isValidForLearning handles reflexive appropriately', () {
      const id1 = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      const id2 = DirectedPairId(sourceLocale: 'de', targetLocale: 'de', semanticVersion: '1.0.0');

      expect(id1.isValidForLearning(), isTrue);
      expect(id2.isValidForLearning(), isFalse);
      expect(id2.isReflexive, isTrue);
    });
  });
}
