import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/catalog/directed_catalog_readiness.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

void main() {
  group('DirectedCatalogReadiness', () {
    late DirectedCatalogReadiness readiness;

    setUp(() {
      readiness = DirectedCatalogReadiness();
    });

    test('should reject unsupported source', () {
      final pair = DirectedPairId(sourceLocale: 'xx', targetLocale: 'de', semanticVersion: '1.0.0');
      final result = readiness.resolvePairStatus(pair);
      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.unsupportedSource);
    });

    test('should reject identical languages', () {
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'de', semanticVersion: '1.0.0');
      final result = readiness.resolvePairStatus(pair);
      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.identicalLanguages);
    });

    test('should reject unsupported target', () {
      readiness.registerLanguage('de');
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'xx', semanticVersion: '1.0.0');
      final result = readiness.resolvePairStatus(pair);
      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.unsupportedTarget);
    });

    test('should reject silent pivot through unverified languages', () {
      readiness.registerLanguage('it');
      readiness.registerLanguage('ja');
      final pair = DirectedPairId(sourceLocale: 'it', targetLocale: 'ja', semanticVersion: '1.0.0');
      final result = readiness.resolvePairStatus(pair);
      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.silentPivotPrevented);
    });

    test('should return target missing pack', () {
      readiness.registerLanguage('de');
      readiness.registerLanguage('ar');
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');
      final result = readiness.resolvePairStatus(pair);
      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.targetMissingPack);
    });

    test('should return target pack rejected', () {
      readiness.registerLanguage('de');
      readiness.registerLanguage('ar');
      readiness.markInstalled('ar', 0, 'checksum123'); // 0 words causes rejected
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');
      final result = readiness.resolvePairStatus(pair);
      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.targetPackRejected);
    });

    test('should allow valid pairs', () {
      readiness.registerLanguage('de');
      readiness.registerLanguage('ar');
      readiness.markInstalled('ar', 100, 'checksum123');
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');
      final result = readiness.resolvePairStatus(pair);
      expect(result, isA<PairUsable>());
    });

    test('should allow reverse pair differently if target not installed', () {
      readiness.registerLanguage('de');
      readiness.registerLanguage('ar');
      readiness.markInstalled('ar', 100, 'checksum123');

      final pair1 = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');
      expect(readiness.resolvePairStatus(pair1), isA<PairUsable>());

      final pair2 = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0');
      final result2 = readiness.resolvePairStatus(pair2);
      expect(result2, isA<PairUnavailable>());
      expect((result2 as PairUnavailable).reason, UnavailableReason.targetMissingPack);
    });

    test('should invalidate pack', () {
      readiness.registerLanguage('de');
      readiness.registerLanguage('ar');
      readiness.markInstalled('ar', 100, 'checksum123');

      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');
      expect(readiness.resolvePairStatus(pair), isA<PairUsable>());

      readiness.invalidatePack('ar');
      final result = readiness.resolvePairStatus(pair);
      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.targetMissingPack);
    });

    test('supports large number of languages', () {
      for (var i = 0; i < 100; i++) {
        readiness.registerLanguage('lang$i');
        readiness.markInstalled('lang$i', 10, 'sum');
      }

      readiness.registerLanguage('de');
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'lang50', semanticVersion: '1.0.0');
      expect(readiness.resolvePairStatus(pair), isA<PairUsable>());
    });

    test('can resolve 100 languages', () {
       readiness.registerLanguage('de');
       for (var i = 0; i < 100; i++) {
         readiness.registerLanguage('lang$i');
         readiness.markInstalled('lang$i', 100, 'sum');
       }

       int usableCount = 0;
       for(var i = 0; i < 100; i++) {
         final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'lang$i', semanticVersion: '1.0.0');
         if (readiness.resolvePairStatus(pair) is PairUsable) {
            usableCount++;
         }
       }
       expect(usableCount, 100);
    });
  });
}
