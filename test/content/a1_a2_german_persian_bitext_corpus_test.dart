import 'package:test/test.dart';
import '../../lib/src/content/a1_a2_german_persian_bitext_corpus.dart';

void main() {
  group('A1A2GermanPersianBitextCorpus Unit Tests (L072)', () {
    test('Contains verified wholesome German-Persian parallel bitext entries', () {
      expect(A1A2GermanPersianBitextCorpus.persianEntries.length, equals(3));

      final first = A1A2GermanPersianBitextCorpus.persianEntries.first;
      expect(first.sentenceDe, contains('Guten Tag'));
      expect(first.sentenceFa, contains('روز بخیر'));

      final second = A1A2GermanPersianBitextCorpus.persianEntries[1];
      expect(second.sentenceDe, contains('Wissen und Bildung'));
      expect(second.sentenceFa, contains('دانش و آموزش'));
    });
  });
}
