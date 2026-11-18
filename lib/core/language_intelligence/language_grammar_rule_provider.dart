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
  final bool _usesDeclarativeProfile;

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
    bool usesDeclarativeProfile = false,
  })  : _usesDeclarativeProfile = usesDeclarativeProfile,
        super(
          capabilities: _capabilitiesFromBooleans(
            hasGender: hasGender,
            hasCases: hasCases,
            hasNumber: hasNumber,
            hasPerson: hasPerson,
            hasTense: hasTense,
            hasAspect: hasAspect,
            hasMood: hasMood,
            hasRootPatternMorphology: hasRootPatternMorphology,
            isAgglutinative: isAgglutinative,
            isAnalytic: isAnalytic,
            hasNounClasses: hasNounClasses,
          ),
          supportedFeatures: _capabilitiesFromBooleans(
            hasGender: hasGender,
            hasCases: hasCases,
            hasNumber: hasNumber,
            hasPerson: hasPerson,
            hasTense: hasTense,
            hasAspect: hasAspect,
            hasMood: hasMood,
            hasRootPatternMorphology: hasRootPatternMorphology,
            isAgglutinative: isAgglutinative,
            isAnalytic: isAnalytic,
            hasNounClasses: hasNounClasses,
          ),
        );

  static Set<GrammarCapability> _capabilitiesFromBooleans({
    required bool hasGender,
    required bool hasCases,
    required bool hasNumber,
    required bool hasPerson,
    required bool hasTense,
    required bool hasAspect,
    required bool hasMood,
    required bool hasRootPatternMorphology,
    required bool isAgglutinative,
    required bool isAnalytic,
    required bool hasNounClasses,
  }) {
    final set = <GrammarCapability>{};
    if (hasGender) set.add(GrammarCapability.gender);
    if (hasCases) set.add(GrammarCapability.caseSystem);
    if (hasNumber) set.add(GrammarCapability.number);
    if (hasPerson) set.add(GrammarCapability.person);
    if (hasTense) set.add(GrammarCapability.tense);
    if (hasAspect) set.add(GrammarCapability.aspect);
    if (hasMood) set.add(GrammarCapability.mood);
    if (hasRootPatternMorphology) set.add(GrammarCapability.rootPattern);
    if (isAgglutinative) set.add(GrammarCapability.agglutinative);
    if (isAnalytic) set.add(GrammarCapability.analytic);
    if (hasNounClasses) set.add(GrammarCapability.nounClasses);
    return set;
  }
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
