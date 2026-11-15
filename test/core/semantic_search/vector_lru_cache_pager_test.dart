import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/semantic_search/vector_lru_cache_pager.dart';

void main() {
  group('VectorLruCachePager Unit Tests (N053)', () {
    test('Maintains capacity limit and evicts oldest unaccessed page', () {
      final pager = VectorLruCachePager(maxLoadedPages: 2);

      VectorPage mockLoader(int id) => VectorPage(pageId: id, vectorData: {'vec_$id': [1, 2, 3]});

      pager.accessPage(1, onDiskLoader: mockLoader);
      pager.accessPage(2, onDiskLoader: mockLoader);
      expect(pager.loadedPageCount, equals(2));

      // Access 3 -> page 1 should be evicted
      pager.accessPage(3, onDiskLoader: mockLoader);
      expect(pager.loadedPageCount, equals(2));
      expect(pager.evictionCount, equals(1));
      expect(pager.cacheMisses, equals(3));

      // Re-access page 2 -> should be a hit (no eviction)
      pager.accessPage(2, onDiskLoader: mockLoader);
      expect(pager.cacheHits, equals(1));
      expect(pager.evictionCount, equals(1));
    });

    test('Hit ratio calculation behaves correctly', () {
      final pager = VectorLruCachePager(maxLoadedPages: 3);
      VectorPage loader(int id) => VectorPage(pageId: id, vectorData: {});

      pager.accessPage(1, onDiskLoader: loader); // Miss
      pager.accessPage(1, onDiskLoader: loader); // Hit
      pager.accessPage(1, onDiskLoader: loader); // Hit

      expect(pager.hitRatio, closeTo(0.666, 0.01));
    });
  });
}
