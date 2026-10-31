import 'package:test/test.dart';
import '../../lib/src/content/a1_a2_german_turkish_bitext_corpus.dart';

void main() {
  group('A1A2GermanTurkishBitextCorpus Unit Tests (L068)', () {
    test('Contains wholesome German-Turkish community harmony parallel sentences', () {
      expect(A1A2GermanTurkishBitextCorpus.turkishEntries.length, equals(3));

      final neighbor = A1A2GermanTurkishBitextCorpus.turkishEntries.first;
      expect(neighbor.sentenceDe, contains('Guten Tag, Nachbar'));
      expect(neighbor.sentenceTr, contains('İyi günler komşum'));

      final punctuality = A1A2GermanTurkishBitextCorpus.turkishEntries.last;
      expect(punctuality.sentenceDe, contains('Pünktlichkeit und gegenseitige Hilfsbereitschaft'));
      expect(punctuality.sentenceTr, contains('Dakiklik ve karşılıklı yardımlaşma'));
    });
  });
}
