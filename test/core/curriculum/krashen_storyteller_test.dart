import 'package:test/test.dart';
import '../../lib/src/core/curriculum/krashen_storyteller.dart';

void main() {
  group('KrashenStoryteller Unit Tests (N039)', () {
    final storyteller = KrashenStoryteller();

    test('Weaves episodic chapter with controlled i+1 target word injection', () {
      final chapter = storyteller.weaveChapter(
        chapterId: 'chap_01',
        title: 'Das Geheimnis im Garten',
        knownPlotTokens: ['Der', 'Hund', 'lief', 'schnell', 'durch', 'das', 'grüne', 'Gras.'],
        targetNovelTokens: ['einen geheimnisvollen Schlüssel', 'ein altes Tagebuch'],
        grammarFocus: 'Akkusativ_Direct_Object',
      );

      expect(chapter.chapterId, equals('chap_01'));
      expect(chapter.injectedTargetWords.length, equals(2));
      expect(chapter.textContent, contains('einen geheimnisvollen Schlüssel'));
      expect(chapter.comprehensionQuestions.length, equals(2));

      final cohesion = storyteller.evaluateStoryCohesion(chapter);
      expect(cohesion, greaterThanOrEqualTo(75.0));
    });

    test('Empty text handles safely', () {
      const empty = MicroNarrativeChapter(
        chapterId: 'e',
        title: 'e',
        textContent: '',
        injectedTargetWords: [],
        targetGrammarFeature: 'none',
        comprehensionQuestions: [],
      );
      expect(storyteller.evaluateStoryCohesion(empty), equals(0.0));
    });
  });
}
