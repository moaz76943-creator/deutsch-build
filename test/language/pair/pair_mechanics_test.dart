import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/language/language_capability.dart';
import 'package:deutsch_bilarabi/language/language_role.dart';
import 'package:deutsch_bilarabi/language/pair/pair_mechanics.dart';

LanguageRoleEligibilityRecord _eligible(String languageId, LanguageRole role) {
  return LanguageRoleEligibilityRecord(
    languageId: languageId,
    role: role,
    state: LanguageRoleEligibilityState.eligible,
  );
}

PairEndpoint _source(String languageId) {
  return PairEndpoint.source(
    languageId: languageId,
    eligibility: _eligible(languageId, LanguageRole.source),
  );
}

PairEndpoint _target(String languageId) {
  return PairEndpoint.target(
    languageId: languageId,
    eligibility: _eligible(languageId, LanguageRole.target),
  );
}

PairRule _rule() {
  return PairRule(
    ruleId: 'synthetic.structure',
    ruleVersion: '1',
    candidateKind: 'synthetic-contrast',
    requiredInputs: const <PairRuleInputRequirement>[
      PairRuleInputRequirement(
        inputKey: 'linguistic.structure',
        role: LanguageRole.source,
      ),
      PairRuleInputRequirement(
        inputKey: 'linguistic.structure',
        role: LanguageRole.target,
      ),
    ],
  );
}

PairInputFact _fact({
  required String languageId,
  required LanguageRole role,
  required String value,
  String inputKey = 'linguistic.structure',
  LanguageCapabilityState state = LanguageCapabilityState.supported,
}) {
  return PairInputFact(
    languageId: languageId,
    role: role,
    inputKey: inputKey,
    state: state,
    valueFingerprint: value,
  );
}

