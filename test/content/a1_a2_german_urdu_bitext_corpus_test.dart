import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/a1_a2_german_urdu_bitext_corpus.dart';

void main() {
  group('A1A2GermanUrduBitextCorpus Unit Tests (L074)', () {
    test('Contains verified wholesome German-Urdu parallel bitext entries', () {
      expect(A1A2GermanUrduBitextCorpus.urduEntries.length, equals(3));

      final first = A1A2GermanUrduBitextCorpus.urduEntries.first;
      expect(first.sentenceDe, contains('Friede und Segen'));
      expect(first.sentenceUr, contains('السلام علیکم'));

      final second = A1A2GermanUrduBitextCorpus.urduEntries[1];
      expect(second.sentenceDe, contains('Ehrliche Arbeit'));
      expect(second.sentenceUr, contains('ایماندارانہ محنت'));
    });
  });
}
