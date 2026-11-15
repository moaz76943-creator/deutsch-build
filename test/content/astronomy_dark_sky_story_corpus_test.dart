import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/astronomy_dark_sky_story_corpus.dart';

void main() {
  group('AstronomyDarkSkyStoryCorpus Unit Tests (L078)', () {
    test('Contains advanced B2/C1 astronomy and cosmic contemplation narrative with rich grammar', () {
      expect(AstronomyDarkSkyStoryCorpus.cosmicChapters.length, equals(3));

      final first = AstronomyDarkSkyStoryCorpus.cosmicChapters.first;
      expect(first.sentenceDe, contains('Spiegelteleskop'));
      expect(first.sentenceAr, contains('التلسكوب العاكس'));

      final third = AstronomyDarkSkyStoryCorpus.cosmicChapters.last;
      expect(third.sentenceDe, contains('tiefer Demut vor der erhabenen Ordnung'));
      expect(third.sentenceAr, contains('تواضعاً عميقاً وإجلالاً للنظام البديع'));
    });
  });
}
