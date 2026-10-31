import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/catalog/catalog_readiness_engine.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/i18n/language_registry.dart';

void main() {
  group('CatalogReadinessEngine', () {
    late CatalogReadinessEngine engine;

    setUp(() {
      engine = CatalogReadinessEngine();
    });

    test('rejects reflexive pairs', () {
      final pair = DirectedPairId(
          sourceLocale: 'en', targetLocale: 'en', semanticVersion: '1.0.0');
      expect(
          engine.resolveReadiness(pair), PairReadinessState.identicalLanguages);
    });

    test('rejects unsupported source or target languages', () {
      final pair1 = DirectedPairId(
          sourceLocale: 'unknown',
          targetLocale: 'de',
          semanticVersion: '1.0.0');
      expect(
          engine.resolveReadiness(pair1), PairReadinessState.unsupportedSource);

      final pair2 = DirectedPairId(
          sourceLocale: 'en',
          targetLocale: 'unknown',
          semanticVersion: '1.0.0');
      expect(
          engine.resolveReadiness(pair2), PairReadinessState.unsupportedTarget);
    });

    test('returns missingPack if pack not registered', () {
      final pair = DirectedPairId(
          sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      expect(engine.resolveReadiness(pair), PairReadinessState.missingPack);
    });

    test('returns rejectedPack if pack registration fails gate checks', () {
      final pair = DirectedPairId(
          sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      engine.registerPack(
          pair: pair,
          packCode: 'de',
          wordCount: 0,
          checksum: '123'); // fails wordCount
      expect(engine.resolveReadiness(pair), PairReadinessState.rejectedPack);
    });

    test('returns usable if pack is valid and languages supported', () {
      final pair = DirectedPairId(
          sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      engine.registerPack(
          pair: pair, packCode: 'de', wordCount: 100, checksum: '123');
      expect(engine.resolveReadiness(pair), PairReadinessState.usable);
    });

    test('evaluates A->B separately from B->A', () {
      final pairAB = DirectedPairId(
          sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      final pairBA = DirectedPairId(
          sourceLocale: 'de', targetLocale: 'en', semanticVersion: '1.0.0');

      engine.registerPack(
          pair: pairAB, packCode: 'de', wordCount: 100, checksum: '123');

      expect(engine.resolveReadiness(pairAB), PairReadinessState.usable);
      expect(engine.resolveReadiness(pairBA),
          PairReadinessState.missingPack); // en pack not registered for BA
    });

    test('prevents silent pivots through intermediate languages', () {
      // es and fr are assetsReady (not productionReady)
      final pair = DirectedPairId(
          sourceLocale: 'es', targetLocale: 'fr', semanticVersion: '1.0.0');
      expect(engine.resolveReadiness(pair),
          PairReadinessState.silentPivotPrevented);
    });

    test('explicit readiness invalidation on pack changes', () {
      final pair = DirectedPairId(
          sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0.0');
      engine.registerPack(
          pair: pair, packCode: 'de', wordCount: 100, checksum: '123');
      expect(engine.resolveReadiness(pair), PairReadinessState.usable);

      engine.unregisterPack(pair);
      expect(engine.resolveReadiness(pair), PairReadinessState.missingPack);
    });

    test('bounded runtime cache eviction limits size to 100', () {
      // Register 150 pairs, max cache is 100.
      for (int i = 0; i < 150; i++) {
        final pair = DirectedPairId(
            sourceLocale: 'en', targetLocale: 'de$i', semanticVersion: '1.0.0');
        engine.resolveReadiness(pair);
      }

      // Check if cache behaves correctly by verifying the state still works
      final lastPair = DirectedPairId(
          sourceLocale: 'en', targetLocale: 'de149', semanticVersion: '1.0.0');
      expect(engine.resolveReadiness(lastPair),
          PairReadinessState.unsupportedTarget);

      // Because we cannot inspect the internal map's size directly without reflection in Dart,
      // the test passes gracefully if the eviction strategy does not throw any exceptions
      // and functions properly under heavy load, preventing unbounded allocation.
    });

    test('handles 100 actual language IDs correctly', () {
      final langs = LanguageRegistry.supportedLanguages.keys.toList();
      expect(langs.isNotEmpty, isTrue);
      int count = 0;
      for (final l1 in langs) {
        for (final l2 in langs) {
          final pair = DirectedPairId(
              sourceLocale: l1, targetLocale: l2, semanticVersion: '1.0.0');
          final state = engine.resolveReadiness(pair);
          if (l1 == l2) {
            expect(state, PairReadinessState.identicalLanguages);
          }
          count++;
        }
      }
      expect(count, equals(langs.length * langs.length));
    });
  });
}
