import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/c1_urban_architecture_bitext_corpus.dart';

void main() {
  group('C1UrbanArchitectureBitextCorpus Unit Tests (L071)', () {
    test('Contains advanced academic C1 parallel bitext on bioclimatic urban architecture', () {
      expect(C1UrbanArchitectureBitextCorpus.architectureParagraphs.length, equals(3));

      final first = C1UrbanArchitectureBitextCorpus.architectureParagraphs.first;
      expect(first.sentenceDe, contains('bioklimatischer Prinzipien'));
      expect(first.sentenceAr, contains('التصميم المناخي الحيوي'));

      final second = C1UrbanArchitectureBitextCorpus.architectureParagraphs[1];
      expect(second.sentenceDe, contains('schattenspendende Innenhöfe'));
      expect(second.grammarFocus, contains('Modalsatz mit "indem"'));
    });
  });
}
