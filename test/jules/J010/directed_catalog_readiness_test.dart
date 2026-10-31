import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/catalog/directed_catalog_readiness.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

void main() {
  group('DirectedCatalogReadiness', () {
    late DirectedCatalogReadiness readiness;

    setUp(() {
      readiness = DirectedCatalogReadiness();
      // Register a few languages
      readiness.registerLanguage('en');
      readiness.registerLanguage('de');
      readiness.registerLanguage('es');
      readiness.registerLanguage('fr');
      readiness.registerLanguage('ar');
    });

    test('resolvePairStatus rejects identical languages', () {
      final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'en', semanticVersion: '1.0');
      final result = readiness.resolvePairStatus(pair);

      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.identicalLanguages);
    });

    test('resolvePairStatus rejects unregistered source language', () {
      final pair = DirectedPairId(sourceLocale: 'xx', targetLocale: 'de', semanticVersion: '1.0');
      final result = readiness.resolvePairStatus(pair);

      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.unsupportedSource);
    });

    test('resolvePairStatus rejects unregistered target language', () {
      final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'xx', semanticVersion: '1.0');
      final result = readiness.resolvePairStatus(pair);

      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.unsupportedTarget);
    });

    test('resolvePairStatus prevents silent pivots (neither source nor target production ready)', () {
      // es and fr are assetsReady according to LanguageReadinessMatrix
      final pair = DirectedPairId(sourceLocale: 'es', targetLocale: 'fr', semanticVersion: '1.0');
      final result = readiness.resolvePairStatus(pair);

      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.silentPivotPrevented);
    });

    test('resolvePairStatus permits reverse pairs (source not production ready, but target is)', () {
      // es is assetsReady, de is productionReady
      readiness.markInstalled('de', 100, 'valid_checksum');
      final pair = DirectedPairId(sourceLocale: 'es', targetLocale: 'de', semanticVersion: '1.0');
      final result = readiness.resolvePairStatus(pair);

      expect(result, isA<PairUsable>());
    });

    test('resolvePairStatus rejects when target pack is missing', () {
      final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');
      final result = readiness.resolvePairStatus(pair);

      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.targetMissingPack);
    });

    test('resolvePairStatus rejects when target pack is rejected by gate', () {
      // Missing checksum
      readiness.markInstalled('de', 100, '');
      final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');
      final result = readiness.resolvePairStatus(pair);

      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.targetPackRejected);
    });

    test('resolvePairStatus returns PairUsable for valid A->B setup', () {
      readiness.markInstalled('de', 100, 'valid_checksum');
      final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');
      final result = readiness.resolvePairStatus(pair);

      expect(result, isA<PairUsable>());
    });

    test('A->B is separate from B->A', () {
      readiness.markInstalled('de', 100, 'valid_checksum');

      final pairAB = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');
      expect(readiness.resolvePairStatus(pairAB), isA<PairUsable>());

      final pairBA = DirectedPairId(sourceLocale: 'de', targetLocale: 'en', semanticVersion: '1.0');
      // B->A fails because en pack is not installed
      final resultBA = readiness.resolvePairStatus(pairBA);
      expect(resultBA, isA<PairUnavailable>());
      expect((resultBA as PairUnavailable).reason, UnavailableReason.targetMissingPack);
    });

    test('invalidatePack resets readiness', () {
      readiness.markInstalled('de', 100, 'valid_checksum');
      final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');

      expect(readiness.resolvePairStatus(pair), isA<PairUsable>());

      readiness.invalidatePack('de');
      final result = readiness.resolvePairStatus(pair);

      expect(result, isA<PairUnavailable>());
      expect((result as PairUnavailable).reason, UnavailableReason.targetMissingPack);
    });

    test('Dynamically test 100 languages', () {
      // Simulate 100 languages
      for (int i = 1; i <= 100; i++) {
        final code = 'lang_$i';
        readiness.registerLanguage(code);
      }

      // Check one specific dynamically added language.
      // Assuming 'lang_50' is nominal (not production ready)
      final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'lang_50', semanticVersion: '1.0');
      final result1 = readiness.resolvePairStatus(pair);
      expect(result1, isA<PairUnavailable>());
      expect((result1 as PairUnavailable).reason, UnavailableReason.targetMissingPack);

      // Install it
      readiness.markInstalled('lang_50', 50, 'hash50');
      final result2 = readiness.resolvePairStatus(pair);
      expect(result2, isA<PairUsable>());
    });
  });
}
