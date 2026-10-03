enum StoryLevel {
  a1('A1'),
  a2('A2');

  const StoryLevel(this.label);
  final String label;
}

final class StoryInteractiveWord {
  const StoryInteractiveWord({
    required this.id,
    required this.surface,
    required this.meaningArabic,
  });

  final String id;
  final String surface;
  final String meaningArabic;
}

final class StoryWordToken {
  const StoryWordToken({
    required this.displayText,
    this.interactiveWord,
  });

  final String displayText;
  final StoryInteractiveWord? interactiveWord;
  bool get isInteractive => interactiveWord != null;
}

final class StoryParagraph {
  StoryParagraph({
    required this.textGerman,
    required this.translationArabic,
    required List<StoryInteractiveWord> interactiveWords,
  }) : interactiveWords = List<StoryInteractiveWord>.unmodifiable(
          interactiveWords,
        ) {
    if (textGerman.trim().isEmpty || translationArabic.trim().isEmpty) {
      throw ArgumentError('Story paragraph text and translation are required.');
    }
  }

  final String textGerman;
  final String translationArabic;
  final List<StoryInteractiveWord> interactiveWords;

  List<StoryWordToken> get tokens {
    final lookup = <String, StoryInteractiveWord>{
      for (final word in interactiveWords) _normalize(word.surface): word,
    };
    return textGerman
        .trim()
        .split(RegExp(r'\s+'))
        .map(
          (part) => StoryWordToken(
            displayText: part,
            interactiveWord: lookup[_normalize(part)],
          ),
        )
        .toList(growable: false);
  }

  StoryInteractiveWord? wordById(String id) {
    for (final word in interactiveWords) {
      if (word.id == id) return word;
    }
    return null;
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[.,!?;:"„“‚‘()\[\]{}]'), '');
}

final class StoryQuestionOption {
  const StoryQuestionOption({
    required this.id,
    required this.textArabic,
  });

  final String id;
  final String textArabic;
}

final class StoryComprehensionQuestion {
  StoryComprehensionQuestion({
    required this.id,
    required this.promptArabic,
    required List<StoryQuestionOption> options,
    required this.correctOptionId,
  }) : options = List<StoryQuestionOption>.unmodifiable(options) {
    if (id.trim().isEmpty ||
        promptArabic.trim().isEmpty ||
        options.length < 2 ||
        !options.any((option) => option.id == correctOptionId)) {
      throw ArgumentError('Invalid comprehension question.');
    }
  }

  final String id;
  final String promptArabic;
  final List<StoryQuestionOption> options;
  final String correctOptionId;

  bool isCorrect(String optionId) => optionId == correctOptionId;
}

final class StoryItem {
  StoryItem({
    required this.id,
    required this.titleArabic,
    required this.titleGerman,
    required this.level,
    required this.coverKey,
    required List<StoryParagraph> paragraphs,
    required List<StoryComprehensionQuestion> questions,
  })  : paragraphs = List<StoryParagraph>.unmodifiable(paragraphs),
        questions = List<StoryComprehensionQuestion>.unmodifiable(questions) {
    if (id.trim().isEmpty ||
        titleArabic.trim().isEmpty ||
        titleGerman.trim().isEmpty ||
        paragraphs.isEmpty ||
        questions.isEmpty) {
      throw ArgumentError('Story identity, paragraphs and questions are required.');
    }
  }

  final String id;
  final String titleArabic;
  final String titleGerman;
  final StoryLevel level;
  final String coverKey;
  final List<StoryParagraph> paragraphs;
  final List<StoryComprehensionQuestion> questions;
}
