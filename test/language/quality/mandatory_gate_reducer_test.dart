import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/language/language_capability.dart';
import 'package:deutsch_bilarabi/language/language_role.dart';
import 'package:deutsch_bilarabi/language/language_role_status.dart';
import 'package:deutsch_bilarabi/language/quality/mandatory_gate_reducer.dart';

LanguageRoleEligibilityRecord _eligible(
  String languageId,
  LanguageRole role,
) {
  return LanguageRoleEligibilityRecord(
    languageId: languageId,
    role: role,
    state: LanguageRoleEligibilityState.eligible,
  );
}

LanguageCapabilityStatus _capability({
  required LanguageRole role,
  required LanguageCapability capability,
  required LanguageCapabilityState state,
  String? justification,
  String? limitation,
}) {
  return LanguageCapabilityStatus(
    role: role,
    capability: capability,
    state: state,
    snapshotVersion: 'synthetic-v1',
    snapshotHash: 'synthetic-hash-v1',
    justification: justification,
    limitation: limitation,
  );
}

LanguageRoleEvidenceBinding _binding(
  String languageId,
  LanguageRole role,
) {
  return LanguageRoleEvidenceBinding(
    languageId: languageId,
    role: role,
    universalContractVersion: 'f1-a1',
    universalContractHash: 'contract-hash',
    manifestStaticFingerprint: 'synthetic-static-fingerprint',
    capabilitySnapshotVersion: 'synthetic-v1',
    capabilitySnapshotHash: 'synthetic-hash-v1',
    compatibilityPolicyVersion: 'synthetic-policy-v1',
    compatibilityPolicyHash: 'synthetic-policy-hash',
    readinessValidatorFingerprint: 'synthetic-validator',
    readinessEvidenceRef: 'synthetic-evidence-ref',
  );
}

QualityGateRequirement _requirement({
  required String gateId,
  bool mandatory = true,
  String? languageId,
  LanguageRole? role,
  LanguageCapability? capability,
  QualityEvidenceKind? requiredEvidenceKind,
  bool allowNotApplicable = false,
  bool acceptLimitedCapability = false,
}) {
  return QualityGateRequirement(
    gateId: gateId,
    mandatory: mandatory,
    languageId: languageId,
    role: role,
    capability: capability,
    requiredEvidenceKind: requiredEvidenceKind,
    allowNotApplicable: allowNotApplicable,
    acceptLimitedCapability: acceptLimitedCapability,
  );
}

QualityGateEvidence _evidence({
  required String gateId,
  QualityGateDisposition disposition = QualityGateDisposition.pass,
  QualityEvidenceKind kind = QualityEvidenceKind.generic,
  String? languageId,
  LanguageRole? role,
  LanguageRoleEligibilityRecord? eligibility,
  LanguageRoleStatusRecord? roleStatus,
  LanguageRoleEvidenceBinding? roleEvidenceBinding,
  LanguageCapabilityStatus? capabilityStatus,
}) {
  return QualityGateEvidence(
    gateId: gateId,
    disposition: disposition,
    kind: kind,
    languageId: languageId,
    role: role,
    eligibility: eligibility,
    roleStatus: roleStatus,
    roleEvidenceBinding: roleEvidenceBinding,
    capabilityStatus: capabilityStatus,
  );
}

