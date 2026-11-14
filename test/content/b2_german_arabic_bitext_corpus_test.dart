import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/b2_german_arabic_bitext_corpus.dart';

void main() {
  group('B2GermanArabicBitextCorpus Unit Tests (L064)', () {
    test('Contains advanced B2 ecological parallel bitext with passive voice and connectors', () {
      expect(B2GermanArabicBitextCorpus.b2Paragraphs.length, equals(3));

      final first = B2GermanArabicBitextCorpus.b2Paragraphs.first;
      expect(first.sentenceDe, contains('regenerative Energiequellen'));
      expect(first.grammarFocus, contains('Doppelkonjunktionen'));

      final third = B2GermanArabicBitextCorpus.b2Paragraphs.last;
      expect(third.sentenceDe, contains('gewährleistet werden kann'));
      expect(third.sentenceAr, contains('أمن الطاقة الموثوق'));
    });
  });
}
