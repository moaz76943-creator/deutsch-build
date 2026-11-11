import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/cache/cache_identity.dart';
import 'package:deutsch_bilarabi/core/l1_cache.dart';

void main() {
  group('J083 New Stress Tests', () {
    late L1VocabularyCache cache;

    setUp(() {
      cache = L1VocabularyCache();
      cache.clear();
    });

    test('Stress test: 100-language switching bounds memory correctly', () {
      for (int i = 0; i < 150; i++) {
        cache.put(
          'lang_base',
          [{'data': 'A' * 1024}],
          direction: 'dir_$i',
          packVersion: 'v1',
        );
      }
      expect(cache.currentMemoryBytes, lessThanOrEqualTo(5 * 1024 * 1024));
    });

    test('Stress test: Large entries are rejected', () {
      final hugeData = List.generate(10, (i) => {'data': 'B' * 1024 * 1024});
      cache.put('huge', hugeData);
      expect(cache.has('huge'), isFalse);
    });

    test('Stress test: Low-memory signals trigger trimming', () {
      for (int i = 0; i < 50; i++) {
        cache.put('lang_$i', [{'val': 'x'}]);
      }
      cache.onMemoryPressure();
      int count = 0;
      for (int i = 0; i < 50; i++) {
        if (cache.has('lang_$i')) count++;
      }
      expect(count, lessThanOrEqualTo(25));
    });

    test('Stress test: Stale cache keys rejected', () {
      cache.put('stale_key', [{'val': 'stale'}], requestEpoch: 1, activeEpoch: 2);
      expect(cache.has('stale_key'), isFalse);
    });
  });
}
