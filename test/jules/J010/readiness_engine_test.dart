import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/catalog/catalog_readiness_engine.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pack_gate.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pair_readiness.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

void main() {
  late CatalogReadinessEngine engine;

  setUp(() {
    engine = CatalogReadinessEngine();
  });

  test('Reflexive pairs return reflexive state', () {
    final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'de', semanticVersion: '1.0');
    expect(engine.resolvePairReadiness(pair), PairReadinessState.reflexive);
  });

  test('Rejected target pack returns unsupported state', () {
    final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');
    engine.admitPack('de', const LanguagePackGateResult(PackGateStatus.rejected));
    expect(engine.resolvePairReadiness(pair), PairReadinessState.unsupported);
  });

  test('Nominal tier source or target without pack returns registered state', () {
    final pair = DirectedPairId(sourceLocale: 'it', targetLocale: 'ru', semanticVersion: '1.0');
    expect(engine.resolvePairReadiness(pair), PairReadinessState.registered);
  });

  test('Missing packs for assetsReady languages return verified', () {
    // 'fr' and 'es' are assetsReady
    final pair = DirectedPairId(sourceLocale: 'es', targetLocale: 'fr', semanticVersion: '1.0');
    expect(engine.resolvePairReadiness(pair), PairReadinessState.verified);
  });

  test('Approved packs without productionReady return installed', () {
    final pair = DirectedPairId(sourceLocale: 'es', targetLocale: 'fr', semanticVersion: '1.0');
    engine.admitPack('fr', const LanguagePackGateResult(PackGateStatus.approved));
    expect(engine.resolvePairReadiness(pair), PairReadinessState.installed);
  });

  test('Approved packs with productionReady return usable', () {
    // 'en' and 'de' are productionReady
    final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');
    engine.admitPack('de', const LanguagePackGateResult(PackGateStatus.approved));
    expect(engine.resolvePairReadiness(pair), PairReadinessState.usable);
  });

  test('Evaluates A->B separately from B->A', () {
    final ab = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');
    final ba = DirectedPairId(sourceLocale: 'de', targetLocale: 'en', semanticVersion: '1.0');

    // Admit 'de' pack but not 'en' pack
    engine.admitPack('de', const LanguagePackGateResult(PackGateStatus.approved));

    expect(engine.resolvePairReadiness(ab), PairReadinessState.usable);
    expect(engine.resolvePairReadiness(ba), PairReadinessState.verified); // because 'en' pack is not admitted
  });

  test('State invalidation clears readiness (stale readiness test)', () {
    final pair = DirectedPairId(sourceLocale: 'en', targetLocale: 'de', semanticVersion: '1.0');

    engine.admitPack('de', const LanguagePackGateResult(PackGateStatus.approved));
    expect(engine.resolvePairReadiness(pair), PairReadinessState.usable);

    engine.invalidatePack('de');
    expect(engine.resolvePairReadiness(pair), PairReadinessState.verified);
  });

  test('Dynamic generation of 100 fake ids returns registered lazily', () {
    final langs = List.generate(100, (i) => 'lang_$i');
    int registeredCount = 0;

    for (var l1 in langs) {
      for (var l2 in langs) {
        if (l1 == l2) continue;
        final pair = DirectedPairId(sourceLocale: l1, targetLocale: l2, semanticVersion: '1.0');
        final state = engine.resolvePairReadiness(pair);

        expect(state, PairReadinessState.registered);
        registeredCount++;
      }
    }

    expect(registeredCount, 9900);
  });
}
