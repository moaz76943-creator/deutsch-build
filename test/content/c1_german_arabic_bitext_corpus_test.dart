import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/c1_german_arabic_bitext_corpus.dart';

void main() {
  group('C1GermanArabicBitextCorpus Unit Tests (L065)', () {
    test('Contains academic C1 parallel bitext on history of science and transmission', () {
      expect(C1GermanArabicBitextCorpus.c1Paragraphs.length, equals(3));

      final first = C1GermanArabicBitextCorpus.c1Paragraphs.first;
      expect(first.sentenceDe, contains('Ibn al-Haitham'));
      expect(first.sentenceAr, contains('ابن الهيثم'));
      expect(first.iPlusOneNovelWords, contains('bahnbrechend'));

      final third = C1GermanArabicBitextCorpus.c1Paragraphs.last;
      expect(third.sentenceDe, contains('tiefgreifende Bereicherung'));
      expect(third.grammarFocus, contains('Funktionsverbgefügen'));
    });
  });
}
