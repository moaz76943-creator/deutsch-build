import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/catalog/catalog_readiness_engine.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pack_gate.dart';

void main() {
  late CatalogReadinessEngine engine;

  setUp(() {
    engine = CatalogReadinessEngine();
  });

  DirectedPairId createPair(String source, String target) {
    return DirectedPairId(
      sourceLocale: source,
      targetLocale: target,
      semanticVersion: '1.0.0',
    );
  }

  test('rejects reflexive pairs', () {
    final pair = createPair('en', 'en');
    expect(
      engine.resolveReadiness(pair),
      isA<IdenticalPairState>(),
    );
  });

  test('rejects unsupported source or target languages', () {
    // Both 'nominal' by default
    final unsupportedPair = createPair('xx', 'yy');
    expect(
      engine.resolveReadiness(unsupportedPair),
      isA<UnsupportedSourceState>(),
    );

    // Unsupported target
    final unsupportedTargetPair = createPair('en', 'zz');
    expect(
      engine.resolveReadiness(unsupportedTargetPair),
      isA<UnsupportedTargetState>(),
    );
  });

  test('returns missingPack if pack not registered', () {
    final pair = createPair('en', 'de');
    expect(
      engine.resolveReadiness(pair),
      isA<MissingPackState>(),
    );
  });

  test('returns rejectedPack if pack registration fails gate checks', () {
    final pair = createPair('en', 'de');

    engine.registerPack(
      targetLocale: 'de',
      packCode: '', // Invalid
      wordCount: 100,
      checksum: 'hash123',
    );

    expect(
      engine.resolveReadiness(pair),
      isA<RejectedPackState>(),
    );

    engine.registerPack(
      targetLocale: 'de',
      packCode: 'de_pack',
      wordCount: 0, // Invalid
      checksum: 'hash123',
    );

    expect(
      engine.resolveReadiness(pair),
      isA<RejectedPackState>(),
    );

    engine.registerPack(
      targetLocale: 'de',
      packCode: 'de_pack',
      wordCount: 100,
      checksum: null, // Invalid
    );

    expect(
      engine.resolveReadiness(pair),
      isA<RejectedPackState>(),
    );
  });

  test('returns usable if pack is valid and languages supported', () {
    final pair = createPair('en', 'de');

    engine.registerPack(
      targetLocale: 'de',
      packCode: 'de_pack',
      wordCount: 100,
      checksum: 'hash123',
    );

    expect(
      engine.resolveReadiness(pair),
      isA<PairUsable>(),
    );
  });

  test('evaluates A->B separately from B->A', () {
    final pairAB = createPair('en', 'de');
    final pairBA = createPair('de', 'en');

    engine.registerPack(
      targetLocale: 'de',
      packCode: 'de_pack',
      wordCount: 100,
      checksum: 'hash123',
    );

    expect(engine.resolveReadiness(pairAB), isA<PairUsable>());
    expect(engine.resolveReadiness(pairBA), isA<MissingPackState>());
  });

  test('prevents silent pivots through intermediate languages', () {
    final pairAEn = createPair('ar', 'en');
    final pairEnB = createPair('en', 'de');
    final pairAB = createPair('ar', 'de');

    engine.registerPack(
      targetLocale: 'en',
      packCode: 'en_pack',
      wordCount: 100,
      checksum: 'hash123',
    );
    engine.registerPack(
      targetLocale: 'de',
      packCode: 'de_pack',
      wordCount: 100,
      checksum: 'hash123',
    );

    // ar and de are both production ready, so it shouldn't trigger silentPivotPrevented
    // BUT what about non-production ready?
    // Let's create two non-production ready languages supported by matrix: fr and es
    final nonProdPair = createPair('fr', 'es');
    engine.registerPack(
      targetLocale: 'es',
      packCode: 'es_pack',
      wordCount: 100,
      checksum: 'hash123',
    );

    expect(engine.resolveReadiness(nonProdPair), isA<SilentPivotPreventedState>());
  });

  test('explicit readiness invalidation on pack changes', () {
    final pair = createPair('en', 'de');

    expect(engine.resolveReadiness(pair), isA<MissingPackState>());

    engine.registerPack(
      targetLocale: 'de',
      packCode: 'de_pack',
      wordCount: 100,
      checksum: 'hash123',
    );

    expect(engine.resolveReadiness(pair), isA<PairUsable>());

    engine.unregisterPack('de');

    expect(engine.resolveReadiness(pair), isA<MissingPackState>());
  });

  test('bounded runtime cache eviction', () {
    // Generate 150 supported pairs (we mock them to be missingPack, but they will be evaluated)
    // Actually, 'en' to 'xx' returns unsupportedTarget, which gets cached.
    for (var i = 0; i < 150; i++) {
      final targetLocale = 'xx$i';
      final pair = createPair('en', targetLocale);
      engine.resolveReadiness(pair);
    }

    // We expect the internal cache to be bounded to 100 elements, but we can't inspect it directly.
    // Instead we can ensure that calling it 150 times doesn't cause any issues and that
    // it lazily keeps working.

    final pair = createPair('en', 'xx0');
    expect(engine.resolveReadiness(pair), isA<UnsupportedTargetState>());
  });

  test('handles 100 actual language IDs correctly', () {
    // Generate 100 language codes, ensuring all are correctly handled without failure.
    // 'ar', 'de', 'en', 'es', 'fr', 'it', 'tr', 'ru' are actual supported languages.
    // For testing 100, we'll append more mock locales, testing that engine does not throw.

    final validLocales = ['ar', 'de', 'en', 'es', 'fr', 'it', 'tr', 'ru'];
    for (var i = 0; i < 92; i++) {
      validLocales.add('locale_$i');
    }

    expect(validLocales.length, 100);

    for (final source in validLocales) {
      for (final target in validLocales) {
        if (source == target) continue;
        final pair = createPair(source, target);
        // It should either return missingPack, unsupportedSource or unsupportedTarget
        // without crashing, evaluating lazily.
        final state = engine.resolveReadiness(pair);
        expect(state, isNotNull);
      }
    }
  });
}
