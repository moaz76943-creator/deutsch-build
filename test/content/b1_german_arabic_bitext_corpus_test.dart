import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/b1_german_arabic_bitext_corpus.dart';

void main() {
  group('B1GermanArabicBitextCorpus Unit Tests (L063)', () {
    test('Contains inspiring B1 community service narrative with relative clauses and participle adjectives', () {
      expect(B1GermanArabicBitextCorpus.b1StoryParagraphs.length, equals(3));

      final first = B1GermanArabicBitextCorpus.b1StoryParagraphs.first;
      expect(first.sentenceDe, contains('ehrenamtliche Initiative'));
      expect(first.sentenceAr, contains('مبادرة تطوعية'));

      final third = B1GermanArabicBitextCorpus.b1StoryParagraphs.last;
      expect(third.sentenceDe, contains('von dem beide Generationen'));
      expect(third.grammarFocus, contains('Relativsätze mit Präpositionen'));
    });
  });
}
