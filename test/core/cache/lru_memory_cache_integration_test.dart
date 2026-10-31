import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cache/lru_memory_cache.dart';
import 'package:deutsch_bilarabi/core/l1_cache.dart';

void main() {
  test('replacement accounting, LRU order and pressure are deterministic', () {
    final cache = LruMemoryCache<String, String>(
      maxCapacity: 3,
      maxMemoryBudget: 10,
      sizeEstimator: (_, value) => value.length,
    );
    expect(cache.put('a', '1234'), isTrue);
    expect(cache.put('b', '1234'), isTrue);
    expect(cache.put('a', '1'), isTrue);
    expect(cache.currentMemory, 5);
    expect(cache.put('c', '12345'), isTrue);
    expect(cache.currentMemory, 10);
    cache.get('a');
    expect(cache.put('d', '12345'), isTrue);
    expect(cache.containsKey('b'), isFalse);
    expect(cache.containsKey('c'), isFalse);
    expect(cache.currentMemory, 6);
    cache.onMemoryPressure();
    expect(cache.currentMemory, lessThanOrEqualTo(5));
    expect(cache.length, lessThanOrEqualTo(1));
    cache.clear();
    expect(cache.currentMemory, 0);
  });

  test('oversized replacement keeps the previous safe value', () {
    final cache = LruMemoryCache<String, String>(
      maxCapacity: 2,
      maxMemoryBudget: 4,
      sizeEstimator: (_, value) => value.length,
    );
    cache.put('a', 'ok');
    expect(cache.put('a', 'oversized'), isFalse);
    expect(cache.get('a'), 'ok');
    expect(cache.currentMemory, 2);
  });

  test('100-language switching has bounded count and isolated identities', () {
    final cache = L1VocabularyCache()..clear();
    for (var i = 0; i < 100; i++) {
      cache.put('language-$i', <Map<String, dynamic>>[
        <String, dynamic>{'word': 'value-$i'},
      ], direction: 'de->language-$i', packVersion: 1);
    }
    expect(cache.retainedIdentities, lessThanOrEqualTo(50));
    expect(cache.estimatedMemoryUsageBytes,
        lessThanOrEqualTo(L1VocabularyCache.maximumEstimatedBytes));
    expect(cache.has('language-0',
        direction: 'de->language-0', packVersion: 1), isFalse);
    expect(cache.has('language-99',
        direction: 'de->language-99', packVersion: 1), isTrue);
    expect(cache.get('language-99',
        direction: 'fr->language-99', packVersion: 1), isNull);
    cache.clear();
  });

  test('nested input mutation cannot escape immutable cache accounting', () {
    final cache = L1VocabularyCache()..clear();
    final nested = <String, dynamic>{'forms': <String>['old']};
    cache.put('de', <Map<String, dynamic>>[nested],
        direction: 'de->ar', packVersion: 2);
    final before = cache.estimatedMemoryUsageBytes;
    (nested['forms'] as List<String>).add('new');
    final stored = cache.get('de', direction: 'de->ar', packVersion: 2)!;
    expect(stored.single['forms'], <String>['old']);
    expect(cache.estimatedMemoryUsageBytes, before);
    expect(() => (stored.single['forms'] as List).add('tamper'),
        throwsUnsupportedError);
    cache.clear();
  });

  test('stale pack eviction and oversized rejection', () {
    final cache = L1VocabularyCache()..clear();
    cache.put('de', <Map<String, dynamic>>[{'a': 'v1'}],
        direction: 'de->ar', packVersion: 1);
    cache.put('de', <Map<String, dynamic>>[{'a': 'v2'}],
        direction: 'de->ar', packVersion: 2);
    cache.invalidateStale('de', 'de->ar', 2);
    expect(cache.has('de', direction: 'de->ar', packVersion: 1), isFalse);
    expect(cache.has('de', direction: 'de->ar', packVersion: 2), isTrue);
    cache.put('oversized', <Map<String, dynamic>>[
      {'payload': List<String>.filled(3 * 1024 * 1024, 'x').join()}
    ]);
    expect(cache.has('oversized'), isFalse);
    cache.clear();
  });
}
