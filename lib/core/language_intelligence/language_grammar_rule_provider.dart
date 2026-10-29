enum GrammaticalGender {
  masculine,
  feminine,
  neuter,
  common,
  none,
}

enum GrammaticalCategory {
  noun,
  verb,
  adjective,
  adverb,
  preposition,
  particle,
  unknown,
<<<<<<< HEAD
}

enum GrammaticalNumber {
  singular,
  dual,
  plural,
  none,
  unknown,
}

enum GrammaticalPerson {
  first,
  second,
  third,
  none,
  unknown,
}

enum GrammaticalCase {
  nominative,
  accusative,
  dative,
  genitive,
  instrumental,
  prepositional,
  vocative,
  locative,
  ablative,
  none,
  unknown,
}

enum Tense {
  past,
  present,
  future,
  none,
  unknown,
}

enum Aspect {
  perfective,
  imperfective,
  continuous,
  none,
  unknown,
}

enum Mood {
  indicative,
  subjunctive,
  imperative,
  conditional,
  optative,
  none,
  unknown,
}

class GrammarCapabilityProfile {
  final bool hasGender;
  final bool hasCases;
  final bool hasNumber;
  final bool hasPerson;
  final bool hasTense;
  final bool hasAspect;
  final bool hasMood;
  final bool hasRootPatternMorphology;
  final bool isAgglutinative;
  final bool isAnalytic;
  final bool hasNounClasses;

  const GrammarCapabilityProfile({
    this.hasGender = false,
    this.hasCases = false,
    this.hasNumber = false,
    this.hasPerson = false,
    this.hasTense = false,
    this.hasAspect = false,
    this.hasMood = false,
    this.hasRootPatternMorphology = false,
    this.isAgglutinative = false,
    this.isAnalytic = false,
    this.hasNounClasses = false,
  });
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
}

abstract class LanguageGrammarRuleProvider {
  String get languageCode;

<<<<<<< HEAD
  /// Returns the grammar capability profile for the specific language
  GrammarCapabilityProfile get capabilityProfile =>
      const GrammarCapabilityProfile();

=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
  /// استنتاج الجنس النحوي للكلمة
  GrammaticalGender determineGender(String word, {String? article});

  /// استنتاج الفئة النحوية
  GrammaticalCategory determineCategory(String word, {String? article});

  /// التحقق مما إذا كانت الأداة مطابقة للكلمة
  bool isValidArticle(String word, String article);

  // New capabilities returning nullable values if the language doesn't support them
  // or unknown if supported but not determined.

  /// Determine the grammatical number
  GrammaticalNumber? determineNumber(String word) {
    if (!capabilityProfile.hasNumber) return null;
    return GrammaticalNumber.unknown;
  }

  /// Determine the grammatical person
  GrammaticalPerson? determinePerson(String word) {
    if (!capabilityProfile.hasPerson) return null;
    return GrammaticalPerson.unknown;
  }

  /// Determine the grammatical case
  GrammaticalCase? determineCase(String word, {String? context}) {
    if (!capabilityProfile.hasCases) return null;
    return GrammaticalCase.unknown;
  }

  /// Determine the tense
  Tense? determineTense(String word) {
    if (!capabilityProfile.hasTense) return null;
    return Tense.unknown;
  }

  /// Determine the aspect
  Aspect? determineAspect(String word) {
    if (!capabilityProfile.hasAspect) return null;
    return Aspect.unknown;
  }

  /// Determine the mood
  Mood? determineMood(String word) {
    if (!capabilityProfile.hasMood) return null;
    return Mood.unknown;
  }

  /// Extract root for Semitic languages
  String? extractRoot(String word) {
    if (!capabilityProfile.hasRootPatternMorphology) return null;
    return null;
  }

  /// Extract pattern for Semitic languages
  String? extractPattern(String word) {
    if (!capabilityProfile.hasRootPatternMorphology) return null;
    return null;
  }

  /// Extract affixes for agglutinative languages
  List<String>? extractAffixes(String word) {
    if (!capabilityProfile.isAgglutinative) return null;
    return [];
  }

  /// Determine noun class
  String? determineNounClass(String word) {
    if (!capabilityProfile.hasNounClasses) return null;
    return null;
  }
}
