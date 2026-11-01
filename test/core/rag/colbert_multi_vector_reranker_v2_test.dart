import 'package:test/test.dart';
import 'package:deutsch_build/src/core/rag/colbert_multi_vector_reranker_v2.dart';

void main() {
  group('ColbertMultiVectorRerankerV2 Suite', () {
    const dimension = 32;
    final reranker = ColbertMultiVectorRerankerV2(vectorDimension: dimension);

    test('Late interaction MaxSim correctly ranks exact match above random noise', () {
      final qToken1 = ColbertMultiVectorRerankerV2.createSyntheticEmbedding('knowledge', dimension, 42);
      final qToken2 = ColbertMultiVectorRerankerV2.createSyntheticEmbedding('wisdom', dimension, 84);
      final query = [qToken1, qToken2];

      // Relevant document contains identical token embeddings
      final relevantDoc = ColbertDocumentRecord(
        id: 'doc-rel',
        text: 'seeking knowledge and wisdom',
        languageCode: 'en',
        tokenEmbeddings: [
          ColbertMultiVectorRerankerV2.createSyntheticEmbedding('seeking', dimension, 11),
          qToken1, // exact match
          qToken2, // exact match
        ],
      );

      // Irrelevant document has distinct orthogonal/random tokens
      final irrelevantDoc = ColbertDocumentRecord(
        id: 'doc-irrel',
        text: 'clouds over high mountains',
        languageCode: 'en',
        tokenEmbeddings: [
          ColbertMultiVectorRerankerV2.createSyntheticEmbedding('clouds', dimension, 999),
          ColbertMultiVectorRerankerV2.createSyntheticEmbedding('mountains', dimension, 1000),
        ],
      );

      final results = reranker.rerank(
        queryTokens: query,
        candidateDocuments: [irrelevantDoc, relevantDoc],
        topK: 2,
      );

      expect(results.length, equals(2));
      expect(results.first.document.id, equals('doc-rel'));
      // Perfect match for 2 unit vectors should yield MaxSim near 2.0
      expect(results.first.score, closeTo(2.0, 1e-4));
      expect(results.first.tokenAlignments.first.bestMatchedDocToken, equals('knowledge'));
      expect(results.first.tokenAlignments.last.bestMatchedDocToken, equals('wisdom'));
    });

    test('Empty candidate list or empty query returns empty list safely', () {
      final qToken = ColbertMultiVectorRerankerV2.createSyntheticEmbedding('peace', dimension, 7);
      expect(reranker.rerank(queryTokens: [], candidateDocuments: []), isEmpty);
      expect(reranker.rerank(queryTokens: [qToken], candidateDocuments: []), isEmpty);
    });

    test('ColbertTokenEmbedding normalization preserves unit length', () {
      final raw = [3.0, 4.0];
      final emb = ColbertTokenEmbedding(token: 'test', rawVector: raw);
      expect(emb.norm, closeTo(5.0, 1e-6));
      expect(emb.vector[0], closeTo(0.6, 1e-6));
      expect(emb.vector[1], closeTo(0.8, 1e-6));
    });
  });
}
