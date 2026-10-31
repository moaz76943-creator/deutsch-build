import '../language_capability.dart';
import '../language_role.dart';
import '../language_role_status.dart';

/// Fail-closed evidence outcomes for the bounded Factory-4 reducer.
///
/// This vocabulary is quality-evidence plumbing only. It does not represent
/// language, pair, deployment, or production readiness.
enum QualityGateDisposition {
  pass,
  fail,
  unknown,
  blocked,
  quarantined,
  notApplicable,
}

/// Synthetic evidence classes used to preserve authority boundaries.
///
/// In particular, a candidate cannot satisfy a Golden requirement and a
/// self-test result is only one evidence class among potentially many required
/// quality gates.
enum QualityEvidenceKind { generic, candidate, golden, selfTest }

/// One declared quality-gate requirement.
///
/// The reducer consumes already-integrated F1-A1 role/capability primitives.
/// It does not resolve manifests, semantic identities, pair truth, runtime
/// activation, or any language-specific facts.
final class QualityGateRequirement {
  final String gateId;
  final bool mandatory;
  final String? languageId;
  final LanguageRole? role;
  final LanguageCapability? capability;
  final QualityEvidenceKind? requiredEvidenceKind;
  final bool allowNotApplicable;
  final bool acceptLimitedCapability;

  QualityGateRequirement({
    required this.gateId,
    this.mandatory = true,
    this.languageId,
    this.role,
    this.capability,
    this.requiredEvidenceKind,
    this.allowNotApplicable = false,
    this.acceptLimitedCapability = false,
  }) {
    _requireNonEmpty(gateId, 'gateId');
    if (languageId != null) {
      _requireNonEmpty(languageId!, 'languageId');
    }
    if ((languageId == null) != (role == null)) {
      throw ArgumentError('languageId and role must be declared together');
    }
    if (capability != null && role == null) {
      throw ArgumentError('capability requirements must be role-scoped');
    }
  }
}

/// One synthetic evidence record submitted to a quality gate.
///
/// F1-A1 objects remain authoritative for their own invariants. Optional
/// coordinates here exist only so Factory-4 can reject cross-role,
/// cross-language, or capability mismatches instead of silently reusing
/// unrelated evidence.
final class QualityGateEvidence {
  final String gateId;
  final QualityGateDisposition disposition;
  final QualityEvidenceKind kind;
  final String? languageId;
  final LanguageRole? role;
  final LanguageRoleEligibilityRecord? eligibility;
  final LanguageRoleStatusRecord? roleStatus;
  final LanguageRoleEvidenceBinding? roleEvidenceBinding;
  final LanguageCapabilityStatus? capabilityStatus;

  const QualityGateEvidence({
    required this.gateId,
    required this.disposition,
    this.kind = QualityEvidenceKind.generic,
    this.languageId,
    this.role,
    this.eligibility,
    this.roleStatus,
    this.roleEvidenceBinding,
    this.capabilityStatus,
  });
}

/// Evaluated result for exactly one declared gate.
final class QualityGateEvaluation {
  final QualityGateRequirement requirement;
  final QualityGateDisposition disposition;
  final bool satisfied;
  final bool acceptedNotApplicable;
  final String reason;

  const QualityGateEvaluation({
    required this.requirement,
    required this.disposition,
    required this.satisfied,
    required this.acceptedNotApplicable,
    required this.reason,
  });
}

/// Aggregate result over mandatory quality gates only.
///
/// Optional evidence is preserved in [results] but cannot improve or mask a
/// mandatory non-pass. A successful reduction is not a readiness receipt.
final class QualityReductionResult {
  final QualityGateDisposition disposition;
  final bool mandatorySatisfied;
  final List<QualityGateEvaluation> results;

  QualityReductionResult({
    required this.disposition,
    required this.mandatorySatisfied,
    required List<QualityGateEvaluation> results,
  }) : results = List<QualityGateEvaluation>.unmodifiable(results);
}

