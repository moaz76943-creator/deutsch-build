import 'package:test/test.dart';
import '../../lib/src/content/a1_a2_german_albanian_bitext_corpus.dart';

void main() {
  group('A1A2GermanAlbanianBitextCorpus Unit Tests (L077)', () {
    test('Contains verified wholesome German-Albanian parallel bitext entries', () {
      expect(A1A2GermanAlbanianBitextCorpus.albanianEntries.length, equals(3));

      final first = A1A2GermanAlbanianBitextCorpus.albanianEntries.first;
      expect(first.sentenceDe, contains('Guten Tag'));
      expect(first.sentenceSq, contains('Mirëdita'));

      final family = A1A2GermanAlbanianBitextCorpus.albanianEntries.last;
      expect(family.sentenceDe, contains('Gesundheit der Familie'));
      expect(family.sentenceSq, contains('Shëndeti i familjes'));
    });
  });
}
