import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/semantic_search/hybrid_search_reranker.dart';

void main() {
  group('HybridSearchReRanker Unit Tests (N043)', () {
    const reranker = HybridSearchReRanker();

    test('BM25 scoring boosts exact keyword occurrences', () {
      final scoreHigh = reranker.calculateBm25(query: 'Wasser trinken', document: 'Ich will frisches Wasser trinken.');
      final scoreLow = reranker.calculateBm25(query: 'Wasser trinken', document: 'Das Auto fährt schnell.');

      expect(scoreHigh, greaterThan(scoreLow));
      expect(scoreLow, equals(0.0));
    });

    test('RRF fusion elevates documents scoring well across both lexical and dense modalities', () {
      final docs = [
        const MapEntry('doc1', 'Ein schneller Hund rennt.'),
        const MapEntry('doc2', 'Katzen schlafen gerne.'),
      ];
      final denseScores = {
        'doc1': 0.88,
        'doc2': 0.12,
      };

      final results = reranker.reRank(
        query: 'Hund rennt',
        documents: docs,
        denseVectorScores: denseScores,
      );

      expect(results.first.id, equals('doc1'));
      expect(results.first.fusedRankScore, greaterThan(results.last.fusedRankScore));
    });
  });
}
