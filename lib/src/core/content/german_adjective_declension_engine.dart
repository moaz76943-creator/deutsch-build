/// Adjective declension category in German grammar.
enum DeclensionType { strong, weak, mixed }

/// Grammatical case.
enum GrammaticalCase { nominativ, akkusativ, dativ, genitiv }

/// Grammatical gender and number.
enum GrammaticalGender { maskulin, feminin, neutral, plural }

/// Represents an inflected German adjective with rule-based explanation.
class InflectedAdjective {
  final String baseAdjective;
  final String suffix;
  final String fullInflectedForm;
  final DeclensionType declensionType;
  final GrammaticalCase appliedCase;
  final GrammaticalGender appliedGender;

  InflectedAdjective({
    required this.baseAdjective,
    required this.suffix,
    required this.fullInflectedForm,
    required this.declensionType,
    required this.appliedCase,
    required this.appliedGender,
  });

  Map<String, dynamic> toJson() => {
        'base': baseAdjective,
        'suffix': suffix,
        'inflected': fullInflectedForm,
        'type': declensionType.name,
        'case': appliedCase.name,
        'gender': appliedGender.name,
      };
}

/// Offline linguistic rule engine for German adjective endings (Adjektivendungen).
/// Computes exact suffixes across all 48 grammatical combinations without cloud dependencies.
class GermanAdjectiveDeclensionEngine {
  /// Compute the correct adjective suffix and inflected form.
  static InflectedAdjective inflect({
    required String adjective,
    required DeclensionType type,
    required GrammaticalCase gramCase,
    required GrammaticalGender gender,
  }) {
    final cleanBase = adjective.trim().toLowerCase();
    String suffix = 'e';

    switch (type) {
      case DeclensionType.weak:
        // Weak: nach bestimmtem Artikel (der, die, das)
        if (gramCase == GrammaticalCase.nominativ) {
          suffix = (gender == GrammaticalGender.plural) ? 'en' : 'e';
        } else if (gramCase == GrammaticalCase.akkusativ) {
          if (gender == GrammaticalGender.feminin || gender == GrammaticalGender.neutral) {
            suffix = 'e';
          } else {
            suffix = 'en';
          }
        } else {
          // Dativ & Genitiv always -en in weak declension
          suffix = 'en';
        }
        break;

      case DeclensionType.mixed:
        // Mixed: nach unbestimmtem Artikel (ein, eine, ein / kein, mein)
        if (gramCase == GrammaticalCase.nominativ) {
          if (gender == GrammaticalGender.maskulin) suffix = 'er';
          else if (gender == GrammaticalGender.feminin) suffix = 'e';
          else if (gender == GrammaticalGender.neutral) suffix = 'es';
          else suffix = 'en';
        } else if (gramCase == GrammaticalCase.akkusativ) {
          if (gender == GrammaticalGender.maskulin) suffix = 'en';
          else if (gender == GrammaticalGender.feminin) suffix = 'e';
          else if (gender == GrammaticalGender.neutral) suffix = 'es';
          else suffix = 'en';
        } else {
          // Dativ & Genitiv always -en
          suffix = 'en';
        }
        break;

      case DeclensionType.strong:
        // Strong: ohne Artikel (Signalendungen des bestimmten Artikels, except Gen. Mas/Neu)
        if (gramCase == GrammaticalCase.nominativ) {
          if (gender == GrammaticalGender.maskulin) suffix = 'er';
          else if (gender == GrammaticalGender.feminin) suffix = 'e';
          else if (gender == GrammaticalGender.neutral) suffix = 'es';
          else suffix = 'e';
        } else if (gramCase == GrammaticalCase.akkusativ) {
          if (gender == GrammaticalGender.maskulin) suffix = 'en';
          else if (gender == GrammaticalGender.feminin) suffix = 'e';
          else if (gender == GrammaticalGender.neutral) suffix = 'es';
          else suffix = 'e';
        } else if (gramCase == GrammaticalCase.dativ) {
          if (gender == GrammaticalGender.feminin) suffix = 'er';
          else if (gender == GrammaticalGender.plural) suffix = 'en';
          else suffix = 'em';
        } else if (gramCase == GrammaticalCase.genitiv) {
          if (gender == GrammaticalGender.feminin || gender == GrammaticalGender.plural) suffix = 'er';
          else suffix = 'en';
        }
        break;
    }

    return InflectedAdjective(
      baseAdjective: cleanBase,
      suffix: suffix,
      fullInflectedForm: '$cleanBase$suffix',
      declensionType: type,
      appliedCase: gramCase,
      appliedGender: gender,
    );
  }
}
