enum WidgetLayoutSize {
  compact2x2,
  standard4x2,
  expanded4x4,
}

class GlanceQuizOption {
  final String text;
  final bool isCorrect;

  const GlanceQuizOption({
    required this.text,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isCorrect': isCorrect,
  };
}

class GlanceWidgetPayload {
  final String headlineWord;
  final String partOfSpeech;
  final String phoneticIpa;
  final String translation;
  final String exampleSentence;
  final int streakDays;
  final List<GlanceQuizOption> quizOptions;

  const GlanceWidgetPayload({
    required this.headlineWord,
    required this.partOfSpeech,
    required this.phoneticIpa,
    required this.translation,
    required this.exampleSentence,
    required this.streakDays,
    required this.quizOptions,
  });

  Map<String, dynamic> toJson() => {
    'headlineWord': headlineWord,
    'partOfSpeech': partOfSpeech,
    'phoneticIpa': phoneticIpa,
    'translation': translation,
    'exampleSentence': exampleSentence,
    'streakDays': streakDays,
    'quizOptions': quizOptions.map((o) => o.toJson()).toList(),
  };
}

class AndroidGlanceWidgetEngine {
  const AndroidGlanceWidgetEngine();

  /// Renders RemoteViews XML-compatible widget state string based on screen grid size.
  String renderWidgetMarkup(GlanceWidgetPayload payload, WidgetLayoutSize size) {
    final buffer = StringBuffer();
    buffer.writeln('<!-- Polyglot Sovereign Android Glance Widget: ${size.name} -->');
    buffer.writeln('<WidgetRoot layout="${size.name}" streak="${payload.streakDays}🔥">');
    buffer.writeln('  <Header title="Wort des Tages" streak="${payload.streakDays}" />');
    buffer.writeln('  <WordSection word="${payload.headlineWord}" pos="${payload.partOfSpeech}" ipa="/${payload.phoneticIpa}/" />');

    if (size != WidgetLayoutSize.compact2x2) {
      buffer.writeln('  <Translation text="${payload.translation}" />');
      buffer.writeln('  <Example sentence="${payload.exampleSentence}" />');
    }

    if (size == WidgetLayoutSize.expanded4x4 && payload.quizOptions.isNotEmpty) {
      buffer.writeln('  <InteractiveQuiz title="Schnelltest">');
      for (int i = 0; i < payload.quizOptions.length; i++) {
        final opt = payload.quizOptions[i];
        buffer.writeln('    <QuizButton index="$i" label="${opt.text}" />');
      }
      buffer.writeln('  </InteractiveQuiz>');
    }

    buffer.writeln('</WidgetRoot>');
    return buffer.toString();
  }

  /// Evaluates an in-widget button tap event without launching the main application activity.
  bool evaluateInWidgetQuizTap(GlanceWidgetPayload payload, int selectedOptionIndex) {
    if (selectedOptionIndex < 0 || selectedOptionIndex >= payload.quizOptions.length) {
      return false;
    }
    return payload.quizOptions[selectedOptionIndex].isCorrect;
  }
}
