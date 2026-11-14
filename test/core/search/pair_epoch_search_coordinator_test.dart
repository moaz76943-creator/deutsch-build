import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/search/pair_epoch_search_coordinator.dart';

void main() {
  group('PairEpochSearchCoordinator Tests', () {
    late PairEpochSearchCoordinator coordinator;

    setUp(() {
      coordinator = PairEpochSearchCoordinator();
    });

    tearDown(() {
      coordinator.dispose();
    });

    test('Discards stale search results from pair A when language pair is switched to pair B', () async {
      coordinator.switchLanguagePair('de_ar');

      // 1. Slow search query initiated for de_ar (50ms latency)
      final slowDeArQuery = coordinator.executeSearch(
        query: 'haus',
        fetchCandidates: (pair) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return [const SearchResultItem(term: 'Haus', gloss: 'بيت', pairId: 'de_ar')];
        },
      );

      // 2. User immediately switches language pair to es_ar after 10ms
      await Future.delayed(const Duration(milliseconds: 10));
      coordinator.switchLanguagePair('es_ar');

      // 3. Fast search query initiated for new pair es_ar (10ms latency)
      final fastEsArQuery = coordinator.executeSearch(
        query: 'casa',
        fetchCandidates: (pair) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return [const SearchResultItem(term: 'Casa', gloss: 'منزل', pairId: 'es_ar')];
        },
      );

      final results = await Future.wait([slowDeArQuery, fastEsArQuery]);

      // Assert de_ar results were dropped (null) due to epoch mismatch
      expect(results[0], isNull);

      // Assert es_ar results arrived and matched current state
      expect(results[1], isNotNull);
      expect(results[1]!.length, equals(1));
      expect(results[1]!.first.pairId, equals('es_ar'));
      expect(results[1]!.first.term, equals('Casa'));
    });

    test('Rapid consecutive keystrokes drop intermediate queries in favor of latest query', () async {
      // Keystroke 1: 'h' (slow)
      final q1 = coordinator.executeSearch(
        query: 'h',
        fetchCandidates: (_) async {
          await Future.delayed(const Duration(milliseconds: 40));
          return [const SearchResultItem(term: 'H', gloss: 'H', pairId: 'de_ar')];
        },
      );

      // Keystroke 2: 'ha' (fast)
      final q2 = coordinator.executeSearch(
        query: 'ha',
        fetchCandidates: (_) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return [const SearchResultItem(term: 'Hallo', gloss: 'مرحبا', pairId: 'de_ar')];
        },
      );

      final res = await Future.wait([q1, q2]);
      expect(res[0], isNull); // Superseded query dropped
      expect(res[1], isNotNull);
      expect(res[1]!.first.term, equals('Hallo'));
    });
  });
}
