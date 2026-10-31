import 'package:test/test.dart';
import '../../lib/src/content/ethical_entrepreneurship_story_corpus.dart';

void main() {
  group('EthicalEntrepreneurshipStoryCorpus Unit Tests (L069)', () {
    test('Contains inspiring B1/B2 ethical entrepreneurship narrative with advanced grammar', () {
      expect(EthicalEntrepreneurshipStoryCorpus.chapters.length, equals(3));

      final first = EthicalEntrepreneurshipStoryCorpus.chapters.first;
      expect(first.sentenceDe, contains('ohne zinsbelastete Kredite'));
      expect(first.sentenceAr, contains('دون الوقوع في شباك القروض'));

      final second = EthicalEntrepreneurshipStoryCorpus.chapters[1];
      expect(second.sentenceDe, contains('Anstatt auf spekulative Investoren zu warten'));
      expect(second.grammarFocus, contains('Anstatt... zu'));
    });
  });
}
