import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/catalog/directed_readiness_engine.dart';

void main() {
  group('DirectedReadinessEngine', () {
    late DirectedReadinessEngine engine;

    setUp(() {
      engine = DirectedReadinessEngine();
    });

    test('maintains backwards compatibility for authorizeDirectedPair', () {
      // Should not throw, does nothing
      engine.authorizeDirectedPair('de', 'ar');
    });

    test('rejects identical source and target languages', () {
      final state = engine.evaluatePair('en', 'en');
      expect(state, isA<IdenticalPairState>());
      expect((state as IdenticalPairState).reason,
          contains('identical'));
    });

    test('rejects unregistered languages', () {
      final state = engine.evaluatePair('xx', 'de');
      expect(state, isA<UnregisteredLanguageState>());
      expect((state as UnregisteredLanguageState).reason,
          contains('Source language "xx" is not registered.'));
    });

    test('rejects nominal (metadata-only) languages', () {
      final stateSource = engine.evaluatePair('tr', 'de');
      expect(stateSource, isA<UnverifiedLanguageState>());
      expect((stateSource as UnverifiedLanguageState).reason,
          contains('nominal and not supported'));

      final stateTarget = engine.evaluatePair('de', 'ru');
      expect(stateTarget, isA<UnverifiedLanguageState>());
      expect((stateTarget as UnverifiedLanguageState).reason,
          contains('nominal and not supported'));
    });

    test('directional evaluation: A -> B requires target pack B, but not source pack A', () {
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 100, checksum: '456');

      final stateEnAr = engine.evaluatePair('en', 'ar');
      expect(stateEnAr, isA<ReadyState>());

      final stateArEn = engine.evaluatePair('ar', 'en');
      expect(stateArEn, isA<MissingPackState>());
      expect((stateArEn as MissingPackState).reason,
          contains('Target language "en" pack is missing.'));
    });

    test('rejects missing target packs', () {
      final state = engine.evaluatePair('de', 'ar');
      expect(state, isA<MissingPackState>());
      expect((state as MissingPackState).reason,
          contains('Target language "ar" pack is missing.'));
    });

    test('rejects rejected target packs', () {
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 0, checksum: '123'); // Invalid count

      final state = engine.evaluatePair('de', 'ar');
      expect(state, isA<InvalidPackState>());
      expect((state as InvalidPackState).reason,
          contains('invalid:'));
    });

    test('prevents silent pivot (es -> fr)', () {
      engine.submitPackForEvaluation(packCode: 'fr', wordCount: 100, checksum: '456');

      final state = engine.evaluatePair('es', 'fr');
      expect(state, isA<SilentPivotPreventedState>());
      expect((state as SilentPivotPreventedState).reason,
          contains('production-ready'));
    });

    test('allows valid direct pair (de -> ar) and reverse (ar -> de) if targets are installed', () {
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 100, checksum: '456');
      engine.submitPackForEvaluation(packCode: 'de', wordCount: 100, checksum: '123');

      final stateDeAr = engine.evaluatePair('de', 'ar');
      expect(stateDeAr, isA<ReadyState>());

      final stateArDe = engine.evaluatePair('ar', 'de');
      expect(stateArDe, isA<ReadyState>());
    });

    test('explicit invalidation clears readiness cache', () {
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 100, checksum: '456');

      // Prime the cache
      expect(engine.evaluatePair('de', 'ar'), isA<ReadyState>());

      // Invalidate target
      engine.invalidatePack('ar');

      expect(engine.evaluatePair('de', 'ar'), isA<MissingPackState>());
    });

    test('bounded LRU caching constraints with 100+ distinct pairs', () {
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 100, checksum: '456');

      // Query 150 distinct language pairs to ensure caching triggers its limit
      for (int i = 0; i < 150; i++) {
        final dummyLang = 'lang$i';
        // Note: these will fail with UnregisteredLanguageState, but they STILL get cached
        engine.evaluatePair(dummyLang, 'ar');
      }

      // Re-query an early pair, it should be evicted and re-computed
      final earlyState = engine.evaluatePair('lang0', 'ar');
      expect(earlyState, isA<UnregisteredLanguageState>());

      // Re-query 'de' -> 'ar' which we'll actually register
      final validState = engine.evaluatePair('de', 'ar');
      expect(validState, isA<ReadyState>());
    });
  });
}