/// Pure, deterministic reducer for the admitted F1-A1-only Factory-4 slice.
abstract final class QualityGateReducer {
  static QualityReductionResult reduce({
    required List<QualityGateRequirement> requirements,
    required List<QualityGateEvidence> evidence,
  }) {
    final evidenceByGate = <String, List<QualityGateEvidence>>{};
    for (final item in evidence) {
      evidenceByGate.putIfAbsent(item.gateId, () => <QualityGateEvidence>[])
        ..add(item);
    }

    final evaluations = <QualityGateEvaluation>[];
    for (final requirement in requirements) {
      final matching =
          evidenceByGate[requirement.gateId] ?? const <QualityGateEvidence>[];

      if (matching.isEmpty) {
        evaluations.add(
          QualityGateEvaluation(
            requirement: requirement,
            disposition: QualityGateDisposition.unknown,
            satisfied: false,
            acceptedNotApplicable: false,
            reason: 'missing required evidence for ' + requirement.gateId,
          ),
        );
        continue;
      }

      if (matching.length != 1) {
        evaluations.add(
          QualityGateEvaluation(
            requirement: requirement,
            disposition: QualityGateDisposition.fail,
            satisfied: false,
            acceptedNotApplicable: false,
            reason: 'duplicate/conflicting evidence for ' + requirement.gateId,
          ),
        );
        continue;
      }

      evaluations.add(_evaluate(requirement, matching.single));
    }

    final mandatory =
        evaluations.where((item) => item.requirement.mandatory).toList();
    final mandatorySatisfied = mandatory.every((item) => item.satisfied);

    if (mandatorySatisfied) {
      return QualityReductionResult(
        disposition: QualityGateDisposition.pass,
        mandatorySatisfied: true,
        results: evaluations,
      );
    }

    return QualityReductionResult(
      disposition: _strongestMandatoryFailure(mandatory),
      mandatorySatisfied: false,
      results: evaluations,
    );
  }

  static QualityGateEvaluation _evaluate(
    QualityGateRequirement requirement,
    QualityGateEvidence evidence,
  ) {
    final scopeFailure = _validateScope(requirement, evidence);
    if (scopeFailure != null) {
      return _failure(requirement, QualityGateDisposition.fail, scopeFailure);
    }

    if (requirement.requiredEvidenceKind != null &&
        evidence.kind != requirement.requiredEvidenceKind) {
      return _failure(
        requirement,
        QualityGateDisposition.fail,
        'evidence kind does not satisfy ' +
            requirement.requiredEvidenceKind!.name,
      );
    }

    final roleStatusFailure = _evaluateRoleStatus(requirement, evidence);
    if (roleStatusFailure != null) {
      return roleStatusFailure;
    }

    final capabilityEvaluation = _evaluateCapability(requirement, evidence);
    final acceptedCapabilityNotApplicable =
        capabilityEvaluation?.acceptedNotApplicable ?? false;
    if (capabilityEvaluation != null && !capabilityEvaluation.satisfied) {
      return capabilityEvaluation;
    }
    if (acceptedCapabilityNotApplicable &&
        evidence.disposition != QualityGateDisposition.notApplicable) {
      return _failure(
        requirement,
        QualityGateDisposition.fail,
        'NOT_APPLICABLE capability must use NOT_APPLICABLE evidence',
      );
    }

    switch (evidence.disposition) {
      case QualityGateDisposition.pass:
        return _pass(requirement);
      case QualityGateDisposition.fail:
        return _failure(
          requirement,
          QualityGateDisposition.fail,
          'evidence reported FAIL',
        );
      case QualityGateDisposition.unknown:
        return _failure(
          requirement,
          QualityGateDisposition.unknown,
          'evidence reported UNKNOWN',
        );
      case QualityGateDisposition.blocked:
        return _failure(
          requirement,
          QualityGateDisposition.blocked,
          'evidence reported BLOCKED',
        );
      case QualityGateDisposition.quarantined:
        return _failure(
          requirement,
          QualityGateDisposition.quarantined,
          'evidence reported QUARANTINED',
        );
      case QualityGateDisposition.notApplicable:
        if (acceptedCapabilityNotApplicable) {
          return capabilityEvaluation!;
        }
        final status = evidence.capabilityStatus;
        final justified = status != null &&
            status.state == LanguageCapabilityState.notApplicable &&
            status.justification != null &&
            status.justification!.trim().isNotEmpty;
        if (requirement.allowNotApplicable && justified) {
          return QualityGateEvaluation(
            requirement: requirement,
            disposition: QualityGateDisposition.notApplicable,
            satisfied: true,
            acceptedNotApplicable: true,
            reason: 'justified NOT_APPLICABLE accepted for this gate',
          );
        }
        return _failure(
          requirement,
          QualityGateDisposition.fail,
          'NOT_APPLICABLE is not justified/allowed for this gate',
        );
    }
  }

