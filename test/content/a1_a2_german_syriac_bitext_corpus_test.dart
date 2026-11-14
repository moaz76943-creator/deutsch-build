import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/a1_a2_german_syriac_bitext_corpus.dart';

void main() {
  group('A1A2GermanSyriacBitextCorpus Unit Tests (L067)', () {
    test('Contains verified German-Syriac parallel entries with linguistic heritage notes', () {
      expect(A1A2GermanSyriacBitextCorpus.syriacEntries.length, equals(3));

      final peace = A1A2GermanSyriacBitextCorpus.syriacEntries.first;
      expect(peace.sentenceDe, contains('Friede sei mit diesem Hause'));
      expect(peace.sentenceSyc, contains('ܫܠܡܐ'));

      final wisdom = A1A2GermanSyriacBitextCorpus.syriacEntries.last;
      expect(wisdom.sentenceDe, contains('Wahre Weisheit'));
      expect(wisdom.sentenceSyc, contains('ܚܟܡܬܐ'));
    });
  });
}
