enum GermanPerson {
  ich,
  du,
  er,
  sieSingular,
  es,
  wir,
  ihr,
  siePlural,
  sieFormal,
}

extension GermanPersonGrammar on GermanPerson {
  String get pronoun => switch (this) {
        GermanPerson.ich => 'ich',
        GermanPerson.du => 'du',
        GermanPerson.er => 'er',
        GermanPerson.sieSingular => 'sie',
        GermanPerson.es => 'es',
        GermanPerson.wir => 'wir',
        GermanPerson.ihr => 'ihr',
        GermanPerson.siePlural => 'sie',
        GermanPerson.sieFormal => 'Sie',
      };

  String get sentenceSubject => switch (this) {
        GermanPerson.ich => 'Ich',
        GermanPerson.du => 'Du',
        GermanPerson.er => 'Er',
        GermanPerson.sieSingular => 'Sie',
        GermanPerson.es => 'Es',
        GermanPerson.wir => 'Wir',
        GermanPerson.ihr => 'Ihr',
        GermanPerson.siePlural => 'Sie',
        GermanPerson.sieFormal => 'Sie',
      };

  int get paradigmIndex => switch (this) {
        GermanPerson.ich => 0,
        GermanPerson.du => 1,
        GermanPerson.er => 2,
        GermanPerson.sieSingular => 2,
        GermanPerson.es => 2,
        GermanPerson.wir => 3,
        GermanPerson.ihr => 4,
        GermanPerson.siePlural => 5,
        GermanPerson.sieFormal => 5,
      };
}

enum KonjunktivUsage {
  politeRequest,
  wish,
  hypotheticalCondition,
  advice,
}

extension KonjunktivUsageArabic on KonjunktivUsage {
  String get labelAr => switch (this) {
        KonjunktivUsage.politeRequest => 'طلب مهذب',
        KonjunktivUsage.wish => 'تمنٍ أو رغبة',
        KonjunktivUsage.hypotheticalCondition => 'شرط افتراضي',
        KonjunktivUsage.advice => 'نصيحة لطيفة',
      };
}

enum KonjunktivConstruction {
  synthetic,
  wuerdeInfinitive,
}

final class KonjunktivForm {
  const KonjunktivForm({
    required this.infinitive,
    required this.person,
    required this.surface,
    required this.construction,
    required this.explanationAr,
  });

  final String infinitive;
  final GermanPerson person;
  final String surface;
  final KonjunktivConstruction construction;
  final String explanationAr;

  bool get usesInfinitiveTail =>
      construction == KonjunktivConstruction.wuerdeInfinitive;
}

enum ComparisonPattern {
  equality,
  comparative,
  superlative,
}

extension ComparisonPatternArabic on ComparisonPattern {
  String get labelAr => switch (this) {
        ComparisonPattern.equality => 'مساواة',
        ComparisonPattern.comparative => 'مقارنة',
        ComparisonPattern.superlative => 'تفضيل',
      };
}

final class ComparisonForms {
  const ComparisonForms({
    required this.positive,
    required this.comparative,
    required this.superlativeStem,
    required this.adverbialSuperlative,
    required this.ruleLabelAr,
  });

  final String positive;
  final String comparative;
  final String superlativeStem;
  final String adverbialSuperlative;
  final String ruleLabelAr;
}

final class GrammarTrainingItem {
  const GrammarTrainingItem({
    required this.id,
    required this.category,
    required this.promptAr,
    required this.sentenceWithBlank,
    required this.expectedAnswer,
    required this.fullSentence,
    required this.explanationAr,
    this.acceptedAlternatives = const <String>[],
  });

  final String id;
  final String category;
  final String promptAr;
  final String sentenceWithBlank;
  final String expectedAnswer;
  final String fullSentence;
  final String explanationAr;
  final List<String> acceptedAlternatives;

  bool accepts(String candidate) {
    final normalized = normalizeGermanInput(candidate);
    if (normalized == normalizeGermanInput(expectedAnswer)) {
      return true;
    }
    return acceptedAlternatives.any(
      (value) => normalizeGermanInput(value) == normalized,
    );
  }
}

String normalizeGermanInput(String value) {
  var normalized = value.trim().toLowerCase();
  normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
  normalized = normalized.replaceAll(RegExp(r'[.!?]+$'), '');
  return normalized.trim();
}