  static String? _validateScope(
    QualityGateRequirement requirement,
    QualityGateEvidence evidence,
  ) {
    if (requirement.languageId != null &&
        evidence.languageId != requirement.languageId) {
      return 'language scope mismatch';
    }
    if (requirement.role != null && evidence.role != requirement.role) {
      return 'role scope mismatch';
    }

    final expectedLanguage = requirement.languageId ?? evidence.languageId;
    final expectedRole = requirement.role ?? evidence.role;

    final eligibility = evidence.eligibility;
    if ((requirement.languageId != null || requirement.role != null) &&
        eligibility == null) {
      return 'scoped gate requires explicit role eligibility';
    }
    if (eligibility != null) {
      if (expectedLanguage == null ||
          expectedRole == null ||
          eligibility.languageId != expectedLanguage ||
          eligibility.role != expectedRole) {
        return 'eligibility scope mismatch';
      }
      if (!eligibility.allowsRole) {
        return 'role eligibility fails closed';
      }
    }

    final roleStatus = evidence.roleStatus;
    if (roleStatus != null &&
        (expectedLanguage == null ||
            expectedRole == null ||
            roleStatus.languageId != expectedLanguage ||
            roleStatus.role != expectedRole)) {
      return 'role status scope mismatch';
    }

    final binding = evidence.roleEvidenceBinding;
    if (binding != null &&
        (expectedLanguage == null ||
            expectedRole == null ||
            binding.languageId != expectedLanguage ||
            binding.role != expectedRole)) {
      return 'role evidence binding scope mismatch';
    }

    final capabilityStatus = evidence.capabilityStatus;
    final nestedBinding = roleStatus?.evidenceBinding;
    if (nestedBinding != null) {
      if (binding == null) {
        return 'nested role evidence binding requires consumed role evidence binding';
      }
      if (!_sameRoleEvidenceBinding(nestedBinding, binding)) {
        return 'nested role evidence binding does not match consumed role evidence binding';
      }
      if (capabilityStatus != null &&
          (nestedBinding.capabilitySnapshotVersion !=
                  capabilityStatus.snapshotVersion ||
              nestedBinding.capabilitySnapshotHash !=
                  capabilityStatus.snapshotHash)) {
        return 'nested role evidence binding capability snapshot mismatch';
      }
    }

    if (binding != null &&
        capabilityStatus != null &&
        (binding.capabilitySnapshotVersion !=
                capabilityStatus.snapshotVersion ||
            binding.capabilitySnapshotHash != capabilityStatus.snapshotHash)) {
      return 'capability snapshot does not match role evidence binding';
    }

    return null;
  }

  static bool _sameRoleEvidenceBinding(
    LanguageRoleEvidenceBinding left,
    LanguageRoleEvidenceBinding right,
  ) {
    if (left.languageId != right.languageId ||
        left.role != right.role ||
        left.universalContractVersion != right.universalContractVersion ||
        left.universalContractHash != right.universalContractHash ||
        left.manifestStaticFingerprint != right.manifestStaticFingerprint ||
        left.capabilitySnapshotVersion != right.capabilitySnapshotVersion ||
        left.capabilitySnapshotHash != right.capabilitySnapshotHash ||
        left.compatibilityPolicyVersion != right.compatibilityPolicyVersion ||
        left.compatibilityPolicyHash != right.compatibilityPolicyHash ||
        left.readinessValidatorFingerprint !=
            right.readinessValidatorFingerprint ||
        left.readinessEvidenceRef != right.readinessEvidenceRef ||
        left.consumedArtifactCoordinates.length !=
            right.consumedArtifactCoordinates.length) {
      return false;
    }

    for (var index = 0;
        index < left.consumedArtifactCoordinates.length;
        index++) {
      final leftCoordinate = left.consumedArtifactCoordinates[index];
      final rightCoordinate = right.consumedArtifactCoordinates[index];
      if (leftCoordinate.artifactType != rightCoordinate.artifactType ||
          leftCoordinate.version != rightCoordinate.version ||
          leftCoordinate.hash != rightCoordinate.hash ||
          leftCoordinate.reference != rightCoordinate.reference) {
        return false;
      }
    }

    return true;
  }

