import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cache/lru_memory_cache.dart';
import 'package:deutsch_bilarabi/core/l1_cache.dart';

void main() {
  test('byte budget and entry count enforce deterministic LRU eviction', () {
    final cache = LruMemoryCache<String, int>(
      maxCapacity: 4, maxMemoryBudget: 10,
      sizeEstimator: (_, value) => value,
    );
    expect(cache.put('first', 6), isTrue);
    expect(cache.put('second', 6), isTrue);
    expect(cache.containsKey('first'), isFalse);
    expect(cache.currentMemory, 6);
    expect(cache.put('second', 100), isFalse);
    expect(cache.get('second'), 6);
    expect(cache.currentMemory, 6);
    cache.clear();
    expect(cache.currentMemory, 0);
  });

  test('100 language identities do not produce an unbounded cache', () {
    final cache = L1VocabularyCache()..clear();
    for (var i = 0; i < 100; i++) {
      cache.put('lang_$i', [{'text': 'word_$i'}], direction: 'ar-target');
    }
    expect(cache.identityCount, L1VocabularyCache.maxIdentities);
    expect(cache.has('lang_0', direction: 'ar-target'), isFalse);
    expect(cache.has('lang_99', direction: 'ar-target'), isTrue);
    expect(cache.estimatedMemoryBytes, lessThanOrEqualTo(
        L1VocabularyCache.maxCacheBytes));
    cache.clear();
  });

  test('isolates directed pairs and invalidates only old pack versions', () {
    final cache = L1VocabularyCache()..clear();
    cache.put('de', [{'text': 'eins'}], direction: 'de-ar', packVersion: 1);
    cache.put('de', [{'text': 'one'}], direction: 'de-en', packVersion: 1);
    cache.put('de', [{'text': 'zwei'}], direction: 'de-ar', packVersion: 2);
    expect(cache.get('de', direction: 'ar-de', packVersion: 1), isNull);
    cache.invalidateStale('de', 'de-ar', 2);
    expect(cache.has('de', direction: 'de-ar', packVersion: 1), isFalse);
    expect(cache.has('de', direction: 'de-en', packVersion: 1), isTrue);
    cache.clear();
  });

  test('owned nested payload is immutable and bounded on pressure', () {
    final cache = L1VocabularyCache()..clear();
    final mutable = <String, dynamic>{'meta': <String, dynamic>{'nested': 'old'}};
    cache.put('de', [mutable], direction: 'de-ar');
    (mutable['meta'] as Map<String, dynamic>)['nested'] = 'new';
    final stored = cache.get('de', direction: 'de-ar')!.first;
    expect((stored['meta'] as Map)['nested'], 'old');
    expect(() => (stored['meta'] as Map)['nested'] = 'changed',
        throwsUnsupportedError);
    for (var i = 0; i < 40; i++) {
      cache.put('id_$i', [{'value': i}]);
    }
    cache.onMemoryPressure();
    expect(cache.identityCount, lessThanOrEqualTo(25));
    cache.clear();
  });
}
