import 'package:test/test.dart';
import 'package:deutsch_build/src/core/rag/polyglot_subword_inverted_index.dart';

void main() {
  group('PolyglotSubwordInvertedIndex Suite', () {
    final index = PolyglotSubwordInvertedIndex();

    setUpAll(() {
      // Turkish agglutinative inflection: "ev" (house), "evlerinizden" (from your houses)
      index.addDocument('doc_tr_01', 'Güzel evlerinizden çıktınız mı?');
      // Arabic derived morphology: "كتاب", "كاتب", "مكتبة"
      index.addDocument('doc_ar_01', 'الكاتب يجلس في المكتبة العامة');
      // Indonesian prefixation: "membaca" (reading), "buku" (book)
      index.addDocument('doc_id_01', 'Siswa itu sedang membaca buku di perpustakaan');
    });

    test('Finds Turkish agglutinative stem match across inflectional suffixes', () {
      final results = index.search('evler');
      expect(results, isNotEmpty);
      expect(results.first.docId, equals('doc_tr_01'));
      expect(results.first.matchedNgramsCount, greaterThan(0));
    });

    test('Finds Arabic triconsonantal root family through sub-word overlap', () {
      final results = index.search('مكتب');
      expect(results, isNotEmpty);
      expect(results.first.docId, equals('doc_ar_01'));
    });
  });
}