  static QualityGateEvaluation? _evaluateRoleStatus(
    QualityGateRequirement requirement,
    QualityGateEvidence evidence,
  ) {
    final status = evidence.roleStatus;
    if (status == null) {
      return null;
    }

    switch (status.state) {
      case LanguageRoleStatusState.blocked:
        return _failure(
          requirement,
          QualityGateDisposition.blocked,
          'role status is BLOCKED',
        );
      case LanguageRoleStatusState.quarantined:
        return _failure(
          requirement,
          QualityGateDisposition.quarantined,
          'role status is QUARANTINED',
        );
      case LanguageRoleStatusState.productionReady:
        return null;
      case LanguageRoleStatusState.registered:
      case LanguageRoleStatusState.specified:
      case LanguageRoleStatusState.implemented:
      case LanguageRoleStatusState.tested:
      case LanguageRoleStatusState.verified:
      case LanguageRoleStatusState.deprecated:
      case LanguageRoleStatusState.superseded:
        return _failure(
          requirement,
          QualityGateDisposition.fail,
          'role status does not allow required use',
        );
    }
  }

  static QualityGateEvaluation? _evaluateCapability(
    QualityGateRequirement requirement,
    QualityGateEvidence evidence,
  ) {
    final requiredCapability = requirement.capability;
    if (requiredCapability == null) {
      return null;
    }

    final status = evidence.capabilityStatus;
    if (status == null) {
      return _failure(
        requirement,
        QualityGateDisposition.unknown,
        'missing required capability declaration',
      );
    }

    if (status.capability != requiredCapability) {
      return _failure(
        requirement,
        QualityGateDisposition.fail,
        'capability scope mismatch',
      );
    }

    if (requirement.role != null && status.role != requirement.role) {
      return _failure(
        requirement,
        QualityGateDisposition.fail,
        'capability role scope mismatch',
      );
    }

    switch (status.state) {
      case LanguageCapabilityState.supported:
        return null;
      case LanguageCapabilityState.limited:
        if (requirement.acceptLimitedCapability) {
          return null;
        }
        return _failure(
          requirement,
          QualityGateDisposition.fail,
          'LIMITED capability requires explicit acceptance',
        );
      case LanguageCapabilityState.unsupported:
        return _failure(
          requirement,
          QualityGateDisposition.fail,
          'required capability is UNSUPPORTED',
        );
      case LanguageCapabilityState.notApplicable:
        final justified = status.justification != null &&
            status.justification!.trim().isNotEmpty;
        if (requirement.allowNotApplicable && justified) {
          return QualityGateEvaluation(
            requirement: requirement,
            disposition: QualityGateDisposition.notApplicable,
            satisfied: true,
            acceptedNotApplicable: true,
            reason: 'justified NOT_APPLICABLE accepted for this gate',
          );
        }
        return _failure(
          requirement,
          QualityGateDisposition.fail,
          'NOT_APPLICABLE is not allowed for required use',
        );
      case LanguageCapabilityState.blocked:
        return _failure(
          requirement,
          QualityGateDisposition.blocked,
          'required capability is BLOCKED',
        );
      case LanguageCapabilityState.quarantined:
        return _failure(
          requirement,
          QualityGateDisposition.quarantined,
          'required capability is QUARANTINED',
        );
    }
  }

  static QualityGateEvaluation _pass(QualityGateRequirement requirement) {
    return QualityGateEvaluation(
      requirement: requirement,
      disposition: QualityGateDisposition.pass,
      satisfied: true,
      acceptedNotApplicable: false,
      reason: 'gate satisfied',
    );
  }

  static QualityGateEvaluation _failure(
    QualityGateRequirement requirement,
    QualityGateDisposition disposition,
    String reason,
  ) {
    return QualityGateEvaluation(
      requirement: requirement,
      disposition: disposition,
      satisfied: false,
      acceptedNotApplicable: false,
      reason: reason,
    );
  }

  static QualityGateDisposition _strongestMandatoryFailure(
    List<QualityGateEvaluation> mandatory,
  ) {
    var strongest = QualityGateDisposition.unknown;
    var strongestRank = -1;

    for (final result in mandatory) {
      if (result.satisfied) {
        continue;
      }
      final rank = _failureRank(result.disposition);
      if (rank > strongestRank) {
        strongest = result.disposition;
        strongestRank = rank;
      }
    }

    return strongest;
  }

  static int _failureRank(QualityGateDisposition disposition) {
    switch (disposition) {
      case QualityGateDisposition.quarantined:
        return 4;
      case QualityGateDisposition.blocked:
        return 3;
      case QualityGateDisposition.fail:
        return 2;
      case QualityGateDisposition.unknown:
        return 1;
      case QualityGateDisposition.pass:
      case QualityGateDisposition.notApplicable:
        return 0;
    }
  }
}

void _requireNonEmpty(String value, String field) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
}
