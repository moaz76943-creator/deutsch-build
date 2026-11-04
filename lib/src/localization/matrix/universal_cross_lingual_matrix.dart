import 'package:meta/meta.dart';

/// Morphological and typological classification for omnidirectional cross-mapping.
enum TypologicalClassification {
  isolatingAnalytic,
  agglutinative,
  fusionalInflected,
  polysynthetic,
}

/// Canonical sentence constituent word orders.
enum CanonicalWordOrder {
  svo,
  sov,
  vso,
  v2VerbSecond,
  topicProminent,
}

/// Core grammatical alignment system.
enum GrammaticalAlignment {
  nominativeAccusative,
  ergativeAbsolutive,
  austronesianSymmetricVoice,
  analyticalPrepositional,
}

/// Semantic roles used by the existing Celtic and Basque profile maps.
enum UniversalGrammaticalRole {
  subjectOrAgent,
  directObjectOrPatient,
  indirectObjectOrRecipient,
  genitivePossessor,
  instrumentalMeans,
  locativePosition,
  ablativeSource,
  allativeDirection,
  vocativeAddress,
}

/// Universal cross-lingual bridge contract enabling N x N bidirectional translation
/// and syntactic transfer between ANY pair of the 100 sovereign languages.
@immutable
abstract class OmnidirectionalLanguageProfile {
  const OmnidirectionalLanguageProfile();
  String get languageName;
  String get autonym;
  String get iso6391;
  String get iso6392or3;
  TypologicalClassification get typology;
  CanonicalWordOrder get primaryWordOrder;
  GrammaticalAlignment get alignment;
  bool get hasTones;
  bool get hasGrammaticalGender;

  /// Generates cross-linguistic transfer instructions to ANY target language.
  Map<String, String> generateOmnidirectionalTransfer(OmnidirectionalLanguageProfile target) {
    final transferRules = <String, String>{};

    // 1. Word Order Transition
    if (primaryWordOrder == target.primaryWordOrder) {
      transferRules['word_order'] = 'Congruent word order ($primaryWordOrder). Direct constituent mapping.';
    } else {
      transferRules['word_order'] = 'Constituent shift required: $primaryWordOrder -> ${target.primaryWordOrder}.';
    }

    // 2. Typological Morphology Transition
    if (typology == target.typology) {
      transferRules['morphology'] = 'Harmonious typological structure ($typology).';
    } else {
      transferRules['morphology'] = 'Structural adaptation: from $typology to ${target.typology}.';
    }

    // 3. Gender Concordance Adaptation
    if (hasGrammaticalGender && !target.hasGrammaticalGender) {
      transferRules['gender'] = 'Source noun gender is neutralized in target.';
    } else if (!hasGrammaticalGender && target.hasGrammaticalGender) {
      transferRules['gender'] = 'Target requires dedicated noun gender classification drills.';
    } else {
      transferRules['gender'] = 'Parallel gender concordance handling.';
    }

    // 4. Tone / Phonology Transfer
    if (hasTones && !target.hasTones) {
      transferRules['phonology'] = 'Tonal modulation transitions to target stress and intonation pitch accents.';
    } else if (!hasTones && target.hasTones) {
      transferRules['phonology'] = 'Target requires active tonal pitch contour training.';
    } else {
      transferRules['phonology'] = 'Congruent tonal/phonological acoustic transfer.';
    }

    return transferRules;
  }
}
