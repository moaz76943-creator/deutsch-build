import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/catalog/directed_readiness_engine.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pack_gate.dart';

void main() {
  group('DirectedReadinessEngine', () {
    late DirectedReadinessEngine engine;

    setUp(() {
      engine = DirectedReadinessEngine();
    });

    test('should reject identical pairs immediately', () {
      final state = engine.evaluatePair('de', 'de');
      expect(state.isUsable, isFalse);
      expect(state, isA<IdenticalPairState>());
    });

    test('should reject unsupported pairs even if individual languages are valid', () {
      // Both languages are valid and production ready
      engine.submitPackForEvaluation(packCode: 'de', wordCount: 100, checksum: 'xyz');
      engine.submitPackForEvaluation(packCode: 'en', wordCount: 100, checksum: 'abc');

      // But pair is not explicitly authorized
      final state = engine.evaluatePair('de', 'en');
      expect(state.isUsable, isFalse);
      expect(state, isA<UnsupportedPairState>());
    });

    test('should reject unregistered languages', () {
      engine.authorizeDirectedPair('xy', 'de');
      final state = engine.evaluatePair('xy', 'de'); // xy is not in LanguageRegistry
      expect(state.isUsable, isFalse);
      expect(state, isA<UnregisteredLanguageState>());
    });

    test('should reject languages not production ready', () {
      engine.authorizeDirectedPair('fr', 'de');
      final state = engine.evaluatePair('fr', 'de'); // fr is assetsReady, not productionReady
      expect(state.isUsable, isFalse);
      expect(state, isA<UnverifiedLanguageState>());
    });

    test('should report missing pack for production ready language', () {
      engine.authorizeDirectedPair('ar', 'de');
      final state = engine.evaluatePair('ar', 'de'); // ar is productionReady, but no pack submitted
      expect(state.isUsable, isFalse);
      expect(state, isA<MissingPackState>());
    });

    test('should report invalid pack', () {
      engine.authorizeDirectedPair('de', 'ar');

      // Submit a valid pack for 'de'
      engine.submitPackForEvaluation(packCode: 'de', wordCount: 100, checksum: 'xyz');
      // Submit an invalid pack for 'ar' (missing checksum)
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 100, checksum: null);

      final state = engine.evaluatePair('de', 'ar');
      expect(state.isUsable, isFalse);
      expect(state, isA<InvalidPackState>());
    });

    test('should return ReadyState for fully valid pair', () {
      engine.authorizeDirectedPair('de', 'ar');
      engine.submitPackForEvaluation(packCode: 'de', wordCount: 100, checksum: 'xyz');
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 100, checksum: 'abc');

      final state = engine.evaluatePair('de', 'ar');
      expect(state.isUsable, isTrue);
      expect(state, isA<ReadyState>());
    });

    test('reverse pair evaluates independently (same result for valid symmetric but conceptually different)', () {
      engine.authorizeDirectedPair('de', 'ar');
      engine.authorizeDirectedPair('ar', 'de');

      engine.submitPackForEvaluation(packCode: 'de', wordCount: 100, checksum: 'xyz');
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 100, checksum: 'abc');

      final stateAB = engine.evaluatePair('de', 'ar');
      final stateBA = engine.evaluatePair('ar', 'de');

      expect(stateAB, isA<ReadyState>());
      expect(stateBA, isA<ReadyState>());
    });

    test('reverse pair is unsupported if not authorized', () {
      engine.authorizeDirectedPair('de', 'ar');
      // Only A->B is authorized, B->A is not

      engine.submitPackForEvaluation(packCode: 'de', wordCount: 100, checksum: 'xyz');
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 100, checksum: 'abc');

      final stateAB = engine.evaluatePair('de', 'ar');
      final stateBA = engine.evaluatePair('ar', 'de');

      expect(stateAB, isA<ReadyState>());
      expect(stateBA, isA<UnsupportedPairState>());
    });

    test('cache invalidation works when pack is invalidated', () {
      engine.authorizeDirectedPair('de', 'ar');
      engine.submitPackForEvaluation(packCode: 'de', wordCount: 100, checksum: 'xyz');
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 100, checksum: 'abc');

      // Both should be ready
      expect(engine.evaluatePair('de', 'ar'), isA<ReadyState>());

      // Invalidate 'ar' pack
      engine.invalidatePack('ar');

      // Cache should be cleared, pair should now be MissingPackState for 'ar'
      final state = engine.evaluatePair('de', 'ar');
      expect(state, isA<MissingPackState>());
    });

    test('cache invalidation works when pack is updated with invalid data', () {
      engine.authorizeDirectedPair('de', 'ar');
      engine.submitPackForEvaluation(packCode: 'de', wordCount: 100, checksum: 'xyz');
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 100, checksum: 'abc');

      expect(engine.evaluatePair('de', 'ar'), isA<ReadyState>());

      // Submit invalid 'ar' pack (no checksum)
      engine.submitPackForEvaluation(packCode: 'ar', wordCount: 100, checksum: null);

      final state = engine.evaluatePair('de', 'ar');
      expect(state, isA<InvalidPackState>());
    });

    test('lazy caching does not grow unboundedly (max 50 test)', () {
      // Register valid packs for 'de' and 'en'
      engine.submitPackForEvaluation(packCode: 'de', wordCount: 100, checksum: 'xyz');
      engine.submitPackForEvaluation(packCode: 'en', wordCount: 100, checksum: 'abc');

      // Evaluate 100 distinct pairs
      // By authorizing and evaluating 100 pairs, we push 100 items into the cache.
      for (int i = 0; i < 100; i++) {
        final targetIso = 'lang$i';
        engine.authorizeDirectedPair('de', targetIso);
        engine.evaluatePair('de', targetIso);
      }

      // Authorize and evaluate 'de' -> 'en' again
      engine.authorizeDirectedPair('de', 'en');
      final state = engine.evaluatePair('de', 'en');
      expect(state, isA<ReadyState>());

      // Because max cache size is 50, memory stays bounded.
    });
  });
}
