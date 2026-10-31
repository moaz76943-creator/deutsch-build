import 'package:test/test.dart';
import '../../lib/src/content/a1_a2_german_maltese_bitext_corpus.dart';

void main() {
  group('A1A2GermanMalteseBitextCorpus Unit Tests (L066)', () {
    test('Contains verified German-Maltese parallel sentences highlighting Semitic roots', () {
      expect(A1A2GermanMalteseBitextCorpus.bitextEntries.length, equals(3));

      final first = A1A2GermanMalteseBitextCorpus.bitextEntries.first;
      expect(first.sentenceDe, contains('Guten Morgen'));
      expect(first.sentenceMt, contains('L-għodwa t-tajba'));

      final water = A1A2GermanMalteseBitextCorpus.bitextEntries[1];
      expect(water.sentenceMt, contains('ilma frisk'));
      expect(water.semiticRootNote, contains('الماء'));
    });
  });
}
