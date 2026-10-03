enum OrthographyTopic {
  comma,
  spelling,
  capitalization,
  punctuation,
  date,
  number,
}

enum OrthographyExerciseKind {
  commaPlacement,
  textEntry,
}

extension OrthographyTopicLabels on OrthographyTopic {
  String get labelDe => switch (this) {
        OrthographyTopic.comma => 'Kommas',
        OrthographyTopic.spelling => 'Rechtschreibung',
        OrthographyTopic.capitalization => 'Großschreibung',
        OrthographyTopic.punctuation => 'Satzzeichen',
        OrthographyTopic.date => 'Datum',
        OrthographyTopic.number => 'Zahlen',
      };

  String get labelAr => switch (this) {
        OrthographyTopic.comma => 'الفواصل',
        OrthographyTopic.spelling => 'الإملاء',
        OrthographyTopic.capitalization => 'الحروف الكبيرة',
        OrthographyTopic.punctuation => 'علامات الترقيم',
        OrthographyTopic.date => 'التاريخ',
        OrthographyTopic.number => 'الأرقام',
      };
}

final class OrthographyExercise {
  const OrthographyExercise({
    required this.id,
    required this.topic,
    required this.kind,
    required this.promptDe,
    required this.instructionAr,
    required this.explanationAr,
    this.tokens = const <String>[],
    this.correctCommaGaps = const <int>{},
    this.acceptedAnswers = const <String>[],
  });

  final String id;
  final OrthographyTopic topic;
  final OrthographyExerciseKind kind;
  final String promptDe;
  final String instructionAr;
  final String explanationAr;
  final List<String> tokens;
  final Set<int> correctCommaGaps;
  final List<String> acceptedAnswers;

  bool get isCommaPlacement =>
      kind == OrthographyExerciseKind.commaPlacement;
}
