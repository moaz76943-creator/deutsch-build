import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/catalog/directed_readiness_engine.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pack_gate.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

void main() {
  const ab = DirectedPairId(
    sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0',
  );
  const ba = DirectedPairId(
    sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0',
  );

  test('approved language pack alone never marks directed pair ready', () {
    final engine = DirectedPairReadinessEngine();
    engine.updatePackStatus(
      'de', const LanguagePackGateResult(PackGateStatus.approved),
    );
    expect(engine.resolvePair(ab).state, PairReadinessState.missingDirectedEvidence);
    expect(engine.resolvePair(ba).state, PairReadinessState.missingPack);
    engine.updatePackStatus(
      'ar', const LanguagePackGateResult(PackGateStatus.approved),
    );
    expect(engine.resolvePair(ba).state, PairReadinessState.missingDirectedEvidence);
  });

  test('pack downgrade invalidates readiness and preserves direction', () {
    final engine = DirectedPairReadinessEngine();
    engine.updatePackStatus(
      'de', const LanguagePackGateResult(PackGateStatus.approved),
    );
    expect(engine.resolvePair(ab).state, PairReadinessState.missingDirectedEvidence);
    engine.updatePackStatus(
      'de', const LanguagePackGateResult(PackGateStatus.schemaMismatch),
    );
    expect(engine.resolvePair(ab).state, PairReadinessState.schemaMismatch);
    engine.invalidatePack('de');
    expect(engine.resolvePair(ab).state, PairReadinessState.missingPack);
  });

  test('unknown language and same-language requests fail closed', () {
    final engine = DirectedPairReadinessEngine();
    expect(
      engine.resolvePair(const DirectedPairId(
        sourceLocale: 'ar', targetLocale: 'ar', semanticVersion: '1.0.0',
      )).state, PairReadinessState.identical,
    );
    expect(
      engine.resolvePair(const DirectedPairId(
        sourceLocale: 'ar', targetLocale: 'zh', semanticVersion: '1.0.0',
      )).state, PairReadinessState.unsupportedTarget,
    );
  });

  test('bounded caches never materialize N-squared pair state', () {
    final engine = DirectedPairReadinessEngine(
      maxCachedPairs: 3, maxCachedPacks: 2,
    );
    for (var i = 0; i < 200; i++) {
      final locale = 'a${String.fromCharCode(97 + i ~/ 26)}'
          '${String.fromCharCode(97 + i % 26)}';
      engine.updatePackStatus(
        locale, const LanguagePackGateResult(PackGateStatus.approved),
      );
      engine.resolvePair(DirectedPairId(
        sourceLocale: 'ar', targetLocale: locale, semanticVersion: '1.0.0',
      ));
    }
    expect(() => engine.updatePackStatus(
      '../invalid', const LanguagePackGateResult(PackGateStatus.approved),
    ), throwsArgumentError);
    expect(engine.currentPackCacheSize, lessThanOrEqualTo(2));
    expect(engine.currentPairCacheSize, lessThanOrEqualTo(3));
    engine.clear();
    expect(engine.currentPairCacheSize, 0);
  });
}
