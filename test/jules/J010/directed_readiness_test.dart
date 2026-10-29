import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pack_gate.dart';
import 'package:deutsch_bilarabi/core/catalog/directed_readiness_engine.dart';

void main() {
  group('DirectedPairReadinessEngine', () {
    late DirectedPairReadinessEngine engine;

    setUp(() {
      engine = DirectedPairReadinessEngine();
    });

    test('Evaluating A->B separately from B->A (Directed pair evaluation)', () {
      // ar -> de should be ready (both production ready)
      engine.updatePackStatus('de', const LanguagePackGateResult(PackGateStatus.approved));
      final pairArToDe = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0');
      final resultArToDe = engine.resolvePair(pairArToDe);
      expect(resultArToDe.state, equals(PairReadinessState.ready));

      // de -> ar: source is de, target is ar. If pack ar is not installed/unknown, missingPack
      final pairDeToAr = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');
      final resultDeToAr = engine.resolvePair(pairDeToAr);
      expect(resultDeToAr.state, equals(PairReadinessState.missingPack));

      engine.updatePackStatus('ar', const LanguagePackGateResult(PackGateStatus.approved));
      final resultDeToAr2 = engine.resolvePair(pairDeToAr);
      expect(resultDeToAr2.state, equals(PairReadinessState.ready));
    });

    test('Rejecting identical-language pairs', () {
      final pairDeToDe = DirectedPairId(sourceLocale: 'de', targetLocale: 'de', semanticVersion: '1.0.0');
      final result = engine.resolvePair(pairDeToDe);
      expect(result.state, equals(PairReadinessState.identical));
    });

    test('Rejecting unsupported and nominal languages', () {
      // fr is assetsReady, not productionReady
      final pairArToFr = DirectedPairId(sourceLocale: 'ar', targetLocale: 'fr', semanticVersion: '1.0.0');
      final result = engine.resolvePair(pairArToFr);
      expect(result.state, equals(PairReadinessState.unsupportedTarget));

      final pairFrToDe = DirectedPairId(sourceLocale: 'fr', targetLocale: 'de', semanticVersion: '1.0.0');
      final result2 = engine.resolvePair(pairFrToDe);
      expect(result2.state, equals(PairReadinessState.unsupportedSource));

      // zh is nominal/unsupported (fallback)
      final pairArToZh = DirectedPairId(sourceLocale: 'ar', targetLocale: 'zh', semanticVersion: '1.0.0');
      final result3 = engine.resolvePair(pairArToZh);
      expect(result3.state, equals(PairReadinessState.unsupportedTarget));
    });

    test('Testing different pack states (schema mismatch, rejected)', () {
      engine.updatePackStatus('de', const LanguagePackGateResult(PackGateStatus.schemaMismatch, 'missing vocab'));
      final pairArToDe = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0');
      final result = engine.resolvePair(pairArToDe);
      expect(result.state, equals(PairReadinessState.schemaMismatch));

      engine.updatePackStatus('en', const LanguagePackGateResult(PackGateStatus.missingChecksum, 'bad checksum'));
      final pairArToEn = DirectedPairId(sourceLocale: 'ar', targetLocale: 'en', semanticVersion: '1.0.0');
      final result2 = engine.resolvePair(pairArToEn);
      expect(result2.state, equals(PairReadinessState.rejectedPack));
    });

    test('Explicit invalidation on pack changes and handling stale readiness', () {
      engine.updatePackStatus('de', const LanguagePackGateResult(PackGateStatus.approved));
      final pairArToDe = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0');
      expect(engine.resolvePair(pairArToDe).state, equals(PairReadinessState.ready));

      engine.invalidatePack('de');
      expect(engine.resolvePair(pairArToDe).state, equals(PairReadinessState.missingPack));
    });

    test('Simulating 100 language IDs to guarantee bounds (O(N) packs, bounded pair state)', () {
      // Add 100 distinct local packs (O(N))
      for (int i = 0; i < 100; i++) {
        engine.updatePackStatus('de_$i', const LanguagePackGateResult(PackGateStatus.approved));
      }
      expect(engine.currentPackCacheSize, equals(100));

      // Resolve 200 distinct pairs (in reality only few are production ready based on LanguageReadinessMatrix but they are cached)
      for (int i = 0; i < 200; i++) {
        final pair = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de_$i', semanticVersion: '1.0.0');
        engine.resolvePair(pair);
      }

      // Max cache limit is 100 (bounded memory)
      expect(engine.currentPairCacheSize, lessThanOrEqualTo(100));
    });
  });
}
