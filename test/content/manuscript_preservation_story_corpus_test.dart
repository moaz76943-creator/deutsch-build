import 'package:test/test.dart';
import '../../lib/src/content/manuscript_preservation_story_corpus.dart';

void main() {
  group('ManuscriptPreservationStoryCorpus Unit Tests (L079)', () {
    test('Contains advanced C1/C2 cultural heritage preservation narrative with rich academic syntax', () {
      expect(ManuscriptPreservationStoryCorpus.restorationChapters.length, equals(3));

      final first = ManuscriptPreservationStoryCorpus.restorationChapters.first;
      expect(first.sentenceDe, contains('Pergamentkodizes'));
      expect(first.sentenceAr, contains('مخطوطات رقّية'));

      final second = ManuscriptPreservationStoryCorpus.restorationChapters[1];
      expect(second.grammarFocus, contains('mittels'));
    });
  });
}
