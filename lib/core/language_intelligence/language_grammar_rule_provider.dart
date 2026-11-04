import 'grammar_capabilities.dart';
import 'grammar_profile.dart';

enum GrammaticalGender { masculine, feminine, neuter, common, none }
enum GrammaticalCategory { noun, verb, adjective, adverb, preposition, particle, unknown }
enum GrammaticalNumber { singular, dual, plural, none, unknown }
enum GrammaticalPerson { first, second, third, none, unknown }
enum GrammaticalCase { nominative, accusative, dative, genitive, instrumental, prepositional, vocative, locative, ablative, none, unknown }
enum GrammaticalTense { past, present, future, none, unknown }
enum GrammaticalAspect { perfective, imperfective, continuous, none, unknown }
enum GrammaticalMood { indicative, subjunctive, imperative, conditional, optative, none, unknown }
enum MorphologyType { rootPattern, inflectional, agglutinative, analytic, unknown }

typedef Tense = GrammaticalTense;
typedef Aspect = GrammaticalAspect;
typedef Mood = GrammaticalMood;

class VerifiedGrammarEvidence {
  final bool isSupported;
  final String? root;
  final String? pattern;
  final GrammaticalTense? tense;
  final GrammaticalPerson? person;
  final GrammaticalAspect? aspect;

  const VerifiedGrammarEvidence({
    required this.isSupported,
    this.root,
    this.pattern,
    this.tense,
    this.person,
    this.aspect,
  });

  factory VerifiedGrammarEvidence.unsupported() {
    return const VerifiedGrammarEvidence(isSupported: false);
  }
}

abstract class LanguageGrammarRuleProvider {
  String get languageCode;

  GrammarProfile get profile => const GrammarProfile();

  GrammarCapabilityProfile get capabilityProfile {
    if (profile is GrammarCapabilityProfile) {
      return profile as GrammarCapabilityProfile;
    }
    return GrammarCapabilityProfile(
      hasGender: profile.supportsFeature(GrammarFeature.gender),
      hasCases: profile.supportsFeature(GrammarFeature.grammaticalCase) || profile.supportsFeature(GrammarFeature.caseSystem),
      hasNumber: profile.supportsFeature(GrammarFeature.number),
      hasPerson: profile.supportsFeature(GrammarFeature.person),
      hasTense: profile.supportsFeature(GrammarFeature.tense),
      hasAspect: profile.supportsFeature(GrammarFeature.aspect),
      hasMood: profile.supportsFeature(GrammarFeature.mood),
      hasRootPatternMorphology: profile.supportsFeature(GrammarFeature.rootPattern) || profile.morphologyType == MorphologyType.rootPattern,
      isAgglutinative: profile.supportsFeature(GrammarFeature.agglutinative) || profile.morphologyType == MorphologyType.agglutinative,
      isAnalytic: profile.supportsFeature(GrammarFeature.analytic) || profile.morphologyType == MorphologyType.analytic,
      hasNounClasses: profile.supportsFeature(GrammarFeature.nounClasses),
    );
  }

  bool supportsFeature(GrammarFeature feature) {
    if (profile is GrammarCapabilityProfile) {
      return profile.supportsFeature(feature);
    }
    return profile.supportsFeature(feature);
  }

  GrammaticalGender determineGender(String word, {String? article});
  GrammaticalCategory determineCategory(String word, {String? article});
  bool isValidArticle(String word, String article);

  GrammaticalNumber? determineNumber(String word, {String? context}) {
    if (!supportsFeature(GrammarFeature.number)) return null;
    return GrammaticalNumber.unknown;
  }

  GrammaticalPerson? determinePerson(String word) {
    if (!supportsFeature(GrammarFeature.person)) return null;
    return GrammaticalPerson.unknown;
  }

  GrammaticalCase? determineCase(String word, {String? context}) {
    if (!supportsFeature(GrammarFeature.grammaticalCase) && !supportsFeature(GrammarFeature.caseSystem)) return null;
    return GrammaticalCase.unknown;
  }

  GrammaticalTense? determineTense(String word) {
    if (!supportsFeature(GrammarFeature.tense)) return null;
    return GrammaticalTense.unknown;
  }

  GrammaticalAspect? determineAspect(String word) {
    if (!supportsFeature(GrammarFeature.aspect)) return null;
    return GrammaticalAspect.unknown;
  }

  GrammaticalMood? determineMood(String word) {
    if (!supportsFeature(GrammarFeature.mood)) return null;
    return GrammaticalMood.unknown;
  }

  String? extractRoot(String word) {
    if (!supportsFeature(GrammarFeature.rootPattern) && profile.morphologyType != MorphologyType.rootPattern) return null;
    return null;
  }

  String? extractPattern(String word) {
    if (!supportsFeature(GrammarFeature.rootPattern) && profile.morphologyType != MorphologyType.rootPattern) return null;
    return null;
  }

  List<String>? extractAffixes(String word) {
    if (!supportsFeature(GrammarFeature.agglutinative) && profile.morphologyType != MorphologyType.agglutinative) return null;
    return null;
  }

  String? determineNounClass(String word) {
    if (!supportsFeature(GrammarFeature.nounClasses)) return null;
    return null;
  }

  VerifiedGrammarEvidence getVerifiedEvidence(String word) {
    return VerifiedGrammarEvidence.unsupported();
  }
}
