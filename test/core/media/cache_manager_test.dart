import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/media/cache_manager.dart';

void main() {
  test('LRU access refreshes recency before eviction', () {
    final cache = CacheManager(maxEntries: 2, maxBytes: 100);
    cache.put('a', Uint8List.fromList(<int>[1]));
    cache.put('b', Uint8List.fromList(<int>[2]));

    expect(cache.get('a'), isNotNull);
    cache.put('c', Uint8List.fromList(<int>[3]));

    expect(cache.contains('a'), isTrue);
    expect(cache.contains('b'), isFalse);
    expect(cache.contains('c'), isTrue);
  });

  test('byte budget evicts oldest entries and stays memory bounded', () {
    final cache = CacheManager(maxEntries: 10, maxBytes: 5);
    cache.put('a', Uint8List.fromList(<int>[1, 2, 3]));
    cache.put('b', Uint8List.fromList(<int>[4, 5, 6]));

    expect(cache.contains('a'), isFalse);
    expect(cache.contains('b'), isTrue);
    expect(cache.currentBytes, lessThanOrEqualTo(5));
  });

  test('single image larger than memory budget is not cached', () {
    final cache = CacheManager(maxEntries: 4, maxBytes: 2);
    cache.put('large', Uint8List.fromList(<int>[1, 2, 3]));

    expect(cache.length, 0);
    expect(cache.currentBytes, 0);
  });
}
