import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cache/cache_identity.dart';
import 'package:deutsch_bilarabi/core/cache/lru_memory_cache.dart';
import 'package:deutsch_bilarabi/core/l1_cache.dart';

void main() {
  group('LruMemoryCache', () {
    test('enforces maxCapacity', () {
      final cache = LruMemoryCache<int, int>(maxCapacity: 3);
      cache.put(1, 10);
      cache.put(2, 20);
      cache.put(3, 30);
      cache.put(4, 40);

      expect(cache.length, 3);
      expect(cache.containsKey(1), isFalse);
      expect(cache.containsKey(2), isTrue);
    });

    test('enforces maxMemoryBytes by evicting older items', () {
      final cache = LruMemoryCache<int, int>(maxCapacity: 100, maxMemoryBytes: 100);
      cache.put(1, 10, itemSizeBytes: 40);
      cache.put(2, 20, itemSizeBytes: 40);
      cache.put(3, 30, itemSizeBytes: 40); // Will trigger eviction of 1

      expect(cache.length, 2);
      expect(cache.containsKey(1), isFalse);
      expect(cache.currentMemoryBytes, 80);
    });

    test('rejects oversized items entirely', () {
      final cache = LruMemoryCache<int, int>(maxCapacity: 100, maxMemoryBytes: 100);
      cache.put(1, 10, itemSizeBytes: 40);
      cache.put(2, 20, itemSizeBytes: 150); // Rejected

      expect(cache.length, 1);
      expect(cache.containsKey(2), isFalse);
      expect(cache.currentMemoryBytes, 40);
    });

    test('trimMemoryPressure halves limits', () {
      final cache = LruMemoryCache<int, int>(maxCapacity: 4, maxMemoryBytes: 100);
      cache.put(1, 10, itemSizeBytes: 20);
      cache.put(2, 20, itemSizeBytes: 20);
      cache.put(3, 30, itemSizeBytes: 20);
      cache.put(4, 40, itemSizeBytes: 20);

      cache.trimMemoryPressure();

      // target capacity = 2
      expect(cache.length, 2);
      expect(cache.containsKey(1), isFalse);
      expect(cache.containsKey(2), isFalse);
      expect(cache.containsKey(3), isTrue);
      expect(cache.containsKey(4), isTrue);
      expect(cache.currentMemoryBytes, 40);
    });
  });

  group('L1VocabularyCache', () {
    late L1VocabularyCache l1Cache;

    setUp(() {
      l1Cache = L1VocabularyCache();
      l1Cache.clear();
    });

    test('stress test: switching 100 languages enforces limits without unbounded growth', () {
      for (int i = 0; i < 150; i++) {
        final langCode = 'lang_$i';
        l1Cache.put(langCode, [
          {'key1': 'value1', 'key2': 2}
        ]);
      }

      // Since maxCapacity is 100, checking if length bounds are enforced indirectly
      // by asserting the first elements are evicted
      expect(l1Cache.has('lang_0'), isFalse);
      expect(l1Cache.has('lang_149'), isTrue);
    });

    test('rejects stale asynchronous updates correctly', () {
      const identity1 = CacheIdentity(language: 'en', direction: 'en_es', pairEpoch: 100, contentVersion: 'v1');
      const identity2 = CacheIdentity(language: 'en', direction: 'en_es', pairEpoch: 90, contentVersion: 'v1');

      l1Cache.putWithIdentity('lang_en', [
        {'id': 'fresh_data'}
      ], identity1);

      // Attempt to put stale data
      l1Cache.putWithIdentity('lang_en', [
        {'id': 'stale_data'}
      ], identity2);

      final result = l1Cache.get('lang_en', direction: 'en_es', packVersion: 'v1' as dynamic);
      expect(result![0]['id'], 'fresh_data');
    });

    test('invalidates stale entries scoped by language/direction for newer pairEpoch', () {
      const oldIdentity = CacheIdentity(language: 'en', direction: 'en_es', pairEpoch: 100, contentVersion: 'v1');
      const newIdentity = CacheIdentity(language: 'en', direction: 'en_es', pairEpoch: 110, contentVersion: 'v1');

      l1Cache.putWithIdentity('lang_en_v1', [{'id': 'old'}], oldIdentity);
      l1Cache.putWithIdentity('lang_en_v2', [{'id': 'new'}], newIdentity);

      expect(l1Cache.has('lang_en_v1', direction: 'en_es', packVersion: 'v1' as dynamic), isFalse);
      expect(l1Cache.has('lang_en_v2', direction: 'en_es', packVersion: 'v1' as dynamic), isTrue);
    });

    test('trimMemoryPressure trims items appropriately', () {
      for (int i = 0; i < 100; i++) {
        l1Cache.put('lang_$i', [{'data': 'test_data'}]);
      }

      l1Cache.trimMemoryPressure();

      // Should cut down capacity (e.g. max 100 / 2 = 50 roughly)
      expect(l1Cache.has('lang_0'), isFalse);
      expect(l1Cache.has('lang_99'), isTrue);
    });
  });
}
