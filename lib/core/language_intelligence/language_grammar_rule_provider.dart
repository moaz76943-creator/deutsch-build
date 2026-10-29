enum GrammaticalGender {
  masculine, feminine, neuter, common, none,
}

enum GrammaticalCategory {
  noun, verb, adjective, adverb, preposition, particle, unknown,
}

enum GrammaticalNumber { singular, dual, plural, none }
enum GrammaticalCase {
  nominative, accusative, dative, genitive, instrumental,
  prepositional, vocative, none,
}
enum GrammaticalTense { past, present, future, none }
enum GrammaticalAspect { perfective, imperfective, continuous, none }
enum GrammaticalMood { indicative, subjunctive, imperative, conditional, none }
enum GrammaticalPerson { first, second, third, none }
enum MorphologyType { rootPattern, agglutinative, inflectional, analytic, unknown }

/// Omitted capabilities are UNKNOWN; they must never mean "not in this language".
enum GrammarFeature { gender, grammaticalCase, number, nounClass, agreement }
enum GrammarFeatureStatus { supported, unsupported, unknown }

class NounClass {
  final String identifier;
  final String localizedLabel;
  const NounClass(this.identifier, this.localizedLabel);

  @override
  bool operator ==(Object other) =>
      other is NounClass && other.identifier == identifier;
  @override
  int get hashCode => identifier.hashCode;
}

class GrammarCapabilityProfile {
  final Set<GrammaticalGender> supportedGenders;
  final Set<GrammaticalCase> supportedCases;
  final Set<GrammaticalNumber> supportedNumbers;
  final Set<NounClass> supportedNounClasses;
  final Set<GrammarFeature> explicitlyUnsupported;
  final MorphologyType morphologyType;
  // Null means unknown, not false.
  final bool? supportsAgreement;

  const GrammarCapabilityProfile({
    this.supportedGenders = const {},
    this.supportedCases = const {},
    this.supportedNumbers = const {},
    this.supportedNounClasses = const {},
    this.explicitlyUnsupported = const {},
    this.morphologyType = MorphologyType.unknown,
    this.supportsAgreement,
  });

  factory GrammarCapabilityProfile.empty() => const GrammarCapabilityProfile();

  GrammarFeatureStatus statusFor(GrammarFeature feature) {
    bool positive;
    switch (feature) {
      case GrammarFeature.gender:
        positive = supportedGenders.isNotEmpty;
        break;
      case GrammarFeature.grammaticalCase:
        positive = supportedCases.isNotEmpty;
        break;
      case GrammarFeature.number:
        positive = supportedNumbers.isNotEmpty;
        break;
      case GrammarFeature.nounClass:
        positive = supportedNounClasses.isNotEmpty;
        break;
      case GrammarFeature.agreement:
        if (supportsAgreement == true) return GrammarFeatureStatus.supported;
        if (supportsAgreement == false) return GrammarFeatureStatus.unsupported;
        positive = false;
        break;
    }
    if (positive) return GrammarFeatureStatus.supported;
    if (explicitlyUnsupported.contains(feature)) {
      return GrammarFeatureStatus.unsupported;
    }
    return GrammarFeatureStatus.unknown;
  }
}

/// Evidence record pointer; the runtime does NOT validate its provenance.
class VerifiedGrammarEvidence {
  final bool isSupported;
  final String? sourceEvidenceId;
  final String? packRevision;
  final String? root;
  final String? pattern;
  final List<String> agglutinativeChains;
  final GrammaticalTense tense;
  final GrammaticalAspect aspect;
  final GrammaticalMood mood;
  final GrammaticalPerson person;

  const VerifiedGrammarEvidence({
    required this.isSupported,
    this.sourceEvidenceId,
    this.packRevision,
    this.root,
    this.pattern,
    this.agglutinativeChains = const [],
    this.tense = GrammaticalTense.none,
    this.aspect = GrammaticalAspect.none,
    this.mood = GrammaticalMood.none,
    this.person = GrammaticalPerson.none,
  });

  /// Structural only; actual corpus/source validation belongs to pack admission.
  bool get hasEvidenceReference =>
      isSupported &&
      sourceEvidenceId != null &&
      sourceEvidenceId!.isNotEmpty &&
      packRevision != null &&
      packRevision!.isNotEmpty;

  factory VerifiedGrammarEvidence.unsupported() =>
      const VerifiedGrammarEvidence(isSupported: false);
}

abstract class LanguageGrammarRuleProvider {
  String get languageCode;

  GrammarCapabilityProfile get profile => GrammarCapabilityProfile.empty();

  VerifiedGrammarEvidence getVerifiedEvidence(String word) =>
      VerifiedGrammarEvidence.unsupported();

  GrammaticalGender determineGender(String word, {String? article});

  GrammaticalCategory determineCategory(String word, {String? article});

  bool isValidArticle(String word, String article);
}
