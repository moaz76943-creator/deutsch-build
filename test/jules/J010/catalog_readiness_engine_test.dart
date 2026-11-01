import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/catalog/catalog_readiness_engine.dart';
import 'package:deutsch_bilarabi/core/catalog/canonical_language_catalog.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pair_readiness.dart';
import 'package:deutsch_bilarabi/core/catalog/language_readiness_matrix.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CanonicalLanguageCatalog catalog;
  late CatalogReadinessEngine engine;

  setUpAll(() async {
    final manifestContent = await rootBundle.loadString('assets/data/catalog.json');
    final map = jsonDecode(manifestContent) as Map<String, dynamic>;
    catalog = CanonicalLanguageCatalog.fromJson(map);
  });

  setUp(() {
    engine = CatalogReadinessEngine(catalog);
  });

  group('CatalogReadinessEngine', () {
    test('Reflexive pairs are unavailable', () {
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'de', semanticVersion: '1.0.0');
      final readiness = engine.resolveReadiness(pair);

      expect(readiness, isA<ReadinessReflexive>());
      expect(readiness.state, PairReadinessState.reflexive);
    });

    test('Unsupported pairs are unavailable due to silent pivot', () {
      final pair = DirectedPairId(sourceLocale: 'fr', targetLocale: 'es', semanticVersion: '1.0.0');
      final readiness = engine.resolveReadiness(pair);

      expect(readiness, isA<ReadinessUnsupported>());
      expect((readiness as ReadinessUnsupported).reason, contains('Silent pivot prevented'));
    });

    test('Unsupported pairs due to unknown language in catalog', () {
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'xyz', semanticVersion: '1.0.0');
      final readiness = engine.resolveReadiness(pair);

      expect(readiness, isA<ReadinessUnsupported>());
    });

    test('Valid pair starts as registered without pack', () {
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');
      final readiness = engine.resolveReadiness(pair);

      expect(readiness, isA<ReadinessRegistered>());
    });

    test('Progresses to Verified when valid pack is admitted', () {
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');

      engine.admitPack(
        pair: pair,
        packCode: 'ar',
        wordCount: 100,
        checksum: '123456', // Gate only checks if not null/empty
      );

      final readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessVerified>());
    });

    test('Progresses to Installed when pack marked installed', () {
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');

      engine.admitPack(
        pair: pair,
        packCode: 'ar',
        wordCount: 100,
        checksum: '123456',
      );

      engine.markPackInstalled(pair);

      final readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessInstalled>());
    });

    test('Progresses to Usable when pack marked usable', () {
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');

      engine.admitPack(
        pair: pair,
        packCode: 'ar',
        wordCount: 100,
        checksum: '123456',
      );

      engine.markPackInstalled(pair);
      engine.markPackUsable(pair);

      final readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessUsable>());
    });

    test('Pack invalidation resets readiness', () {
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');

      engine.admitPack(
        pair: pair,
        packCode: 'ar',
        wordCount: 100,
        checksum: '123456',
      );

      engine.markPackInstalled(pair);
      engine.markPackUsable(pair);
      expect(engine.resolveReadiness(pair), isA<ReadinessUsable>());

      engine.invalidatePack(pair);

      expect(engine.resolveReadiness(pair), isA<ReadinessRegistered>());
    });

    test('Rejected pack returns ReadinessRegistered with reject reason', () {
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');

      engine.admitPack(
        pair: pair,
        packCode: '', // empty pack code will reject
        wordCount: 100,
        checksum: '123456',
      );

      final readiness = engine.resolveReadiness(pair);
      expect(readiness, isA<ReadinessRegistered>());
      expect((readiness as ReadinessRegistered).reason, contains('Pack rejected'));
    });

    test('A->B and B->A are distinct', () {
      final pairAB = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');
      final pairBA = DirectedPairId(sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0');

      engine.admitPack(pair: pairAB, packCode: 'ar', wordCount: 100, checksum: '123456');

      expect(engine.resolveReadiness(pairAB), isA<ReadinessVerified>());
      expect(engine.resolveReadiness(pairBA), isA<ReadinessRegistered>()); // No pack for BA yet
    });

    test('Tests capacity logic via evaluating more pairs than cache size', () {
      for (int i = 0; i < 150; i++) {
        // Just mock some pairs, assuming they fail at missing metadata, it still tests cache
        final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'tag$i', semanticVersion: '1.0.0');
        engine.resolveReadiness(pair);
      }

      // We can't access `_evaluatedPairs` directly, but we can resolve again without crashing.
      // And we verify at least the engine evaluates properly.
      final pair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');
      expect(engine.resolveReadiness(pair), isA<ReadinessRegistered>());
    });

    test('Resolves readiness for all catalog languages against DE', () {
      final validDePair = DirectedPairId(sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0');
      // Admitting AR to have at least one usable
      engine.admitPack(
        pair: validDePair,
        packCode: 'ar',
        wordCount: 100,
        checksum: '123456',
      );

      int count = 0;
      for (final targetId in catalog.canonicalIds) {
        if (targetId == 'de') continue;

        final pair = DirectedPairId(sourceLocale: 'de', targetLocale: targetId, semanticVersion: '1.0.0');
        final readiness = engine.resolveReadiness(pair);

        if (targetId == 'ar') {
           expect(readiness, isA<ReadinessVerified>());
        } else {
           if (LanguageReadinessMatrix.getTier(targetId) == LanguageReadinessTier.nominal) {
              expect(readiness, isA<ReadinessUnsupported>());
           } else {
              expect(readiness, isA<ReadinessRegistered>());
           }
        }
        count++;
      }
      expect(count, greaterThanOrEqualTo(99)); // 100 languages minus 1 (de)
    });
  });
}
