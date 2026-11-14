import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/rag/hybrid_bm25_vector_fusion_engine.dart';

void main() {
  group('HybridBm25VectorFusionEngine Suite', () {
    test('BM25 correctly ranks exact keyword occurrences', () {
      final index = Bm25Index();

      index.addDocument(Bm25Document(
        id: 'doc1',
        text: 'الصبر مفتاح الفرج والعمل الصالح',
        tokens: ['الصبر', 'مفتاح', 'الفرج', 'والعمل', 'الصالح'],
      ));

      index.addDocument(Bm25Document(
        id: 'doc2',
        text: 'العلم نور يهدي إلى طريق الخير',
        tokens: ['العلم', 'نور', 'يهدي', 'إلى', 'طريق', 'الخير'],
      ));

      final hits = index.search(['الصبر', 'الفرج']);
      expect(hits, isNotEmpty);
      expect(hits.first.docId, equals('doc1'));
      expect(hits.first.rank, equals(1));
    });

    test('RRF fusion prioritizes items with agreement across lexical and vector modalities', () {
      const engine = HybridBm25VectorFusionEngine(rrfK: 60);

      // Item A ranks #1 in vector, #1 in lexical
      // Item B ranks #2 in lexical, not present in vector top-K
      // Item C ranks #2 in vector, not present in lexical top-K
      final lexicalHits = [
        const LexicalHit(docId: 'itemA', score: 12.5, rank: 1),
        const LexicalHit(docId: 'itemB', score: 9.1, rank: 2),
      ];

      final vectorHits = [
        const VectorHit(docId: 'itemA', score: 0.95, rank: 1),
        const VectorHit(docId: 'itemC', score: 0.88, rank: 2),
      ];

      final fused = engine.fuse(
        lexicalHits: lexicalHits,
        vectorHits: vectorHits,
        topK: 3,
      );

      expect(fused.length, equals(3));
      expect(fused.first.docId, equals('itemA'));
      // itemA score = 1/(60+1) + 1/(60+1) = 2/61 ≈ 0.03278
      expect(fused.first.rrfScore, closeTo(2.0 / 61.0, 1e-5));
      expect(fused.first.lexicalRank, equals(1));
      expect(fused.first.vectorRank, equals(1));
    });
  });
}