void main() {
  group('PairIdentity directionality', () {
    test('A→B is not B→A and reverse identity remains isolated', () {
      final ab = PairIdentity(
        sourceLanguageId: 'syn-a',
        targetLanguageId: 'syn-b',
      );
      final ba = PairIdentity(
        sourceLanguageId: 'syn-b',
        targetLanguageId: 'syn-a',
      );

      expect(ab, isNot(ba));
      expect(ab.stableId, isNot(ba.stableId));
      expect(ab.sourceLanguageId, 'syn-a');
      expect(ab.targetLanguageId, 'syn-b');
    });

    test('same-language pair is rejected', () {
      expect(
        () =>
            PairIdentity(sourceLanguageId: 'syn-a', targetLanguageId: 'syn-a'),
        throwsArgumentError,
      );
    });

    test('reverse override never applies automatically', () {
      final ab = PairIdentity(
        sourceLanguageId: 'syn-a',
        targetLanguageId: 'syn-b',
      );
      final ba = PairIdentity(
        sourceLanguageId: 'syn-b',
        targetLanguageId: 'syn-a',
      );
      final overrideRef = DirectedPairOverrideRef(
        overrideId: 'synthetic-only',
        pair: ab,
      );

      expect(overrideRef.appliesTo(ab), isTrue);
      expect(overrideRef.appliesTo(ba), isFalse);
    });
  });

  group('SOURCE/TARGET eligibility', () {
    test('USER-only eligibility cannot satisfy SOURCE requirement', () {
      final userEligibility = _eligible('syn-a', LanguageRole.user);

      expect(
        () => PairEndpoint.source(
          languageId: 'syn-a',
          eligibility: userEligibility,
        ),
        throwsArgumentError,
      );
    });

    test('ineligible endpoint fails closed', () {
      final ineligible = LanguageRoleEligibilityRecord(
        languageId: 'syn-a',
        role: LanguageRole.source,
        state: LanguageRoleEligibilityState.ineligible,
        reason: 'synthetic fixture',
      );

      expect(
        () => PairEndpoint.source(languageId: 'syn-a', eligibility: ineligible),
        throwsStateError,
      );
    });
  });

  group('mechanics-only candidate derivation', () {
    test('no implicit reverse registration or candidate propagation', () {
      final result = PairMechanics.evaluate(
        source: _source('syn-a'),
        target: _target('syn-b'),
        rule: _rule(),
        facts: <PairInputFact>[
          _fact(
            languageId: 'syn-a',
            role: LanguageRole.source,
            value: 'source-v1',
          ),
          _fact(
            languageId: 'syn-b',
            role: LanguageRole.target,
            value: 'target-v1',
          ),
        ],
      );

      expect(result.isBlocked, isFalse);
      expect(result.candidate, isNotNull);
      expect(result.candidate!.pair.sourceLanguageId, 'syn-a');
      expect(result.candidate!.pair.targetLanguageId, 'syn-b');
      expect(
        result.candidate!.pair,
        isNot(
          PairIdentity(sourceLanguageId: 'syn-b', targetLanguageId: 'syn-a'),
        ),
      );
    });

    test('English/German/third-language facts cannot act as pivots', () {
      for (final pivot in <String>['en', 'de', 'syn-c']) {
        final result = PairMechanics.evaluate(
          source: _source('syn-a'),
          target: _target('syn-b'),
          rule: _rule(),
          facts: <PairInputFact>[
            _fact(
              languageId: pivot,
              role: LanguageRole.source,
              value: 'pivot-source',
            ),
            _fact(
              languageId: 'syn-b',
              role: LanguageRole.target,
              value: 'target-v1',
            ),
          ],
        );

        expect(result.isBlocked, isTrue, reason: 'pivot=$pivot');
        expect(result.candidate, isNull, reason: 'pivot=$pivot');
      }
    });

    test('missing required input fails closed', () {
      final result = PairMechanics.evaluate(
        source: _source('syn-a'),
        target: _target('syn-b'),
        rule: _rule(),
        facts: <PairInputFact>[
          _fact(
            languageId: 'syn-a',
            role: LanguageRole.source,
            value: 'source-v1',
          ),
        ],
      );

      expect(result.isBlocked, isTrue);
      expect(result.candidate, isNull);
      expect(result.blockedReason, contains('missing'));
    });

    test('blocked required input fails closed', () {
      final result = PairMechanics.evaluate(
        source: _source('syn-a'),
        target: _target('syn-b'),
        rule: _rule(),
        facts: <PairInputFact>[
          _fact(
            languageId: 'syn-a',
            role: LanguageRole.source,
            value: 'source-v1',
          ),
          _fact(
            languageId: 'syn-b',
            role: LanguageRole.target,
            value: 'target-v1',
            state: LanguageCapabilityState.blocked,
          ),
        ],
      );

      expect(result.isBlocked, isTrue);
      expect(result.candidate, isNull);
    });

    test(
      'deterministic ID/fingerprint ignores undeclared input order and values',
      () {
        final rule = _rule();
        final baseFacts = <PairInputFact>[
          _fact(
            languageId: 'syn-a',
            role: LanguageRole.source,
            value: 'source-v1',
          ),
          _fact(
            languageId: 'syn-b',
            role: LanguageRole.target,
            value: 'target-v1',
          ),
        ];

        final first = PairMechanics.evaluate(
          source: _source('syn-a'),
          target: _target('syn-b'),
          rule: rule,
          facts: <PairInputFact>[
            ...baseFacts,
            _fact(
              languageId: 'syn-a',
              role: LanguageRole.source,
              inputKey: 'runtime.offlineContent',
              value: 'supported',
            ),
          ],
        );
        final second = PairMechanics.evaluate(
          source: _source('syn-a'),
          target: _target('syn-b'),
          rule: rule,
          facts: <PairInputFact>[
            _fact(
              languageId: 'syn-a',
              role: LanguageRole.source,
              inputKey: 'runtime.offlineContent',
              value: 'different-unrelated-value',
            ),
            baseFacts[1],
            baseFacts[0],
          ],
        );

        expect(first.isBlocked, isFalse);
        expect(second.isBlocked, isFalse);
        expect(first.candidate!.fingerprint, second.candidate!.fingerprint);
        expect(first.candidate!.candidateId, second.candidate!.candidateId);
      },
    );

    test('declared input change changes deterministic fingerprint and ID', () {
      final first = PairMechanics.evaluate(
        source: _source('syn-a'),
        target: _target('syn-b'),
        rule: _rule(),
        facts: <PairInputFact>[
          _fact(
            languageId: 'syn-a',
            role: LanguageRole.source,
            value: 'source-v1',
          ),
          _fact(
            languageId: 'syn-b',
            role: LanguageRole.target,
            value: 'target-v1',
          ),
        ],
      );
      final second = PairMechanics.evaluate(
        source: _source('syn-a'),
        target: _target('syn-b'),
        rule: _rule(),
        facts: <PairInputFact>[
          _fact(
            languageId: 'syn-a',
            role: LanguageRole.source,
            value: 'source-v2',
          ),
          _fact(
            languageId: 'syn-b',
            role: LanguageRole.target,
            value: 'target-v1',
          ),
        ],
      );

      expect(
        first.candidate!.fingerprint,
        isNot(second.candidate!.fingerprint),
      );
      expect(
        first.candidate!.candidateId,
        isNot(second.candidate!.candidateId),
      );
    });

    test(
      'non-pair capability differences do not create linguistic candidates',
      () {
        final noLinguisticInputs = PairRule(
          ruleId: 'synthetic.no-input-rule',
          ruleVersion: '1',
          candidateKind: 'synthetic-noop',
          requiredInputs: const <PairRuleInputRequirement>[],
        );

        final result = PairMechanics.evaluate(
          source: _source('syn-a'),
          target: _target('syn-b'),
          rule: noLinguisticInputs,
          facts: <PairInputFact>[
            _fact(
              languageId: 'syn-a',
              role: LanguageRole.source,
              inputKey: 'runtime.offlineContent',
              value: 'supported',
            ),
            _fact(
              languageId: 'syn-b',
              role: LanguageRole.target,
              inputKey: 'runtime.offlineContent',
              value: 'unsupported',
            ),
          ],
        );

        expect(result.isBlocked, isTrue);
        expect(result.candidate, isNull);
        expect(result.blockedReason, contains('no declared pair inputs'));
      },
    );

    test(
      'candidate state cannot self-promote to verified/readiness states',
      () {
        final stateNames = PairCandidateState.values
            .map((state) => state.name)
            .toSet();

        expect(stateNames, contains('derivedCandidate'));
        expect(stateNames, isNot(contains('verified')));
        expect(stateNames, isNot(contains('ready')));
        expect(stateNames, isNot(contains('productionReady')));
      },
    );
  });
}
