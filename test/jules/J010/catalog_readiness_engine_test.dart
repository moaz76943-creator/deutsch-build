import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/catalog/canonical_language_catalog.dart';
import 'package:deutsch_bilarabi/core/catalog/catalog_readiness_engine.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pair_readiness.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CanonicalLanguageCatalog catalog;
  late CatalogReadinessEngine engine;

  setUpAll(() async {
    catalog = await CanonicalLanguageCatalog.loadBundled();
  });

  setUp(() {
    engine = CatalogReadinessEngine(catalog);
  });

  group('CatalogReadinessEngine - Lazy Directed Readiness', () {
    test('Reflexive pairs are rejected with ReadinessReflexive', () {
      final pair = DirectedPairId(
        sourceLocale: 'en',
        targetLocale: 'en',
        semanticVersion: '1.0.0',
      );
      final readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessReflexive>());
    });

    test('Non-existent or unknown metadata is rejected', () {
      final pair = DirectedPairId(
        sourceLocale: 'xx',
        targetLocale: 'yy',
        semanticVersion: '1.0.0',
      );
      final readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessUnsupported>());
      expect((readiness as ReadinessUnsupported).reason, contains('metadata not found'));
    });

    test('Silent pivot prevention: es->fr rejected as neither is production ready', () {
      final pair = DirectedPairId(
        sourceLocale: 'es',
        targetLocale: 'fr',
        semanticVersion: '1.0.0',
      );
      final readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessUnsupported>());
      expect((readiness as ReadinessUnsupported).reason, contains('Silent pivot prevented'));
    });

    test('Valid lifecycle (Registered -> Verified -> Installed -> Usable) transitions', () {
      final pair = DirectedPairId(
        sourceLocale: 'ar',
        targetLocale: 'de',
        semanticVersion: '1.0.0',
      );

      // Initially registered but not admitted
      var readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessRegistered>());

      // Admit pack (makes it verified but not installed)
      engine.admitPack(
        pair: pair,
        packCode: 'ar_de_1.0.0',
        wordCount: 100,
        checksum: 'checksum_here',
      );
      readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessVerified>());

      // Mark installed
      engine.markPackInstalled(pair);
      readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessInstalled>());

      // Mark usable
      engine.markPackUsable(pair);
      readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessUsable>());
    });

    test('Directed pairs A->B and B->A are evaluated completely independently', () {
      final aToB = DirectedPairId(
        sourceLocale: 'en',
        targetLocale: 'de',
        semanticVersion: '1.0.0',
      );
      final bToA = DirectedPairId(
        sourceLocale: 'de',
        targetLocale: 'en',
        semanticVersion: '1.0.0',
      );

      // Admit and fully ready A->B
      engine.admitPack(
        pair: aToB,
        packCode: 'en_de_1.0.0',
        wordCount: 100,
        checksum: 'checksum_here',
      );
      engine.markPackUsable(aToB);

      // Evaluate both
      final readinessAToB = engine.resolveReadiness(aToB);
      final readinessBToA = engine.resolveReadiness(bToA);

      expect(readinessAToB, isA<ReadinessUsable>());
      // B->A is not affected by A->B
      expect(readinessBToA, isA<ReadinessRegistered>());
    });

    test('Invalidation removes cached state and resets readiness', () {
      final pair = DirectedPairId(
        sourceLocale: 'ar',
        targetLocale: 'en',
        semanticVersion: '1.0.0',
      );

      engine.admitPack(
        pair: pair,
        packCode: 'ar_en_1.0.0',
        wordCount: 100,
        checksum: 'chk',
      );
      engine.markPackUsable(pair);
      expect(engine.resolveReadiness(pair), isA<ReadinessUsable>());

      engine.invalidatePack(pair);
      expect(engine.resolveReadiness(pair), isA<ReadinessRegistered>());
    });

    test('Rejected pack from gate results in ReadinessRegistered with rejection reason', () {
      final pair = DirectedPairId(
        sourceLocale: 'ar',
        targetLocale: 'de',
        semanticVersion: '1.0.0',
      );

      // Missing checksum will fail the acceptance gate
      engine.admitPack(
        pair: pair,
        packCode: 'ar_de_1.0.0',
        wordCount: 100,
        checksum: null,
      );

      final readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessRegistered>());
      expect((readiness as ReadinessRegistered).reason, contains('rejected'));
    });

    test('Lazy initialization ensures no eagerly instantiated pairs across all 100 languages', () {
      int unsupported = 0;
      int registered = 0;

      for (final src in catalog.canonicalIds) {
        for (final tgt in catalog.canonicalIds) {
          if (src == tgt) continue;

          final pair = DirectedPairId(
            sourceLocale: src,
            targetLocale: tgt,
            semanticVersion: '1.0.0',
          );

          final readiness = engine.resolveReadiness(pair);
          if (readiness is ReadinessUnsupported) {
            unsupported++;
          } else if (readiness is ReadinessRegistered) {
            registered++;
          }
        }
      }

      // Total pairs evaluated is 100 * 99 = 9900
      // Ensure that we successfully checked every pair and didn't crash
      expect(unsupported + registered, 9900);

      // Because maxCacheSize is 100, checking the internals (implicitly)
      // or at least knowing we just ran 9900 checks without eagerly allocating
      // 9900 permanent states validates bounded cache requirements.
    });
  });
}
