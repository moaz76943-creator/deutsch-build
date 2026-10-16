import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';

void main() {
  test('unreported grammatical features remain unknown', () {
    final empty = GrammarCapabilityProfile.empty();
    expect(empty.statusFor(GrammarFeature.gender), GrammarFeatureStatus.unknown);
    expect(empty.statusFor(GrammarFeature.agreement), GrammarFeatureStatus.unknown);
    expect(empty.morphologyType, MorphologyType.unknown);
  });

  test('different languages can declare capabilities without a universal heuristic', () {
    const german = GrammarCapabilityProfile(
      supportedGenders: {GrammaticalGender.masculine, GrammaticalGender.feminine},
      supportedCases: {GrammaticalCase.dative},
      supportsAgreement: true,
      morphologyType: MorphologyType.inflectional,
    );
    const analytic = GrammarCapabilityProfile(
      explicitlyUnsupported: {GrammarFeature.gender, GrammarFeature.grammaticalCase},
      supportsAgreement: false,
      morphologyType: MorphologyType.analytic,
    );
    expect(german.statusFor(GrammarFeature.grammaticalCase), GrammarFeatureStatus.supported);
    expect(analytic.statusFor(GrammarFeature.gender), GrammarFeatureStatus.unsupported);
    expect(analytic.statusFor(GrammarFeature.number), GrammarFeatureStatus.unknown);
    expect(analytic.statusFor(GrammarFeature.agreement), GrammarFeatureStatus.unsupported);
  });

  test('synthetic grammar statements are not independently verified evidence', () {
    const unsupported = VerifiedGrammarEvidence(isSupported: false);
    const attestedRecord = VerifiedGrammarEvidence(
      isSupported: true,
      sourceEvidenceId: 'local-source-1',
      packRevision: '1.0.0',
      root: 'كتب',
      tense: GrammaticalTense.past,
    );
    expect(unsupported.hasEvidenceReference, isFalse);
    expect(const VerifiedGrammarEvidence(isSupported: true).hasEvidenceReference, isFalse);
    expect(attestedRecord.hasEvidenceReference, isTrue);
  });
}
