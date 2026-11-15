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

  @override
  bool supports(GrammarFeature feature) {
    switch (feature) {
      case GrammarFeature.gender:
        return hasGender;
      case GrammarFeature.caseSystem:
      case GrammarFeature.grammaticalCase:
        return hasCases;
      case GrammarFeature.number:
        return hasNumber;
      case GrammarFeature.person:
        return hasPerson;
      case GrammarFeature.tense:
        return hasTense;
      case GrammarFeature.aspect:
        return hasAspect;
      case GrammarFeature.mood:
        return hasMood;
      case GrammarFeature.rootPattern:
        return hasRootPatternMorphology;
      case GrammarFeature.agglutinative:
        return isAgglutinative;
      case GrammarFeature.analytic:
        return isAnalytic;
      case GrammarFeature.nounClasses:
        return hasNounClasses;
      default:
        return super.supports(feature);
    }
  }
}

abstract class LanguageGrammarRuleProvider {
  bool get _usesDeclarativeProfile => profile is! GrammarCapabilityProfile;
  String get languageCode;

  /// Returns the grammar capability profile for the specific language
  GrammarCapabilityProfile get capabilityProfile =>
      const GrammarCapabilityProfile();

  GrammarProfile get profile => capabilityProfile;

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
    if (!profile.supports(GrammarFeature.number)) return _usesDeclarativeProfile ? GrammaticalNumber.none : null;
    return _usesDeclarativeProfile ? GrammaticalNumber.none : GrammaticalNumber.unknown;
  }

  /// Determine the grammatical person
  GrammaticalPerson? determinePerson(String word) {
    if (!profile.supports(GrammarFeature.person)) return _usesDeclarativeProfile ? GrammaticalPerson.none : null;
    return _usesDeclarativeProfile ? GrammaticalPerson.none : GrammaticalPerson.unknown;
  }

  /// Determine the grammatical case
  GrammaticalCase? determineCase(String word, {String? context}) {
    if (!profile.supports(GrammarFeature.caseSystem) && !profile.supports(GrammarFeature.grammaticalCase)) {
      return _usesDeclarativeProfile ? GrammaticalCase.none : null;
    }
    return _usesDeclarativeProfile ? GrammaticalCase.none : GrammaticalCase.unknown;
  }

  /// Determine the tense
  Tense? determineTense(String word) {
    if (!profile.supports(GrammarFeature.tense)) return _usesDeclarativeProfile ? Tense.none : null;
    return _usesDeclarativeProfile ? Tense.none : Tense.unknown;
  }

  /// Determine the aspect
  Aspect? determineAspect(String word) {
    if (!profile.supports(GrammarFeature.aspect)) return _usesDeclarativeProfile ? Aspect.none : null;
    return _usesDeclarativeProfile ? Aspect.none : Aspect.unknown;
  }

  /// Determine the mood
  Mood? determineMood(String word) {
    if (!profile.supports(GrammarFeature.mood)) return _usesDeclarativeProfile ? Mood.none : null;
    return _usesDeclarativeProfile ? Mood.none : Mood.unknown;
  }

  /// Extract root for Semitic languages
  String? extractRoot(String word) {
    if (!profile.supports(GrammarFeature.rootPattern)) return null;
    return null;
  }

  /// Extract pattern for Semitic languages
  String? extractPattern(String word) {
    if (!profile.supports(GrammarFeature.rootPattern)) return null;
    return null;
  }

  /// Extract affixes for agglutinative languages
  List<String>? extractAffixes(String word) {
    if (!profile.supports(GrammarFeature.agglutinative)) return null;
    return [];
  }

  /// Determine noun class
  String? determineNounClass(String word) {
    if (!profile.supports(GrammarFeature.nounClasses)) return null;
    return null;
  }
}
