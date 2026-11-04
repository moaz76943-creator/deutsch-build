import 'grammar_capabilities.dart';
import 'grammar_profile.dart';

export 'grammar_capabilities.dart';
export 'grammar_profile.dart';

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

/// Names retained for clients of both grammar contract revisions.
typedef GrammaticalTense = Tense;
typedef GrammaticalAspect = Aspect;
typedef GrammaticalMood = Mood;

enum MorphologyType {
  rootPattern,
  inflectional,
  agglutinative,
  analytic,
  unknown
}

/// A provider must supply real record evidence; a capability is not verification.
class VerifiedGrammarEvidence {
  final bool isSupported;
  final String? root;
  final String? pattern;
  final Tense? tense;
  final GrammaticalPerson? person;
  final Aspect? aspect;
  final String? packRevision;

  const VerifiedGrammarEvidence({
    required this.isSupported,
    this.root,
    this.pattern,
    this.tense,
    this.person,
    this.aspect,
    this.packRevision,
  });

  const VerifiedGrammarEvidence.unsupported() : this(isSupported: false);
}

/// Legacy boolean capabilities and declared metadata share one contract.
class GrammarCapabilityProfile extends GrammarProfile {
  final bool? _hasGender;
  final bool? _hasCases;
  final bool? _hasNumber;
  final bool? _hasPerson;
  final bool? _hasTense;
  final bool? _hasAspect;
  final bool? _hasMood;
  final bool? _hasRootPatternMorphology;
  final bool? _isAgglutinative;
  final bool? _isAnalytic;
  final bool? _hasNounClasses;

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
}

abstract class LanguageGrammarRuleProvider {
  String get languageCode;

  /// Returns the grammar capability profile for the specific language
  GrammarCapabilityProfile get capabilityProfile =>
      const GrammarCapabilityProfile();

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
    if (_usesDeclarativeProfile) return GrammaticalNumber.none;
    if (!capabilityProfile.hasNumber) return null;
    return GrammaticalNumber.unknown;
  }

  /// Determine the grammatical person
  GrammaticalPerson? determinePerson(String word) {
    if (_usesDeclarativeProfile) return GrammaticalPerson.none;
    if (!capabilityProfile.hasPerson) return null;
    return GrammaticalPerson.unknown;
  }

  /// Determine the grammatical case
  GrammaticalCase? determineCase(String word, {String? context}) {
    if (_usesDeclarativeProfile) return GrammaticalCase.none;
    if (!capabilityProfile.hasCases) return null;
    return GrammaticalCase.unknown;
  }

  /// Determine the tense
  Tense? determineTense(String word) {
    if (_usesDeclarativeProfile) return Tense.none;
    if (!capabilityProfile.hasTense) return null;
    return Tense.unknown;
  }

  /// Determine the aspect
  Aspect? determineAspect(String word) {
    if (_usesDeclarativeProfile) return Aspect.none;
    if (!capabilityProfile.hasAspect) return null;
    return Aspect.unknown;
  }

  /// Determine the mood
  Mood? determineMood(String word) {
    if (_usesDeclarativeProfile) return Mood.none;
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
