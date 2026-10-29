import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/l1_cache.dart';

void main() {
  group('J083 Adaptive Memory Pressure & LRU Cache Trimming', () {
    late L1VocabularyCache cache;

    setUp(() {
      cache = L1VocabularyCache();
      cache.clear();
    });

    tearDown(() {
      cache.clear();
    });

    test('enforces max capacity with LRU eviction for 100 language switching', () {
      // Assuming max capacity is 20 in the implementation we made.
      for (int i = 0; i < 100; i++) {
        final langCode = 'lang_$i';
        cache.put(langCode, [
          {'id': i, 'word': 'word_$i'}
        ]);
      }

      // Check that oldest entries (0-79) were evicted.
      for (int i = 0; i < 80; i++) {
        expect(cache.has('lang_$i'), isFalse);
      }

      // Check that newest entries (80-99) are still present.
      for (int i = 80; i < 100; i++) {
        expect(cache.has('lang_$i'), isTrue);
      }
    });

    test('rejects oversized entries based on memory budget', () {
      // Assuming max budget is 15MB.
      // Make it huge enough to trigger rejection, limit is 15 * 1024 * 1024 = 15.7M
      final hugeList = List.generate(350000, (i) => {'word': 'very_long_word_$i', 'num': 1});

      cache.put('huge', hugeList);

      // Should not be in cache because it was rejected by the underlying budget
      expect(cache.has('huge'), isFalse);
    });

    test('invalidates stale pack versions properly', () {
      // Put v1
      cache.put('en', [
        {'id': 1}
      ], direction: 'en-es', packVersion: 1);
      // Put v2
      cache.put('en', [
        {'id': 2}
      ], direction: 'en-es', packVersion: 2);

      // We should have both right now.
      expect(cache.has('en', direction: 'en-es', packVersion: 1), isTrue);
      expect(cache.has('en', direction: 'en-es', packVersion: 2), isTrue);

      // Invalidate everything not matching v2
      cache.invalidateStaleVersions('2');

      // v1 should be gone, v2 should remain
      expect(cache.has('en', direction: 'en-es', packVersion: 1), isFalse);
      expect(cache.has('en', direction: 'en-es', packVersion: 2), isTrue);
    });

    test('trims cache gracefully on memory pressure', () {
      // Add 20 items (under the 20 limit)
      for (int i = 0; i < 20; i++) {
        cache.put('lang_$i', [
          {'id': i}
        ]);
      }

      expect(cache.has('lang_0'), isTrue); // First element exists

      // Trigger memory pressure
      cache.onMemoryPressure();

      // Half of max capacity is 10, so size should drop to 10.
      // Therefore, the first 10 (oldest) elements should be evicted (20 - 10 = 10).
      for (int i = 0; i < 10; i++) {
        expect(cache.has('lang_$i'), isFalse, reason: 'lang_$i should be evicted');
      }

      for (int i = 10; i < 20; i++) {
        expect(cache.has('lang_$i'), isTrue, reason: 'lang_$i should remain');
      }
    });

    test('no cross-pair retrieval', () {
      cache.put('es', [{'word': 'hola'}], direction: 'en-es');

      // Attempting to retrieve with a different direction should return null
      expect(cache.get('es', direction: 'fr-es'), isNull);
      expect(cache.has('es', direction: 'fr-es'), isFalse);

      expect(cache.get('es', direction: 'en-es'), isNotNull);
    });
  });
}
