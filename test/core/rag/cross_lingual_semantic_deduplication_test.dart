import 'package:test/test.dart';
import 'package:deutsch_build/src/core/rag/cross_lingual_semantic_deduplication.dart';

void main() {
  group('CrossLingualSemanticDeduplicator Suite', () {
    const deduplicator = CrossLingualSemanticDeduplicator(
      maxAllowedSimilarity: 0.92,
      mmrLambda: 0.7,
    );

    test('Prunes redundant passage discussing identical grammar rule in another language', () {
      final vGrammar = [0.9, 0.4, 0.0, 0.0];
      final vGrammarDup = [0.89, 0.41, 0.0, 0.0]; // Cosine sim > 0.99
      final vVocabulary = [0.0, 0.1, 0.9, 0.4];

      final candArabic = DeduplicationCandidate(
        id: 'ar_rule_1',
        text: 'الفاعل مرفوع وعلامة رفعه الضمة الظاهرة',
        languageCode: 'ar',
        vector: vGrammar,
        relevanceScore: 0.95,
      );

      final candTurkishDup = DeduplicationCandidate(
        id: 'tr_rule_1_dup',
        text: 'Özne her zaman yalın veya merfu halde bulunur',
        languageCode: 'tr',
        vector: vGrammarDup,
        relevanceScore: 0.93,
      );

      final candVocab = DeduplicationCandidate(
        id: 'vocab_2',
        text: 'قائمة بالمفردات اللغوية الشائعة',
        languageCode: 'ar',
        vector: vVocabulary,
        relevanceScore: 0.85,
      );

      final result = deduplicator.deduplicate(
        candidates: [candArabic, candTurkishDup, candVocab],
        topK: 5,
      );

      expect(result.retainedItems.length, equals(2));
      expect(result.retainedItems.map((c) => c.id), contains('ar_rule_1'));
      expect(result.retainedItems.map((c) => c.id), contains('vocab_2'));
      expect(result.prunedItems.length, equals(1));
      expect(result.prunedItems.first.item.id, equals('tr_rule_1_dup'));
      expect(result.prunedItems.first.duplicateOfId, equals('ar_rule_1'));
    });
  });
}
