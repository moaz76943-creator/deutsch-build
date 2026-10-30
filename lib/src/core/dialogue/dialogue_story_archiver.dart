class StoryDialogueLine {
  final String speaker;
  final String originalText;
  final String translation;
  final int durationSeconds;

  const StoryDialogueLine({
    required this.speaker,
    required this.originalText,
    required this.translation,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
    'speaker': speaker,
    'originalText': originalText,
    'translation': translation,
    'durationSeconds': durationSeconds,
  };
}

class CompletedStoryArchive {
  final String storyId;
  final String title;
  final String scenarioCategory;
  final String cefrLevel;
  final DateTime completedAt;
  final List<StoryDialogueLine> script;
  final List<String> keyVocabularyLearned;
  final List<String> grammarTipsExtracted;

  const CompletedStoryArchive({
    required this.storyId,
    required this.title,
    required this.scenarioCategory,
    required this.cefrLevel,
    required this.completedAt,
    required this.script,
    required this.keyVocabularyLearned,
    required this.grammarTipsExtracted,
  });

  /// Exports story as a clean readable Markdown reading/listening sheet.
  String toMarkdownStorySheet() {
    final buffer = StringBuffer();
    buffer.writeln('# 📖 Hörgeschichte: $title');
    buffer.writeln('**Niveau:** ${cefrLevel.toUpperCase()} | **Kategorie:** $scenarioCategory | **Datum:** ${completedAt.toIso8601String().substring(0, 10)}\n');

    buffer.writeln('## 💬 Dialogverlauf');
    for (final line in script) {
      buffer.writeln('**${line.speaker}:** ${line.originalText}');
      buffer.writeln('  *↳ ${line.translation}*\n');
    }

    if (keyVocabularyLearned.isNotEmpty) {
      buffer.writeln('## 🔑 Wichtiger Wortschatz');
      for (final vocab in keyVocabularyLearned) {
        buffer.writeln('- $vocab');
      }
      buffer.writeln('');
    }

    if (grammarTipsExtracted.isNotEmpty) {
      buffer.writeln('## 💡 Grammatik-Tipps aus dem Dialog');
      for (final tip in grammarTipsExtracted) {
        buffer.writeln('- $tip');
      }
    }

    return buffer.toString();
  }
}

class DialogueStoryArchiver {
  const DialogueStoryArchiver();

  /// Compiles raw conversational history into an archived learning story.
  CompletedStoryArchive archiveSession({
    required String storyId,
    required String title,
    required String scenarioCategory,
    required String cefrLevel,
    required List<StoryDialogueLine> lines,
    required List<String> vocabulary,
    required List<String> grammarCorrections,
  }) {
    return CompletedStoryArchive(
      storyId: storyId,
      title: title,
      scenarioCategory: scenarioCategory,
      cefrLevel: cefrLevel,
      completedAt: DateTime.now(),
      script: lines,
      keyVocabularyLearned: vocabulary,
      grammarTipsExtracted: grammarCorrections,
    );
  }
}
