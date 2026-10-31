/// Basic word order typology.
enum WordOrder { svo, sov, vso }

/// Language structural profile.
class TypologicalProfile {
  final String languageCode;
  final WordOrder defaultOrder;
  final bool hasGrammaticalGender;
  final bool isProDrop;
  final bool isAgglutinative;

  const TypologicalProfile({
    required this.languageCode,
    required this.defaultOrder,
    required this.hasGrammaticalGender,
    required this.isProDrop,
    required this.isAgglutinative,
  });
}

/// Anticipates L1 interference and predicts cross-linguistic acquisition hurdles.
class TypologicalTransferGovernor {
  static const Map<String, TypologicalProfile> _profiles = {
    'de': TypologicalProfile(languageCode: 'de', defaultOrder: WordOrder.svo, hasGrammaticalGender: true, isProDrop: false, isAgglutinative: false),
    'ar': TypologicalProfile(languageCode: 'ar', defaultOrder: WordOrder.vso, hasGrammaticalGender: true, isProDrop: true, isAgglutinative: false),
    'en': TypologicalProfile(languageCode: 'en', defaultOrder: WordOrder.svo, hasGrammaticalGender: false, isProDrop: false, isAgglutinative: false),
    'tr': TypologicalProfile(languageCode: 'tr', defaultOrder: WordOrder.sov, hasGrammaticalGender: false, isProDrop: true, isAgglutinative: true),
    'syc': TypologicalProfile(languageCode: 'syc', defaultOrder: WordOrder.vso, hasGrammaticalGender: true, isProDrop: true, isAgglutinative: false),
    'mt': TypologicalProfile(languageCode: 'mt', defaultOrder: WordOrder.svo, hasGrammaticalGender: true, isProDrop: false, isAgglutinative: false),
  };

  /// Compares learner L1 and target L2 to yield predictive interference flags.
  List<String> predictInterferenceRisk({required String l1, required String l2}) {
    final prof1 = _profiles[l1.toLowerCase()];
    final prof2 = _profiles[l2.toLowerCase()];
    if (prof1 == null || prof2 == null) return [];

    final warnings = <String>[];

    // Word order delta
    if (prof1.defaultOrder != prof2.defaultOrder) {
      warnings.add('Word Order Interference: ${prof1.languageCode.toUpperCase()} (${prof1.defaultOrder.name.toUpperCase()}) vs ${prof2.languageCode.toUpperCase()} (${prof2.defaultOrder.name.toUpperCase()}).');
    }

    // Pro-drop transfer
    if (prof1.isProDrop && !prof2.isProDrop) {
      warnings.add('Pronoun Dropping Risk: Learner may omit compulsory subject pronouns in ${prof2.languageCode.toUpperCase()}.');
    }

    // Gender assignment
    if (!prof1.hasGrammaticalGender && prof2.hasGrammaticalGender) {
      warnings.add('Grammatical Gender Barrier: L1 lacks noun gender; expect high interference in article selection.');
    }

    return warnings;
  }
}
