import 'package:test/test.dart';
import '../../lib/src/content/civilizational_dialogue_story_corpus.dart';

void main() {
  group('CivilizationalDialogueStoryCorpus Unit Tests (L075)', () {
    test('Contains advanced B2/C1 academic civilizational dialogue narrative with rich grammar', () {
      expect(CivilizationalDialogueStoryCorpus.scholarlyChapters.length, equals(3));

      final first = CivilizationalDialogueStoryCorpus.scholarlyChapters.first;
      expect(first.sentenceDe, contains('Wissenschaftskongress in Heidelberg'));
      expect(first.sentenceAr, contains('هايدلبرغ'));

      final third = CivilizationalDialogueStoryCorpus.scholarlyChapters.last;
      expect(third.sentenceDe, contains('universales Erbe der Menschheit'));
      expect(third.sentenceAr, contains('إرثاً إنسانياً مشتركاً'));
    });
  });
}
