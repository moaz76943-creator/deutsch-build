import '../core/content_contract.dart';
import '../language/language_content_quality.dart';

class ReadingPassage {
  final List<LearningContent> sentences;
  final List<String> targetWords;
  final String title;
  const ReadingPassage({
    required this.sentences,
    required this.targetWords,
    required this.title,
  });
}

class ReadingPractice {
  static ReadingPassage build(
    List<LearningContent> items, {
    required LanguageContentQuality contentQuality,
    String? focusSkill,
    int targetWords = 6,
    int maxSentences = 5,
  }) {
    final eligible = items
        .where(
          (x) =>
              contentQuality.issues(x).isEmpty &&
              (focusSkill == null || x.skill == focusSkill),
        )
        .toList();
    final source = eligible.isEmpty
        ? items.where((x) => contentQuality.issues(x).isEmpty).toList()
        : eligible;
    final selected = <LearningContent>[];
    final words = <String>[];
    final seen = <String>{};
    for (final x in source) {
      if (selected.length >= maxSentences) break;
      if (!seen.add(x.exampleText)) continue;
      selected.add(x);
      if (words.length < targetWords) words.add(x.sourceText);
    }
    return ReadingPassage(
      sentences: selected,
      targetWords: words,
      title: focusSkill == null ? 'قراءة اليوم' : 'قراءة مركزة على $focusSkill',
    );
  }
}