void main() {
  group('Factory-4 A1-only mandatory reducer', () {
    test('RR-A1-01 MANDATORY_FAIL_MONOTONIC', () {
      final requirements = <QualityGateRequirement>[
        _requirement(gateId: 'mandatory'),
        _requirement(gateId: 'optional', mandatory: false),
      ];

      final baseline = QualityGateReducer.reduce(
        requirements: requirements,
        evidence: <QualityGateEvidence>[
          _evidence(
            gateId: 'mandatory',
            disposition: QualityGateDisposition.fail,
          ),
        ],
      );
      final withOptionalPass = QualityGateReducer.reduce(
        requirements: requirements,
        evidence: <QualityGateEvidence>[
          _evidence(
            gateId: 'mandatory',
            disposition: QualityGateDisposition.fail,
          ),
          _evidence(gateId: 'optional'),
        ],
      );

      expect(baseline.mandatorySatisfied, isFalse);
      expect(withOptionalPass.mandatorySatisfied, isFalse);
      expect(withOptionalPass.disposition, QualityGateDisposition.fail);
    });

    test('RR-A1-02 MISSING_REQUIRED_EVIDENCE_FAILS_CLOSED', () {
      final result = QualityGateReducer.reduce(
        requirements: <QualityGateRequirement>[
          _requirement(gateId: 'required'),
        ],
        evidence: const <QualityGateEvidence>[],
      );

      expect(result.mandatorySatisfied, isFalse);
      expect(result.disposition, QualityGateDisposition.unknown);
      expect(result.results.single.reason, contains('missing'));
    });

    test('RR-A1-03 MANDATORY_BLOCKED_STAYS_BLOCKED', () {
      final result = QualityGateReducer.reduce(
        requirements: <QualityGateRequirement>[
          _requirement(
            gateId: 'capability',
            languageId: 'syn',
            role: LanguageRole.target,
            capability: LanguageCapability.writing,
          ),
        ],
        evidence: <QualityGateEvidence>[
          _evidence(
            gateId: 'capability',
            languageId: 'syn',
            role: LanguageRole.target,
            eligibility: _eligible('syn', LanguageRole.target),
            capabilityStatus: _capability(
              role: LanguageRole.target,
              capability: LanguageCapability.writing,
              state: LanguageCapabilityState.blocked,
            ),
          ),
        ],
      );

      expect(result.mandatorySatisfied, isFalse);
      expect(result.disposition, QualityGateDisposition.blocked);
    });

    test('RR-A1-04 MANDATORY_QUARANTINED_STAYS_QUARANTINED', () {
      final result = QualityGateReducer.reduce(
        requirements: <QualityGateRequirement>[
          _requirement(
            gateId: 'capability',
            languageId: 'syn',
            role: LanguageRole.target,
            capability: LanguageCapability.assessment,
          ),
        ],
        evidence: <QualityGateEvidence>[
          _evidence(
            gateId: 'capability',
            languageId: 'syn',
            role: LanguageRole.target,
            eligibility: _eligible('syn', LanguageRole.target),
            capabilityStatus: _capability(
              role: LanguageRole.target,
              capability: LanguageCapability.assessment,
              state: LanguageCapabilityState.quarantined,
            ),
          ),
        ],
      );

      expect(result.mandatorySatisfied, isFalse);
      expect(result.disposition, QualityGateDisposition.quarantined);
    });

    test('RR-A1-05 NOT_APPLICABLE_REQUIRES_JUSTIFICATION', () {
      expect(
        () => _capability(
          role: LanguageRole.target,
          capability: LanguageCapability.transliteration,
          state: LanguageCapabilityState.notApplicable,
        ),
        throwsArgumentError,
      );

      final result = QualityGateReducer.reduce(
        requirements: <QualityGateRequirement>[
          _requirement(
            gateId: 'na',
            languageId: 'syn',
            role: LanguageRole.target,
            capability: LanguageCapability.transliteration,
            allowNotApplicable: true,
          ),
        ],
        evidence: <QualityGateEvidence>[
          _evidence(
            gateId: 'na',
            disposition: QualityGateDisposition.notApplicable,
            languageId: 'syn',
            role: LanguageRole.target,
            eligibility: _eligible('syn', LanguageRole.target),
            capabilityStatus: _capability(
              role: LanguageRole.target,
              capability: LanguageCapability.transliteration,
              state: LanguageCapabilityState.notApplicable,
              justification: 'synthetic capability does not apply',
            ),
          ),
        ],
      );

      expect(result.mandatorySatisfied, isTrue);
      expect(result.disposition, QualityGateDisposition.pass);
      expect(result.results.single.acceptedNotApplicable, isTrue);

      final explicitFailure = QualityGateReducer.reduce(
        requirements: <QualityGateRequirement>[
          _requirement(
            gateId: 'na-fail',
            languageId: 'syn',
            role: LanguageRole.target,
            capability: LanguageCapability.transliteration,
            allowNotApplicable: true,
          ),
        ],
        evidence: <QualityGateEvidence>[
          _evidence(
            gateId: 'na-fail',
            disposition: QualityGateDisposition.fail,
            languageId: 'syn',
            role: LanguageRole.target,
            eligibility: _eligible('syn', LanguageRole.target),
            capabilityStatus: _capability(
              role: LanguageRole.target,
              capability: LanguageCapability.transliteration,
              state: LanguageCapabilityState.notApplicable,
              justification: 'synthetic capability does not apply',
            ),
          ),
        ],
      );

      expect(explicitFailure.mandatorySatisfied, isFalse);
      expect(explicitFailure.disposition, QualityGateDisposition.fail);
    });

    test('RR-A1-06 ROLE_EVIDENCE_MISMATCH_REJECTED', () {
      final result = QualityGateReducer.reduce(
        requirements: <QualityGateRequirement>[
          _requirement(
            gateId: 'role-evidence',
            languageId: 'syn',
            role: LanguageRole.user,
          ),
        ],
        evidence: <QualityGateEvidence>[
          _evidence(
            gateId: 'role-evidence',
            languageId: 'syn',
            role: LanguageRole.user,
            eligibility: _eligible('syn', LanguageRole.user),
            roleEvidenceBinding: _binding('syn', LanguageRole.target),
          ),
        ],
      );

      expect(result.mandatorySatisfied, isFalse);
      expect(result.disposition, QualityGateDisposition.fail);
      expect(result.results.single.reason, contains('evidence binding'));
    });

    test('RR-A1-07 TARGET_PASS_NOT_USER_PASS', () {
      final result = QualityGateReducer.reduce(
        requirements: <QualityGateRequirement>[
          _requirement(
            gateId: 'role-isolation',
            languageId: 'syn',
            role: LanguageRole.user,
          ),
        ],
        evidence: <QualityGateEvidence>[
          _evidence(
            gateId: 'role-isolation',
            languageId: 'syn',
            role: LanguageRole.target,
            eligibility: _eligible('syn', LanguageRole.target),
          ),
        ],
      );

      expect(result.mandatorySatisfied, isFalse);
      expect(result.disposition, QualityGateDisposition.fail);
    });

    test('RR-A1-08 CANDIDATE_IS_NOT_GOLDEN', () {
      final result = QualityGateReducer.reduce(
        requirements: <QualityGateRequirement>[
          _requirement(
            gateId: 'golden',
            requiredEvidenceKind: QualityEvidenceKind.golden,
          ),
        ],
        evidence: <QualityGateEvidence>[
          _evidence(
            gateId: 'golden',
            kind: QualityEvidenceKind.candidate,
          ),
        ],
      );

      expect(result.mandatorySatisfied, isFalse);
      expect(result.disposition, QualityGateDisposition.fail);
      expect(result.results.single.reason, contains('evidence kind'));
    });

    test('RR-A1-09 SELFTEST_PASS_NOT_READINESS', () {
      final result = QualityGateReducer.reduce(
        requirements: <QualityGateRequirement>[
          _requirement(
            gateId: 'self-test',
            requiredEvidenceKind: QualityEvidenceKind.selfTest,
          ),
          _requirement(
            gateId: 'authoritative-quality-evidence',
            requiredEvidenceKind: QualityEvidenceKind.golden,
          ),
        ],
        evidence: <QualityGateEvidence>[
          _evidence(
            gateId: 'self-test',
            kind: QualityEvidenceKind.selfTest,
          ),
        ],
      );

      expect(result.results.first.satisfied, isTrue);
      expect(result.mandatorySatisfied, isFalse);
      expect(result.disposition, QualityGateDisposition.unknown);
    });

    test('RR-A1-10 OPTIONAL_PASS_CANNOT_MASK_MANDATORY_NONPASS', () {
      final result = QualityGateReducer.reduce(
        requirements: <QualityGateRequirement>[
          _requirement(gateId: 'mandatory'),
          _requirement(gateId: 'optional-a', mandatory: false),
          _requirement(gateId: 'optional-b', mandatory: false),
        ],
        evidence: <QualityGateEvidence>[
          _evidence(
            gateId: 'mandatory',
            disposition: QualityGateDisposition.unknown,
          ),
          _evidence(gateId: 'optional-a'),
          _evidence(gateId: 'optional-b'),
        ],
      );

      expect(result.mandatorySatisfied, isFalse);
      expect(result.disposition, QualityGateDisposition.unknown);
    });
  });
}
