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
      );

      // 'a' uses 20 bytes
      cache.put('a', '1234567890', itemSizeBytes: 20);
      // 'b' uses 60 bytes, total 80
      cache.put('b', '123456789012345678901234567890', itemSizeBytes: 60);

      expect(cache.length, 2);
      expect(cache.currentMemoryBytes, 80);

      // 'c' uses 40 bytes. Total would be 120, which exceeds 100.
      // Needs to evict 'a' (20 bytes). Now 100. Should fit.
      cache.put('c', '12345678901234567890', itemSizeBytes: 40);

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
      );

      cache.put('huge', '123456789012345678901234567890', itemSizeBytes: 60); // 60 bytes
      expect(cache.containsKey('huge'), isFalse);
      expect(cache.length, 0);
      expect(cache.currentMemoryBytes, 0);
    });

    test('Memory-pressure trimming reduces memory to 50%', () {
      final cache = LruMemoryCache<String, String>(
        maxCapacity: 10,
        maxMemoryBytes: 100,
      );

      cache.put('a', '1234567890', itemSizeBytes: 20); // 20 bytes
      cache.put('b', '1234567890', itemSizeBytes: 20); // 20 bytes
      cache.put('c', '1234567890', itemSizeBytes: 20); // 20 bytes
      cache.put('d', '1234567890', itemSizeBytes: 20); // 20 bytes

      expect(cache.length, 4);
      expect(cache.currentMemoryBytes, 80);

      cache.trimMemoryPressure(); // Trims to 50 (50% of 100)

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
      for (int i = 0; i < 100; i++) {
        final langCode = 'lang$i';
        // Roughly ~150 bytes per item
        l1Cache.put(langCode, [
          {'word': 'word_a', 'meaning': 'meaning_a'},
          {'word': 'word_b', 'meaning': 'meaning_b'},
        ]);
      }

      // Should hit maxCapacity of 50
      int count = 0;
      for (int i = 0; i < 100; i++) {
        final langCode = 'lang$i';
        if (l1Cache.has(langCode)) count++;
      }

      expect(count, lessThanOrEqualTo(50));
    });

    test('Stale asynchronous mutations are correctly rejected', () {
      const langCode = 'de';

      const identity1 = CacheIdentity(language: 'de', direction: 'de_ar', pairEpoch: 1, contentVersion: '1.0.0');
      const identity2 = CacheIdentity(language: 'de', direction: 'de_ar', pairEpoch: 2, contentVersion: '1.0.0');

      // Valid sync mutation epoch 2
      l1Cache.putWithIdentity(
        langCode,
        [{'word': 'valid'}],
        identity2
      );

      // Request started at epoch 1, but active epoch is now 2 (e.g., user navigated away and back)
      l1Cache.putWithIdentity(
        langCode,
        [{'word': 'stale'}],
        identity1
      );

      expect(l1Cache.has(langCode), isTrue);
      expect(l1Cache.get(langCode)!.first['word'], 'valid');
    });

    test('Entries are successfully invalidated after a content version update', () {
      l1Cache.put('de', [{'w': '1'}], direction: 'de_ar', packVersion: 1);
      l1Cache.put('en', [{'w': '2'}], direction: 'en_ar', packVersion: 1);
      l1Cache.put('fr', [{'w': '3'}], direction: 'fr_ar', packVersion: 2); // New version

      expect(l1Cache.has('de', direction: 'de_ar', packVersion: 1), isTrue);
      expect(l1Cache.has('en', direction: 'en_ar', packVersion: 1), isTrue);
      expect(l1Cache.has('fr', direction: 'fr_ar', packVersion: 2), isTrue);

      // Invalidating all non-version 2 entries for 'de' and 'en'
      l1Cache.invalidateStale('de', 'de_ar', 2);
      l1Cache.invalidateStale('en', 'en_ar', 2);

      expect(l1Cache.has('de', direction: 'de_ar', packVersion: 1), isFalse);
      expect(l1Cache.has('en', direction: 'en_ar', packVersion: 1), isFalse);
      expect(l1Cache.has('fr', direction: 'fr_ar', packVersion: 2), isTrue);
    });

    test('Oversized objects are rejected based on size estimator', () {
      const langCode = 'de';

      // Create a giant array to exceed 5MB limit.
      // 150000 items * ~150 bytes = ~22.5MB
      final hugeList = List.generate(150000, (i) => {'word': 'very_long_word_$i'});

      l1Cache.put(langCode, hugeList);

      // Should have been rejected
      expect(l1Cache.has(langCode), isFalse);
    });
  });
}
