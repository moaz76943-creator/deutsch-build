/// An episodic comprehensible story chapter designed for subconscious acquisition.
class MicroNarrativeChapter {
  final String chapterId;
  final String title;
  final String textContent;
  final List<String> injectedTargetWords;
  final String targetGrammarFeature;
  final List<String> comprehensionQuestions;

  const MicroNarrativeChapter({
    required this.chapterId,
    required this.title,
    required this.textContent,
    required this.injectedTargetWords,
    required this.targetGrammarFeature,
    required this.comprehensionQuestions,
  });
}

/// Weaves target vocabulary and grammar structures into high-interest, low-stress episodic stories.
class KrashenStoryteller {
  /// Assembles a story chapter with controlled target lexical density.
  MicroNarrativeChapter weaveChapter({
    required String chapterId,
    required String title,
    required List<String> knownPlotTokens,
    required List<String> targetNovelTokens,
    required String grammarFocus,
  }) {
    final storyBuffer = StringBuffer();
    storyBuffer.writeln('Es war ein sonniger Morgen in Berlin. ');
    storyBuffer.writeln(knownPlotTokens.join(' '));
    storyBuffer.write(' Plötzlich passierte etwas Unerwartetes: ');

    for (int i = 0; i < targetNovelTokens.length; i++) {
      storyBuffer.write('Die Hauptfigur entdeckte ${targetNovelTokens[i]} im alten Garten. ');
    }
    storyBuffer.write('Alles wurde verständlich und ruhig.');

    return MicroNarrativeChapter(
      chapterId: chapterId,
      title: title,
      textContent: storyBuffer.toString(),
      injectedTargetWords: targetNovelTokens,
      targetGrammarFeature: grammarFocus,
      comprehensionQuestions: [
        'Was geschah am sonnigen Morgen?',
        'Was wurde im alten Garten entdeckt?',
      ],
    );
  }

  /// Calculates the narrative immersion index.
  double evaluateStoryCohesion(MicroNarrativeChapter chapter) {
    if (chapter.textContent.isEmpty) return 0.0;
    final wordCount = chapter.textContent.split(RegExp(r'\s+')).length;
    final targetDensity = (chapter.injectedTargetWords.length / wordCount) * 100.0;
    // Ideal i+1 injection density in narratives is roughly 4% to 8%
    if (targetDensity >= 3.0 && targetDensity <= 10.0) {
      return 95.0;
    }
    return 75.0;
  }
}
