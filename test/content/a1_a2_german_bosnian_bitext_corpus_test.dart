import 'package:test/test.dart';
import '../../lib/src/content/a1_a2_german_bosnian_bitext_corpus.dart';

void main() {
  group('A1A2GermanBosnianBitextCorpus Unit Tests (L076)', () {
    test('Contains verified wholesome German-Bosnian parallel bitext entries', () {
      expect(A1A2GermanBosnianBitextCorpus.bosnianEntries.length, equals(3));

      final first = A1A2GermanBosnianBitextCorpus.bosnianEntries.first;
      expect(first.sentenceDe, contains('Guten Tag'));
      expect(first.sentenceBs, contains('Dobar dan'));

      final second = A1A2GermanBosnianBitextCorpus.bosnianEntries[1];
      expect(second.sentenceDe, contains('Wissen und Fleiß'));
      expect(second.sentenceBs, contains('Znanje i marljivost'));
    });
  });
}
