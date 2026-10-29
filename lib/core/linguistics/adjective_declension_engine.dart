enum GrammaticalGender { masculine, feminine, neutral, plural }
enum GrammaticalCase { nominative, accusative, dative, genitive }
enum ArticleCategory { definite, indefinite, none }

/// Computes German adjective inflection endings across all cases and genders.
class AdjectiveDeclensionEngine {
  /// Returns the exact inflection suffix (-e, -en, -er, -es, -em).
  String getEnding({
    required GrammaticalGender gender,
    required GrammaticalCase grammaticalCase,
    required ArticleCategory article,
  }) {
    switch (article) {
      case ArticleCategory.definite:
        // Weak declension (Schwache Deklination)
        if (grammaticalCase == GrammaticalCase.nominative) {
          return gender == GrammaticalGender.plural ? 'en' : 'e';
        }
        if (grammaticalCase == GrammaticalCase.accusative) {
          if (gender == GrammaticalGender.feminine || gender == GrammaticalGender.neutral) {
            return 'e';
          }
          return 'en';
        }
        return 'en'; // Dative and Genitive always -en

      case ArticleCategory.indefinite:
        // Mixed declension (Gemischte Deklination: ein, mein, kein)
        if (grammaticalCase == GrammaticalCase.nominative) {
          switch (gender) {
            case GrammaticalGender.masculine: return 'er';
            case GrammaticalGender.feminine: return 'e';
            case GrammaticalGender.neutral: return 'es';
            case GrammaticalGender.plural: return 'en';
          }
        }
        if (grammaticalCase == GrammaticalCase.accusative) {
          switch (gender) {
            case GrammaticalGender.masculine: return 'en';
            case GrammaticalGender.feminine: return 'e';
            case GrammaticalGender.neutral: return 'es';
            case GrammaticalGender.plural: return 'en';
          }
        }
        return 'en'; // Dative and Genitive always -en

      case ArticleCategory.none:
        // Strong declension (Starke Deklination: Nullartikel)
        if (grammaticalCase == GrammaticalCase.nominative) {
          switch (gender) {
            case GrammaticalGender.masculine: return 'er';
            case GrammaticalGender.feminine: return 'e';
            case GrammaticalGender.neutral: return 'es';
            case GrammaticalGender.plural: return 'e';
          }
        }
        if (grammaticalCase == GrammaticalCase.accusative) {
          switch (gender) {
            case GrammaticalGender.masculine: return 'en';
            case GrammaticalGender.feminine: return 'e';
            case GrammaticalGender.neutral: return 'es';
            case GrammaticalGender.plural: return 'e';
          }
        }
        if (grammaticalCase == GrammaticalCase.dative) {
          switch (gender) {
            case GrammaticalGender.masculine:
            case GrammaticalGender.neutral: return 'em';
            case GrammaticalGender.feminine: return 'er';
            case GrammaticalGender.plural: return 'en';
          }
        }
        // Genitive
        switch (gender) {
          case GrammaticalGender.masculine:
          case GrammaticalGender.neutral: return 'en';
          case GrammaticalGender.feminine:
          case GrammaticalGender.plural: return 'er';
        }
    }
  }

  /// Inflects a base adjective root.
  String inflect(
    String baseRoot, {
    required GrammaticalGender gender,
    required GrammaticalCase grammaticalCase,
    required ArticleCategory article,
  }) {
    final suffix = getEnding(
      gender: gender,
      grammaticalCase: grammaticalCase,
      article: article,
    );
    // Handle root stem adjustments (e.g. teuer -> teur-)
    var stem = baseRoot;
    if (stem.endsWith('el') || (stem.endsWith('er') && stem.length > 4)) {
      stem = stem.replaceFirst(RegExp(r'e(?=[lr]$)'), '');
    }
    return '$stem$suffix';
  }
}
