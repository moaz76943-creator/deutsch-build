import '../domain/story_models.dart';
import '../domain/story_repository.dart';

final class LocalStoryRepository implements StoryRepository {
  const LocalStoryRepository();

  static final List<StoryItem> _stories = <StoryItem>[
    StoryItem(
      id: 'a1-morning-cafe',
      titleArabic: 'صباح في المقهى',
      titleGerman: 'Ein Morgen im Café',
      level: StoryLevel.a1,
      coverKey: 'coffee',
      paragraphs: <StoryParagraph>[
        StoryParagraph(
          textGerman:
              'Am Morgen ist das Café ruhig. Ein Gast bestellt Tee und ein Käsebrötchen.',
          translationArabic:
              'في الصباح يكون المقهى هادئًا. يطلب أحد الزبائن شايًا وخبزًا صغيرًا بالجبن.',
          interactiveWords: const <StoryInteractiveWord>[
            StoryInteractiveWord(
              id: 'morning',
              surface: 'Morgen',
              meaningArabic: 'الصباح',
            ),
            StoryInteractiveWord(
              id: 'quiet',
              surface: 'ruhig',
              meaningArabic: 'هادئ',
            ),
            StoryInteractiveWord(
              id: 'orders',
              surface: 'bestellt',
              meaningArabic: 'يطلب',
            ),
            StoryInteractiveWord(
              id: 'cheese-roll',
              surface: 'Käsebrötchen',
              meaningArabic: 'خبز صغير بالجبن',
            ),
          ],
        ),
        StoryParagraph(
          textGerman:
              'Der Tee ist heiß, aber das Brötchen schmeckt gut. Danach geht der Gast zur Arbeit.',
          translationArabic:
              'الشاي ساخن، لكن طعم الخبز جيد. بعد ذلك يذهب الزبون إلى العمل.',
          interactiveWords: const <StoryInteractiveWord>[
            StoryInteractiveWord(
              id: 'hot',
              surface: 'heiß',
              meaningArabic: 'ساخن',
            ),
            StoryInteractiveWord(
              id: 'tastes',
              surface: 'schmeckt',
              meaningArabic: 'طعمه يكون / مذاقه',
            ),
            StoryInteractiveWord(
              id: 'afterwards',
              surface: 'Danach',
              meaningArabic: 'بعد ذلك',
            ),
            StoryInteractiveWord(
              id: 'work',
              surface: 'Arbeit',
              meaningArabic: 'العمل',
            ),
          ],
        ),
      ],
      questions: <StoryComprehensionQuestion>[
        StoryComprehensionQuestion(
          id: 'cafe-q1',
          promptArabic: 'ماذا يطلب الزبون؟',
          options: const <StoryQuestionOption>[
            StoryQuestionOption(id: 'tea', textArabic: 'شاي وخبز بالجبن'),
            StoryQuestionOption(id: 'coffee', textArabic: 'قهوة فقط'),
            StoryQuestionOption(id: 'water', textArabic: 'ماء وفاكهة'),
          ],
          correctOptionId: 'tea',
        ),
        StoryComprehensionQuestion(
          id: 'cafe-q2',
          promptArabic: 'إلى أين يذهب الزبون بعد ذلك؟',
          options: const <StoryQuestionOption>[
            StoryQuestionOption(id: 'home', textArabic: 'إلى البيت'),
            StoryQuestionOption(id: 'work', textArabic: 'إلى العمل'),
            StoryQuestionOption(id: 'station', textArabic: 'إلى المحطة'),
          ],
          correctOptionId: 'work',
        ),
      ],
    ),
    StoryItem(
      id: 'a2-trip-irbid',
      titleArabic: 'رحلة إلى إربد',
      titleGerman: 'Eine Fahrt nach Irbid',
      level: StoryLevel.a2,
      coverKey: 'transport',
      paragraphs: <StoryParagraph>[
        StoryParagraph(
          textGerman:
              'Am Freitag plant eine Studentin eine Fahrt von Amman nach Irbid. Sie kauft ihr Ticket am Schalter, weil sie noch eine Frage hat.',
          translationArabic:
              'يوم الجمعة تخطط طالبة لرحلة من عمّان إلى إربد. تشتري تذكرتها من الشباك لأن لديها سؤالًا آخر.',
          interactiveWords: const <StoryInteractiveWord>[
            StoryInteractiveWord(
              id: 'plans',
              surface: 'plant',
              meaningArabic: 'تخطط',
            ),
            StoryInteractiveWord(
              id: 'trip',
              surface: 'Fahrt',
              meaningArabic: 'رحلة / تنقّل',
            ),
            StoryInteractiveWord(
              id: 'ticket',
              surface: 'Ticket',
              meaningArabic: 'تذكرة',
            ),
            StoryInteractiveWord(
              id: 'counter',
              surface: 'Schalter',
              meaningArabic: 'شباك الخدمة',
            ),
          ],
        ),
        StoryParagraph(
          textGerman:
              'Der Bus fährt um neun Uhr ab. Vor der Abfahrt prüft sie die Uhrzeit und wartet neben dem Eingang.',
          translationArabic:
              'تنطلق الحافلة الساعة التاسعة. قبل الانطلاق تتحقق من الوقت وتنتظر بجانب المدخل.',
          interactiveWords: const <StoryInteractiveWord>[
            StoryInteractiveWord(
              id: 'departs',
              surface: 'fährt',
              meaningArabic: 'ينطلق / يسير',
            ),
            StoryInteractiveWord(
              id: 'departure',
              surface: 'Abfahrt',
              meaningArabic: 'الانطلاق / المغادرة',
            ),
            StoryInteractiveWord(
              id: 'checks',
              surface: 'prüft',
              meaningArabic: 'تتحقق من',
            ),
            StoryInteractiveWord(
              id: 'entrance',
              surface: 'Eingang',
              meaningArabic: 'المدخل',
            ),
          ],
        ),
      ],
      questions: <StoryComprehensionQuestion>[
        StoryComprehensionQuestion(
          id: 'irbid-q1',
          promptArabic: 'لماذا تشتري الطالبة التذكرة من الشباك؟',
          options: const <StoryQuestionOption>[
            StoryQuestionOption(id: 'question', textArabic: 'لأن لديها سؤالًا'),
            StoryQuestionOption(id: 'late', textArabic: 'لأنها متأخرة'),
            StoryQuestionOption(id: 'lost', textArabic: 'لأنها أضاعت حقيبتها'),
          ],
          correctOptionId: 'question',
        ),
        StoryComprehensionQuestion(
          id: 'irbid-q2',
          promptArabic: 'متى تنطلق الحافلة؟',
          options: const <StoryQuestionOption>[
            StoryQuestionOption(id: 'eight', textArabic: 'الساعة الثامنة'),
            StoryQuestionOption(id: 'nine', textArabic: 'الساعة التاسعة'),
            StoryQuestionOption(id: 'ten', textArabic: 'الساعة العاشرة'),
          ],
          correctOptionId: 'nine',
        ),
      ],
    ),
  ];

  @override
  Future<List<StoryItem>> listStories() async =>
      List<StoryItem>.unmodifiable(_stories);

  @override
  Future<StoryItem?> getStory(String id) async {
    final normalized = id.trim();
    for (final story in _stories) {
      if (story.id == normalized) return story;
    }
    return null;
  }
}
