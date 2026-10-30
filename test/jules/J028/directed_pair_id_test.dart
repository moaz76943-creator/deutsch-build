import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

void main() {
  group('DirectedPairId', () {
    test('Equality and Hashing (O(N) Set behavior)', () {
      final set = <DirectedPairId>{};

      for (int i = 0; i < 100; i++) {
        set.add(DirectedPairId(
          sourceLocale: 'loc_$i',
          targetLocale: 'tgt_$i',
          semanticVersion: '1.0.0',
        ));
      }
      expect(set.length, 100);

      // Attempting to add duplicates should not increase length
      for (int i = 0; i < 100; i++) {
        set.add(DirectedPairId(
          sourceLocale: 'loc_$i',
          targetLocale: 'tgt_$i',
          semanticVersion: '1.0.0',
        ));
      }
      expect(set.length, 100);
    });

    test('Directional identity: A->B differs from B->A', () {
      final pair1 = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0');
      final pair2 = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');

      expect(pair1 == pair2, isFalse);
      expect(pair1.hashCode == pair2.hashCode, isFalse);
    });

    test('Invalid locales and version-transition scenarios', () {
      final valid = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0');
      expect(valid.isValidForLearning(), isTrue);

      final reflexive = DirectedPairId(sourceLocale: 'ar', targetLocale: 'ar', semanticVersion: '1.0.0');
      expect(reflexive.isValidForLearning(), isFalse);

      final emptySource = DirectedPairId(sourceLocale: '', targetLocale: 'de', semanticVersion: '1.0.0');
      expect(emptySource.isValidForLearning(), isFalse);

      final emptyTarget = DirectedPairId(sourceLocale: 'ar', targetLocale: '', semanticVersion: '1.0.0');
      expect(emptyTarget.isValidForLearning(), isFalse);

      final emptyVersion = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '');
      expect(emptyVersion.isValidForLearning(), isFalse);
    });

    test('JSON serialization', () {
      final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'es', semanticVersion: '2.1.0');
      final json = pair.toJson();
      final restored = DirectedPairId.fromJson(json);

      expect(restored, equals(pair));
    });

    test('Legacy string parsing', () {
      final legacy1 = DirectedPairId.fromLegacyString('ar_de');
      expect(legacy1.sourceLocale, 'ar');
      expect(legacy1.targetLocale, 'de');
      expect(legacy1.semanticVersion, '1.0.0'); // defaults to 1.0.0

      final legacy2 = DirectedPairId.fromLegacyString('ar_de_2.0.0');
      expect(legacy2.sourceLocale, 'ar');
      expect(legacy2.targetLocale, 'de');
      expect(legacy2.semanticVersion, '2.0.0');

      final legacy3 = DirectedPairId.fromLegacyString('ar_de_2.0.0_beta');
      expect(legacy3.sourceLocale, 'ar');
      expect(legacy3.targetLocale, 'de');
      expect(legacy3.semanticVersion, '2.0.0_beta');

      expect(() => DirectedPairId.fromLegacyString('invalid'), throwsFormatException);
    });
  });
}
