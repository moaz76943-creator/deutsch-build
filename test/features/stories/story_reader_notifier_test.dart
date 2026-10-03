import 'package:deutsch_bilarabi/features/stories/application/story_reader_notifier.dart';
import 'package:deutsch_bilarabi/features/stories/domain/story_models.dart';
import 'package:deutsch_bilarabi/features/stories/domain/story_repository.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeStoryRepository implements StoryRepository {
  final StoryItem story = StoryItem(
    id: 'story',
    titleArabic: 'قصة',
    titleGerman: 'Geschichte',
    level: StoryLevel.a1,
    coverKey: 'coffee',
    paragraphs: <StoryParagraph>[
      StoryParagraph(
        textGerman: 'Der Bahnhof ist ruhig.',
        translationArabic: 'المحطة هادئة.',
        interactiveWords: const <StoryInteractiveWord>[
          StoryInteractiveWord(
            id: 'station',
            surface: 'Bahnhof',
            meaningArabic: 'محطة القطار',
          ),
          StoryInteractiveWord(
            id: 'quiet',
            surface: 'ruhig',
            meaningArabic: 'هادئ',
          ),
        ],
      ),
    ],
    questions: <StoryComprehensionQuestion>[
      StoryComprehensionQuestion(
        id: 'q1',
        promptArabic: 'كيف حال المحطة؟',
        options: const <StoryQuestionOption>[
          StoryQuestionOption(id: 'quiet', textArabic: 'هادئة'),
          StoryQuestionOption(id: 'busy', textArabic: 'مزدحمة'),
        ],
        correctOptionId: 'quiet',
      ),
      StoryComprehensionQuestion(
        id: 'q2',
        promptArabic: 'ما المكان المذكور؟',
        options: const <StoryQuestionOption>[
          StoryQuestionOption(id: 'station', textArabic: 'المحطة'),
          StoryQuestionOption(id: 'school', textArabic: 'المدرسة'),
        ],
        correctOptionId: 'station',
      ),
    ],
  );

  @override
  Future<StoryItem?> getStory(String id) async => id == story.id ? story : null;

  @override
  Future<List<StoryItem>> listStories() async => <StoryItem>[story];
}

void main() {
  test('paragraph tokens preserve punctuation and expose interactive word', () {
    final paragraph = _FakeStoryRepository().story.paragraphs.single;
    final station = paragraph.tokens.firstWhere(
      (token) => token.interactiveWord?.id == 'station',
    );
    final quiet = paragraph.tokens.firstWhere(
      (token) => token.interactiveWord?.id == 'quiet',
    );

    expect(station.displayText, 'Bahnhof');
    expect(quiet.displayText, 'ruhig.');
    expect(quiet.interactiveWord?.meaningArabic, 'هادئ');
  });

  test('word tap reveals meaning and second tap hides it', () async {
    final notifier = StoryReaderNotifier(repository: _FakeStoryRepository());
    await notifier.loadStory('story');

    notifier.toggleWordMeaning('station');
    expect(notifier.state.revealedWord?.meaningArabic, 'محطة القطار');

    notifier.toggleWordMeaning('station');
    expect(notifier.state.revealedWord, isNull);
    notifier.dispose();
  });

  test('paragraph translation is controlled by application state', () async {
    final notifier = StoryReaderNotifier(repository: _FakeStoryRepository());
    await notifier.loadStory('story');

    expect(notifier.state.showParagraphTranslation, isFalse);
    notifier.toggleParagraphTranslation();
    expect(notifier.state.showParagraphTranslation, isTrue);
    notifier.dispose();
  });

  test('comprehension score reflects verified answers', () async {
    final notifier = StoryReaderNotifier(repository: _FakeStoryRepository());
    await notifier.loadStory('story');

    notifier.answerQuestion('q1', 'quiet');
    notifier.answerQuestion('q2', 'school');

    expect(notifier.comprehensionComplete, isTrue);
    expect(notifier.comprehensionScorePercent, 50);
    expect(notifier.state.answerCorrectness['q1'], isTrue);
    expect(notifier.state.answerCorrectness['q2'], isFalse);
    notifier.dispose();
  });
}
