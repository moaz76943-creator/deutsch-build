import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/dialogue/dialogue_story_archiver.dart';

void main() {
  group('DialogueStoryArchiver Tests', () {
    const archiver = DialogueStoryArchiver();

    test('Archives restaurant dialogue into structured learning story', () {
      final lines = [
        const StoryDialogueLine(
          speaker: 'Herr Schmidt',
          originalText: 'Guten Tag! Was darf es sein?',
          translation: 'Good day! What can I get for you?',
          durationSeconds: 3,
        ),
        const StoryDialogueLine(
          speaker: 'Learner',
          originalText: 'Ich möchte bitte einen Kaffee.',
          translation: 'I would like a coffee please.',
          durationSeconds: 3,
        ),
      ];

      final story = archiver.archiveSession(
        storyId: 'story_cafe_01',
        title: 'Ein Nachmittag im Café Lindenhof',
        scenarioCategory: 'Restaurant',
        cefrLevel: 'A2',
        lines: lines,
        vocabulary: ['der Kaffee', 'die Speisekarte'],
        grammarCorrections: ['Polite request: Ich möchte bitte...'],
      );

      expect(story.storyId, equals('story_cafe_01'));
      expect(story.script.length, equals(2));
      expect(story.keyVocabularyLearned.contains('der Kaffee'), isTrue);

      final md = story.toMarkdownStorySheet();
      expect(md, contains('# 📖 Hörgeschichte: Ein Nachmittag im Café Lindenhof'));
      expect(md, contains('**Herr Schmidt:** Guten Tag! Was darf es sein?'));
      expect(md, contains('Polite request: Ich möchte bitte...'));
    });
  });
}
