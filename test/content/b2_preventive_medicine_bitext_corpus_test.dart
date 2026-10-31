import 'package:test/test.dart';
import '../../lib/src/content/b2_preventive_medicine_bitext_corpus.dart';

void main() {
  group('B2PreventiveMedicineBitextCorpus Unit Tests (L070)', () {
    test('Contains advanced B2 preventive healthcare parallel bitext with medical grammar scaffolding', () {
      expect(B2PreventiveMedicineBitextCorpus.medicalParagraphs.length, equals(3));

      final first = B2PreventiveMedicineBitextCorpus.medicalParagraphs.first;
      expect(first.sentenceDe, contains('Präventivmedizin'));
      expect(first.sentenceAr, contains('الطب الوقائي'));
      expect(first.iPlusOneNovelWords, contains('vorbeugen'));

      final second = B2PreventiveMedicineBitextCorpus.medicalParagraphs[1];
      expect(second.sentenceDe, contains('ausgewogene Ernährung'));
      expect(second.grammarFocus, contains('Relativsatz'));
    });
  });
}
