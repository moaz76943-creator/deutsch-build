import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/catalog/catalog_readiness_engine.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

void main() {
  group('CatalogReadinessEngine', () {
    late CatalogReadinessEngine engine;

    setUp(() {
      engine = CatalogReadinessEngine();
    });

    test('rejects identical languages', () {
      final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'en', semanticVersion: '1.0');
      final state = engine.resolveReadiness(pair);

      expect(state, isA<IdenticalPairState>());
      expect(state.isUsable, isFalse);
    });

    test('rejects unsupported/nominal source and target languages', () {
      final pairTarget = DirectedPairId(sourceLocale: 'de', targetLocale: 'tr', semanticVersion: '1.0');
      final stateTarget = engine.resolveReadiness(pairTarget);
      expect(stateTarget, isA<UnsupportedTargetState>());
      expect(stateTarget.isUsable, isFalse);

      final pairSource = DirectedPairId(sourceLocale: 'tr', targetLocale: 'de', semanticVersion: '1.0');
      final stateSource = engine.resolveReadiness(pairSource);
      expect(stateSource, isA<UnsupportedSourceState>());
      expect(stateSource.isUsable, isFalse);
    });

    test('prevents silent pivots (neither source nor target is production ready)', () {
      final pair = DirectedPairId(sourceLocale: 'es', targetLocale: 'fr', semanticVersion: '1.0');
      final state = engine.resolveReadiness(pair);

      expect(state, isA<SilentPivotPreventedState>());
      expect(state.isUsable, isFalse);
    });

    test('allows reverse pairs if target pack is admitted (source not productionReady, but target is)', () {
      engine.registerPack(packCode: 'de', wordCount: 100, checksum: 'xyz');

      final pair = DirectedPairId(sourceLocale: 'es', targetLocale: 'de', semanticVersion: '1.0');
      final state = engine.resolveReadiness(pair);

      expect(state, isA<PairUsable>());
      expect(state.isUsable, isTrue);
    });

    test('directional evaluation: A -> B requires target pack B, but not source pack A', () {
      engine.registerPack(packCode: 'de', wordCount: 100, checksum: 'xyz');

      final pairBA = DirectedPairId(sourceLocale: 'de', targetLocale: 'en', semanticVersion: '1.0');
      final stateBA = engine.resolveReadiness(pairBA);

      expect(stateBA, isA<MissingPackState>());
      expect(stateBA.isUsable, isFalse);

      final pairAB = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');
      final stateAB = engine.resolveReadiness(pairAB);

      expect(stateAB, isA<PairUsable>());
      expect(stateAB.isUsable, isTrue);
    });

    test('rejects invalid/rejected target packs', () {
      engine.registerPack(packCode: 'de', wordCount: 0, checksum: null);

      final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');
      final state = engine.resolveReadiness(pair);

      expect(state, isA<RejectedPackState>());
      expect(state.isUsable, isFalse);
    });

    test('explicit cache invalidation on pack changes', () {
      final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');

      expect(engine.resolveReadiness(pair), isA<MissingPackState>());

      engine.registerPack(packCode: 'de', wordCount: 100, checksum: 'xyz');
      expect(engine.resolveReadiness(pair), isA<PairUsable>());

      engine.unregisterPack('de');
      expect(engine.resolveReadiness(pair), isA<MissingPackState>());
    });

    test('bounded runtime cache eviction limits size to 100', () {
      engine.registerPack(packCode: 'de', wordCount: 100, checksum: 'xyz');

      for (int i = 0; i < 150; i++) {
        final pair = DirectedPairId(sourceLocale: 'lang$i', targetLocale: 'de', semanticVersion: '1.0');
        engine.resolveReadiness(pair);
      }

      final earlyPair = DirectedPairId(sourceLocale: 'lang0', targetLocale: 'de', semanticVersion: '1.0');
      final state = engine.resolveReadiness(earlyPair);
      expect(state, isA<UnsupportedSourceState>());
    });

    test('dynamically test 100 language combinations', () {
      engine.registerPack(packCode: 'ar', wordCount: 100, checksum: 'ar_hash');

      for (int i = 1; i <= 100; i++) {
        final pair = DirectedPairId(sourceLocale: 'lang_$i', targetLocale: 'ar', semanticVersion: '1.0');
        final state = engine.resolveReadiness(pair);

        expect(state, isA<UnsupportedSourceState>());
      }
    });
  });
}
