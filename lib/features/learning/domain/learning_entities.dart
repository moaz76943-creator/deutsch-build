/// German grammatical gender for noun vocabulary.
enum GermanGender { masculine, feminine, neuter }

extension GermanGenderArticle on GermanGender {
  String get article => switch (this) {
        GermanGender.masculine => 'der',
        GermanGender.feminine => 'die',
        GermanGender.neuter => 'das',
      };
}

/// Immutable vocabulary entity used by the learning domain.
final class VocabularyEntity {
  final String id;
  final String german;
  final String arabic;
  final GermanGender? gender;
  final String exampleGerman;
  final String exampleArabic;

  const VocabularyEntity({
    required this.id,
    required this.german,
    required this.arabic,
    required this.exampleGerman,
    this.exampleArabic = '',
    this.gender,
  })  : assert(id != ''),
        assert(german != ''),
        assert(arabic != ''),
        assert(exampleGerman != '');

  String get article => gender?.article ?? '';
}

/// Immutable grammar entity with a concise rule and worked example.
final class GrammarEntity {
  final String id;
  final String title;
  final String explanationArabic;
  final String exampleGerman;
  final String exampleArabic;

  const GrammarEntity({
    required this.id,
    required this.title,
    required this.explanationArabic,
    required this.exampleGerman,
    required this.exampleArabic,
  })  : assert(id != ''),
        assert(title != ''),
        assert(explanationArabic != ''),
        assert(exampleGerman != ''),
        assert(exampleArabic != '');
}
