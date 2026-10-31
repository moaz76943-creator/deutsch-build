import 'package:test/test.dart';
import '../../lib/src/content/a1_german_arabic_bitext_corpus.dart';

void main() {
  group('A1GermanArabicBitextCorpus Unit Tests (L061)', () {
    test('Contains aligned A1 bilingual story with i+1 grammar and lexical scaffolds', () {
      expect(A1GermanArabicBitextCorpus.storyParagraphs.length, equals(4));

      final first = A1GermanArabicBitextCorpus.storyParagraphs.first;
      expect(first.sentenceDe, contains('frühstücken'));
      expect(first.sentenceAr, contains('يتناول وجبة الإفطار'));
      expect(first.iPlusOneNovelWords, contains('aufstehen'));
      expect(first.grammarFocus, contains('Trennbare Verben'));
    });
  });
}
