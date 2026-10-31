import 'package:test/test.dart';
import '../../lib/src/content/a2_german_arabic_bitext_corpus.dart';

void main() {
  group('A2GermanArabicBitextCorpus Unit Tests (L062)', () {
    test('Contains rich nature exploration A2 parallel bitext with weil subordinate clauses', () {
      expect(A2GermanArabicBitextCorpus.a2StoryParagraphs.length, equals(3));

      final second = A2GermanArabicBitextCorpus.a2StoryParagraphs[1];
      expect(second.sentenceDe, contains('weil die frische Bergluft'));
      expect(second.sentenceAr, contains('هواء الجبال النقي'));
      expect(second.grammarFocus, contains('Nebensätze mit "weil"'));
    });
  });
}
