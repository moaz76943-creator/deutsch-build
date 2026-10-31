import 'german_grammar_types.dart';

final class GermanNounCaseForms {
  const GermanNounCaseForms({
    required this.nominativeSingular,
    required this.accusativeSingular,
    required this.dativeSingular,
    required this.genitiveSingular,
    this.nominativePlural,
    this.accusativePlural,
    this.dativePlural,
    this.genitivePlural,
  });

  final String nominativeSingular;
  final String accusativeSingular;
  final String dativeSingular;
  final String genitiveSingular;
  final String? nominativePlural;
  final String? accusativePlural;
  final String? dativePlural;
  final String? genitivePlural;

  String? formFor(GermanCase grammaticalCase, {required bool plural}) {
    if (!plural) {
      return switch (grammaticalCase) {
        GermanCase.nominative => nominativeSingular,
        GermanCase.accusative => accusativeSingular,
        GermanCase.dative => dativeSingular,
        GermanCase.genitive => genitiveSingular,
      };
    }
    return switch (grammaticalCase) {
      GermanCase.nominative => nominativePlural,
      GermanCase.accusative => accusativePlural,
      GermanCase.dative => dativePlural,
      GermanCase.genitive => genitivePlural,
    };
  }
}
