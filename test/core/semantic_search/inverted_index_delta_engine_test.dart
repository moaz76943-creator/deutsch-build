import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/semantic_search/inverted_index_delta_engine.dart';

void main() {
  group('InvertedIndexDeltaEngine Unit Tests (N050)', () {
    final engine = InvertedIndexDeltaEngine();

    test('Indexes documents and updates vocabulary size incrementally', () {
      engine.indexDocument(docId: 'doc1', content: 'Der Hund bellt laut im Garten.');
      engine.indexDocument(docId: 'doc2', content: 'Die Katze schläft friedlich auf dem Sofa.');

      expect(engine.totalDocuments, equals(2));
      expect(engine.vocabularySize, greaterThan(8));
    });

    test('Retrieves relevant documents with non-zero BM25 score', () {
      engine.indexDocument(docId: 'doc1', content: 'Brot und Wasser sind Grundnahrungsmittel.');
      engine.indexDocument(docId: 'doc2', content: 'Autos fahren schnell auf der Autobahn.');

      final results = engine.search('Wasser Brot');
      expect(results.containsKey('doc1'), isTrue);
      expect(results.containsKey('doc2'), isFalse);
      expect(results['doc1']!, greaterThan(0.0));
    });

    test('Empty query returns empty results', () {
      expect(engine.search(''), isEmpty);
    });
  });
}
