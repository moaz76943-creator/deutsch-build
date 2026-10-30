import 'package:test/test.dart';
import '../../lib/src/core/semantic_search/cross_lingual_embeddings.dart';

void main() {
  group('CrossLingualEmbeddingsEngine Unit Tests (N041)', () {
    const engine = CrossLingualEmbeddingsEngine(embeddingDimension: 32);

    test('Generates normalized vectors with non-zero magnitude', () {
      final vec = engine.encode('Guten Morgen!');
      expect(vec.dimension, equals(32));

      double norm = 0.0;
      for (final v in vec.values) {
        norm += v * v;
      }
      expect(norm, closeTo(1.0, 0.001));
    });

    test('Identical sentences yield cosine similarity of 1.0', () {
      final v1 = engine.encode('Wie geht es Ihnen?');
      final v2 = engine.encode('Wie geht es Ihnen?');
      expect(v1.cosineSimilarity(v2), closeTo(1.0, 0.0001));
    });

    test('Semantically similar sentences score higher than completely unrelated text', () {
      final base = engine.encode('Guten Tag mein Freund');
      final similar = engine.encode('Guten Tag mein lieber Freund');
      final unrelated = engine.encode('Quantenmechanik in der Astrophysik');

      final simScore = base.cosineSimilarity(similar);
      final un соцScore = base.cosineSimilarity(unrelated);

      expect(simScore, greaterThan(un соцScore));
    });

    test('Empty sentence yields zero vector with zero similarity', () {
      final emptyVec = engine.encode('');
      final otherVec = engine.encode('Hallo');
      expect(emptyVec.cosineSimilarity(otherVec), equals(0.0));
    });
  });
}
