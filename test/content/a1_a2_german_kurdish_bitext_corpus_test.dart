import 'package:test/test.dart';
import '../../lib/src/content/a1_a2_german_kurdish_bitext_corpus.dart';

void main() {
  group('A1A2GermanKurdishBitextCorpus Unit Tests (L073)', () {
    test('Contains verified wholesome German-Kurdish parallel bitext entries', () {
      expect(A1A2GermanKurdishBitextCorpus.kurdishEntries.length, equals(3));

      final first = A1A2GermanKurdishBitextCorpus.kurdishEntries.first;
      expect(first.sentenceDe, contains('Willkommen'));
      expect(first.sentenceCkb, contains('بەخێربێن'));

      final second = A1A2GermanKurdishBitextCorpus.kurdishEntries[1];
      expect(second.sentenceDe, contains('Bildung'));
      expect(second.sentenceCkb, contains('پەروەردە'));
    });
  });
}
