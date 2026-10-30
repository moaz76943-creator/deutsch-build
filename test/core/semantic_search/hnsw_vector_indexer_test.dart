import 'package:test/test.dart';
import '../../lib/src/core/semantic_search/hnsw_vector_indexer.dart';

void main() {
  group('HnswVectorIndexer Unit Tests (N042)', () {
    final indexer = HnswVectorIndexer(maxConnectionsPerNode: 4);

    test('Inserts vectors and retrieves top-k nearest semantic neighbors', () {
      indexer.insert(id: 'v1', vector: [1.0, 0.0, 0.0], text: 'Guten Morgen');
      indexer.insert(id: 'v2', vector: [0.95, 0.05, 0.0], text: 'Guten Tag');
      indexer.insert(id: 'v3', vector: [0.0, 1.0, 0.0], text: 'Astronomie');

      expect(indexer.totalVectors, equals(3));

      final results = indexer.query(queryVector: [1.0, 0.0, 0.0], topK: 2);
      expect(results.length, equals(2));
      expect(results.first.id, equals('v1'));
      expect(results.first.similarity, closeTo(1.0, 0.001));
      expect(results[1].id, equals('v2'));
      expect(results[1].similarity, greaterThan(0.90));
    });

    test('Empty index query handles safely', () {
      final emptyIndexer = HnswVectorIndexer();
      final results = emptyIndexer.query(queryVector: [1.0, 2.0], topK: 5);
      expect(results, isEmpty);
    });
  });
}
