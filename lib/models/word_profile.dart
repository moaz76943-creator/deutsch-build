import '../core/content_contract.dart';

class WordProfile<T extends LearningContent> {
  final T item;
  final List<String> relatedForms;
  final List<String> relatedWords;
  final List<String> relatedExamples;
  final int attempts;
  final int errors;
  final bool due;
  final double masteryScore;

  const WordProfile({
    required this.item,
    this.relatedForms = const [],
    this.relatedWords = const [],
    this.relatedExamples = const [],
    this.attempts = 0,
    this.errors = 0,
    this.due = false,
    this.masteryScore = 0,
  });

  String get displayForm => item.grammaticalMarker.isEmpty
      ? item.sourceText
      : '${item.grammaticalMarker} ${item.sourceText}';
  double get successRate => attempts == 0 ? 0 : (attempts - errors) / attempts;
  bool get needsPractice => due || errors > 0 || attempts == 0;
  int get masteryPercent => (masteryScore.clamp(0.0, 1.0) * 100).round();
  String get masteryLabel => masteryPercent >= 85
      ? 'متقنة'
      : masteryPercent >= 65
          ? 'جيدة'
          : masteryPercent >= 40
              ? 'تحتاج تثبيتًا'
              : 'تحتاج تدريبًا';
}
