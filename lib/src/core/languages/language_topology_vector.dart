import 'declarative_language_profile.dart';

/// Multi-dimensional mathematical vector representing a language's structural typology.
class LanguageTopologyVector {
  final double typologyScore; // SVO=1.0, SOV=2.0, VSO=3.0
  final double caseSystemWeight; // casesCount * 0.15
  final double morphologyScore; // Isolating=0.0, Fusional=1.0, Agglutinative=2.0
  final double directionalityScore; // LTR=0.0, RTL=1.0
  final double genderComplexity; // none=0.0, 2=0.5, 3+=1.0

  const LanguageTopologyVector({
    required this.typologyScore,
    required this.caseSystemWeight,
    required this.morphologyScore,
    required this.directionalityScore,
    required this.genderComplexity,
  });

  factory LanguageTopologyVector.fromProfile(LanguageProfile profile) {
    double typ = 1.0;
    if (profile.typology == 'SOV') typ = 2.0;
    if (profile.typology == 'VSO') typ = 3.0;

    double morph = 1.0;
    if (profile.morphologyType == 'Isolating') morph = 0.0;
    if (profile.morphologyType == 'Agglutinative') morph = 2.0;

    double gen = 0.0;
    if (profile.genders.contains('m') && profile.genders.contains('f')) {
      gen = profile.genders.contains('n') ? 1.0 : 0.5;
    }

    return LanguageTopologyVector(
      typologyScore: typ,
      caseSystemWeight: profile.casesCount * 0.15,
      morphologyScore: morph,
      directionalityScore: profile.isRtl ? 1.0 : 0.0,
      genderComplexity: gen,
    );
  }
}
