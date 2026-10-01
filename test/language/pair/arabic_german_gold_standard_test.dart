import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/language/pair/arabic_german_gold_standard.dart';
import 'package:deutsch_bilarabi/language/pair/pair_mechanics.dart';

ArabicGermanGoldCase _case({
  String caseId = 'ar-de-a1-greeting-001',
  String semanticIntentId = 'greeting.basic',
  String sourceText = 'مرحبا',
  String canonicalTargetText = 'Hallo',
  List<String> acceptedTargetForms = const <String>['Hallo!', 'Guten Tag'],
  GoldCaseLifecycle lifecycle = GoldCaseLifecycle.canonical,
}) {
  return ArabicGermanGoldCase(
    caseId: caseId,
    semanticIntentId: semanticIntentId,
    sourceText: sourceText,
    canonicalTargetText: canonicalTargetText,
    acceptedTargetForms: acceptedTargetForms,
    skill: 'production',
    level: 'A1',
    provenanceRefs: const <String>['fixture:owner-approved'],
    evidenceRefs: const <String>['test:red-baseline'],
    lifecycle: lifecycle,
    contrastiveNotes: 'Arabic source to German target; no reverse inference.',
  );
}

void main() {
  test('Gold Standard binds exactly Arabic source to German target', () {
    final pair = ArabicGermanGoldStandard.pair;
    final reverse = PairIdentity(
      sourceLanguageId: 'de',
      targetLanguageId: 'ar',
    );

    expect(pair.sourceLanguageId, 'ar');
    expect(pair.targetLanguageId, 'de');
    expect(pair, isNot(reverse));
    expect(pair.stableId, isNot(reverse.stableId));
  });

  test(
    'valid canonical case passes schema validation and counts as evidence',
    () {
      final value = _case();

      expect(ArabicGermanGoldStandard.validate(value), isEmpty);
      expect(ArabicGermanGoldStandard.countsTowardReadiness(value), isTrue);
    },
  );

  test('candidate can validate structurally but cannot count as canonical evidence', () {
    final value = _case(lifecycle: GoldCaseLifecycle.candidate);

    expect(ArabicGermanGoldStandard.validate(value), isEmpty);
    expect(ArabicGermanGoldStandard.countsTowardReadiness(value), isFalse);
  });

  test('schema bounds reject overlong text and excessive accepted forms', () {
    final tooLong = _case(
      sourceText: 'س' * (ArabicGermanGoldStandard.maxTextLength + 1),
    );
    final tooManyForms = _case(
      acceptedTargetForms: List<String>.filled(
        ArabicGermanGoldStandard.maxAcceptedForms + 1,
        'Hallo',
      ),
    );

    expect(ArabicGermanGoldStandard.validate(tooLong), contains('sourceText'));
    expect(
      ArabicGermanGoldStandard.validate(tooManyForms),
      contains('acceptedTargetForms'),
    );
  });
}
