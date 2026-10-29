import '../../../core/explain_why/deterministic_explain_why_engine.dart';

enum GrammarLevel {
  a1('A1'),
  a2('A2'),
  b1('B1');

  final String code;
  const GrammarLevel(this.code);
}

enum GrammarCase {
  nominative('Nominativ'),
  accusative('Akkusativ'),
  dative('Dativ'),
  genitive('Genitiv');

  final String label;
  const GrammarCase(this.label);
}

enum GrammarTokenRole {
  subject,
  verb,
  connector,
  articleMasculine,
  articleFeminine,
  articleNeuter,
  accusativeMarker,
  dativeMarker,
  other,
}

final class GrammarToken {
  final String id;
  final String text;
  final GrammarTokenRole role;

  const GrammarToken({
    required this.id,
    required this.text,
    this.role = GrammarTokenRole.other,
  });
}

sealed class GrammarDrill {
  final String id;
  final GrammarLevel level;
  final String titleAr;
  final String instructionAr;
  final String reasonCode;
  final Map<String, String> reasonArguments;

  const GrammarDrill({
    required this.id,
    required this.level,
    required this.titleAr,
    required this.instructionAr,
    required this.reasonCode,
    this.reasonArguments = const <String, String>{},
  });
}

final class SentenceReorderExercise extends GrammarDrill {
  final List<GrammarToken> tokens;
  final List<String> correctTokenIds;
  final String translationAr;

  const SentenceReorderExercise({
    required super.id,
    required super.level,
    required super.titleAr,
    required super.instructionAr,
    required super.reasonCode,
    super.reasonArguments,
    required this.tokens,
    required this.correctTokenIds,
    required this.translationAr,
  });
}

final class VerbConjugationDrill extends GrammarDrill {
  final String infinitive;
  final String pronoun;
  final String sentencePrefix;
  final String sentenceSuffix;
  final String expectedForm;
  final List<String> acceptedForms;

  const VerbConjugationDrill({
    required super.id,
    required super.level,
    required super.titleAr,
    required super.instructionAr,
    required super.reasonCode,
    super.reasonArguments,
    required this.infinitive,
    required this.pronoun,
    required this.sentencePrefix,
    required this.sentenceSuffix,
    required this.expectedForm,
    this.acceptedForms = const <String>[],
  });
}

final class CaseSelectionDrill extends GrammarDrill {
  final GrammarCase targetCase;
  final String sentenceBefore;
  final String noun;
  final String sentenceAfter;
  final List<String> options;
  final String expectedArticle;

  const CaseSelectionDrill({
    required super.id,
    required super.level,
    required super.titleAr,
    required super.instructionAr,
    required super.reasonCode,
    super.reasonArguments,
    required this.targetCase,
    required this.sentenceBefore,
    required this.noun,
    required this.sentenceAfter,
    required this.options,
    required this.expectedArticle,
  });
}

abstract interface class GrammarDrillRepository {
  ExplainWhyEngine get explainWhyEngine;
  List<GrammarDrill> forLevel(GrammarLevel level);
  GrammarDrill? byId(String id);
}
