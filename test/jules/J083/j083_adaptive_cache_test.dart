import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cache/cache_identity.dart';
import 'package:deutsch_bilarabi/core/cache/lru_memory_cache.dart';
import 'package:deutsch_bilarabi/core/l1_cache.dart';

void main() {
  group('LruMemoryCache Core', () {
    test('Evicts items when maxCapacity is exceeded', () {
      final cache = LruMemoryCache<String, String>(maxCapacity: 3, maxMemoryBytes: 1024);
      cache.put('a', '1');
      cache.put('b', '2');
      cache.put('c', '3');
      cache.put('d', '4');

      expect(cache.length, 3);
      expect(cache.containsKey('a'), isFalse);
      expect(cache.containsKey('b'), isTrue);
    });

    test('Evicts items based on maxMemoryBytes limit and estimates', () {
      final cache = LruMemoryCache<String, String>(
        maxCapacity: 10,
        maxMemoryBytes: 100,
        sizeEstimator: (k, v) => v.length * 2, // 2 bytes per char
      );

      // 'a' uses 20 bytes
      cache.put('a', '1234567890');
      // 'b' uses 60 bytes, total 80
      cache.put('b', '123456789012345678901234567890');

      expect(cache.length, 2);
      expect(cache.currentMemoryBytes, 80);

      // 'c' uses 40 bytes. Total would be 120, which exceeds 100.
      // Needs to evict 'a' (20 bytes). Now 100. Should fit.
      cache.put('c', '12345678901234567890');

      expect(cache.length, 2);
      expect(cache.containsKey('a'), isFalse);
      expect(cache.containsKey('b'), isTrue);
      expect(cache.containsKey('c'), isTrue);
      expect(cache.currentMemoryBytes, 100);
    });

    test('Rejects explicitly oversized objects without uncontrolled allocation', () {
      final cache = LruMemoryCache<String, String>(
        maxCapacity: 10,
        maxMemoryBytes: 50,
        sizeEstimator: (k, v) => v.length * 2,
      );

      cache.put('huge', '123456789012345678901234567890'); // 60 bytes
      expect(cache.containsKey('huge'), isFalse);
      expect(cache.length, 0);
      expect(cache.currentMemoryBytes, 0);
    });

    test('Memory-pressure trimming reduces memory to 50%', () {
      final cache = LruMemoryCache<String, String>(
        maxCapacity: 10,
        maxMemoryBytes: 100,
        sizeEstimator: (k, v) => v.length * 2,
      );

      cache.put('a', '1234567890'); // 20 bytes
      cache.put('b', '1234567890'); // 20 bytes
      cache.put('c', '1234567890'); // 20 bytes
      cache.put('d', '1234567890'); // 20 bytes

      expect(cache.length, 4);
      expect(cache.currentMemoryBytes, 80);

      cache.onMemoryPressure(); // Trims to 50 (50% of 100)

      expect(cache.currentMemoryBytes, 40); // Will evict 'a' and 'b' to get under 50
      expect(cache.length, 2);
      expect(cache.containsKey('a'), isFalse);
      expect(cache.containsKey('b'), isFalse);
      expect(cache.containsKey('c'), isTrue);
      expect(cache.containsKey('d'), isTrue);
    });
  });

  group('L1VocabularyCache Limits & Invalidations', () {
    late L1VocabularyCache l1Cache;

    setUp(() {
      l1Cache = L1VocabularyCache();
      l1Cache.clear();
    });

    test('Switching among 100 language identities bounds memory', () {
      for (int i = 0; i < 150; i++) {
        final key = l1Cache.generateKey('lang$i', 'target', '1.0.0');
        // Roughly ~150 bytes per item
        l1Cache.put(key, [
          {'word': 'word_a', 'meaning': 'meaning_a'},
          {'word': 'word_b', 'meaning': 'meaning_b'},
        ]);
      }

      // Should hit maxCapacity of 100
      int count = 0;
      for (int i = 0; i < 150; i++) {
        final key = l1Cache.generateKey('lang$i', 'target', '1.0.0');
        if (l1Cache.has(key)) count++;
      }

      expect(count, lessThanOrEqualTo(100));
      expect(l1Cache.currentMemoryBytes, lessThanOrEqualTo(10 * 1024 * 1024));
    });

    test('Stale asynchronous mutations are correctly rejected', () {
      final key = l1Cache.generateKey('de', 'ar', '1.0.0');

      // Request started at epoch 1, but active epoch is now 2 (e.g., user navigated away and back)
      l1Cache.put(
        key,
        [{'word': 'stale'}],
        requestEpoch: 1,
        activeEpoch: 2
      );

      expect(l1Cache.has(key), isFalse);

      // Valid sync mutation
      l1Cache.put(
        key,
        [{'word': 'valid'}],
        requestEpoch: 2,
        activeEpoch: 2
      );

      expect(l1Cache.has(key), isTrue);
      expect(l1Cache.get(key)!.first['word'], 'valid');
    });

    test('Entries are successfully invalidated after a content version update', () {
      l1Cache.put(l1Cache.generateKey('de', 'ar', '1.0.0'), [{'w': '1'}], direction: 'de_ar', packVersion: '1.0.0');
      l1Cache.put(l1Cache.generateKey('en', 'ar', '1.0.0'), [{'w': '2'}], direction: 'en_ar', packVersion: '1.0.0');
      l1Cache.put(l1Cache.generateKey('fr', 'ar', '1.1.0'), [{'w': '3'}], direction: 'fr_ar', packVersion: '1.1.0'); // New version

      expect(l1Cache.has(l1Cache.generateKey('de', 'ar', '1.0.0')), isTrue);
      expect(l1Cache.has(l1Cache.generateKey('en', 'ar', '1.0.0')), isTrue);
      expect(l1Cache.has(l1Cache.generateKey('fr', 'ar', '1.1.0')), isTrue);

      // Invalidating all non-1.1.0 entries
      l1Cache.invalidateStaleVersions('1.1.0');

      expect(l1Cache.has(l1Cache.generateKey('de', 'ar', '1.0.0')), isFalse);
      expect(l1Cache.has(l1Cache.generateKey('en', 'ar', '1.0.0')), isFalse);
      expect(l1Cache.has(l1Cache.generateKey('fr', 'ar', '1.1.0')), isTrue);
    });

    test('Oversized objects are rejected based on size estimator', () {
      final key = l1Cache.generateKey('de', 'ar', '1.0.0');

      // Create a giant array to exceed 10MB limit.
      // 400000 items * ~150 bytes = ~60MB
      final hugeList = List.generate(400000, (i) => {'word': 'very_long_word_$i'});

      l1Cache.put(key, hugeList);

      // Should have been rejected
      expect(l1Cache.has(key), isFalse);
      expect(l1Cache.currentMemoryBytes, 0);
    });

    test('No cross-pair stale retrieval using directional args', () {
      final key = 'es';
      l1Cache.put(key, [{'word': 'hola'}], direction: 'en-es', packVersion: '1.0.0');

      // Attempting to retrieve with a different direction should return null
      expect(l1Cache.get(key, direction: 'fr-es'), isNull);
      expect(l1Cache.has(key, direction: 'fr-es'), isFalse);

      expect(l1Cache.get(key, direction: 'en-es'), isNotNull);
      expect(l1Cache.has(key, direction: 'en-es'), isTrue);
    });
  });
}
