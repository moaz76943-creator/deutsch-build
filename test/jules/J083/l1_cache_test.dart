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
      // Assuming max capacity is 50.
      for (int i = 0; i < 100; i++) {
        final langCode = cache.generateKey('lang_$i', 'target', '1');
        cache.put(langCode, [
          {'id': i, 'word': 'word_$i'}
        ]);
      }

      // Check that oldest entries (0-49) were evicted.
      for (int i = 0; i < 50; i++) {
        final langCode = cache.generateKey('lang_$i', 'target', '1');
        expect(cache.has(langCode), isFalse);
      }

      // Check that newest entries (50-99) are still present.
      for (int i = 50; i < 100; i++) {
        final langCode = cache.generateKey('lang_$i', 'target', '1');
        expect(cache.has(langCode), isTrue);
      }
    });

    test('rejects oversized entries based on memory budget', () {
      // Assuming max budget is 5MB. We'll create a massive string to force rejection.
      final massiveString = List.filled(3 * 1024 * 1024, 'a').join(); // ~6MB
      final key = cache.generateKey('huge', 'target', '1');
      cache.put(key, [
        {'text': massiveString}
      ]);
      // Should not be in cache because it was rejected by the underlying budget
      expect(cache.has(key), isFalse);
    });

    test('invalidates stale pack versions properly', () {
      final keyV1 = cache.generateKey('en', 'en-es', '1');
      final keyV2 = cache.generateKey('en', 'en-es', '2');

      // Put v1
      cache.put(keyV1, [
        {'id': 1}
      ]);
      // Put v2
      cache.put(keyV2, [
        {'id': 2}
      ]);

      // We should have both right now.
      expect(cache.has(keyV1), isTrue);
      expect(cache.has(keyV2), isTrue);

      // Invalidate everything not matching v2
      cache.invalidateStaleVersions('2');

      // v1 should be gone, v2 should remain
      expect(cache.has(keyV1), isFalse);
      expect(cache.has(keyV2), isTrue);
    });

    test('trims cache gracefully on memory pressure', () {
      // Add 40 items (under the 50 limit)
      for (int i = 0; i < 40; i++) {
        final key = cache.generateKey('lang_$i', 'target', '1');
        cache.put(key, [
          {'id': i}
        ]);
      }

      final firstKey = cache.generateKey('lang_0', 'target', '1');
      expect(cache.has(firstKey), isTrue); // First element exists

      // Trigger memory pressure
      cache.onMemoryPressure();

      // Half of max capacity is 25, so size should drop to 25.
      // Therefore, the first 15 (oldest) elements should be evicted (40 - 25 = 15).
      for (int i = 0; i < 15; i++) {
        final key = cache.generateKey('lang_$i', 'target', '1');
        expect(cache.has(key), isFalse, reason: 'lang_$i should be evicted');
      }

      for (int i = 15; i < 40; i++) {
        final key = cache.generateKey('lang_$i', 'target', '1');
        expect(cache.has(key), isTrue, reason: 'lang_$i should remain');
      }
    });

    test('no cross-pair retrieval', () {
      final key1 = cache.generateKey('es', 'en-es', '1');
      cache.put(key1, [{'word': 'hola'}]);

      // Attempting to retrieve with a different direction should return null
      final key2 = cache.generateKey('es', 'fr-es', '1');
      expect(cache.get(key2), isNull);
      expect(cache.has(key2), isFalse);

      expect(cache.get(key1), isNotNull);
    });
  });
}
