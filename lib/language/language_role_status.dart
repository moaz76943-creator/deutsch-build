import 'language_role.dart';

/// Per-role lifecycle/status. This record is not an aggregate deployment
/// readiness authority.
enum LanguageRoleStatusState {
  registered,
  specified,
  implemented,
  tested,
  verified,
  productionReady,
  blocked,
  quarantined,
  deprecated,
  superseded,
}

extension LanguageRoleStatusStatePolicy on LanguageRoleStatusState {
  /// Required-use semantics are intentionally fail-closed.
  ///
  /// Earlier lifecycle states, including VERIFIED, do not silently imply
  /// production readiness. Only the explicit per-role PRODUCTION_READY state
  /// can satisfy a caller that requires this status.
  bool allowsRequiredUse() {
    switch (this) {
      case LanguageRoleStatusState.productionReady:
        return true;
      case LanguageRoleStatusState.registered:
      case LanguageRoleStatusState.specified:
      case LanguageRoleStatusState.implemented:
      case LanguageRoleStatusState.tested:
      case LanguageRoleStatusState.verified:
      case LanguageRoleStatusState.blocked:
      case LanguageRoleStatusState.quarantined:
      case LanguageRoleStatusState.deprecated:
      case LanguageRoleStatusState.superseded:
        return false;
    }
  }

  bool get isFailClosed => !allowsRequiredUse();
}

/// Exact version/hash coordinate for one artifact consumed by role evidence.
final class ArtifactEvidenceCoordinate {
  final String artifactType;
  final String version;
  final String hash;
  final String? reference;

  ArtifactEvidenceCoordinate({
    required this.artifactType,
    required this.version,
    required this.hash,
    this.reference,
  }) {
    _requireNonEmpty(artifactType, 'artifactType');
    _requireNonEmpty(version, 'version');
    _requireNonEmpty(hash, 'hash');
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'artifactType': artifactType,
        'version': version,
        'hash': hash,
        'reference': reference,
      };
}

/// Exact evidence envelope for one language + one role.
///
/// Every coordinate is descriptive evidence input. This class does not compute
/// role readiness and does not promote deployment state.
final class LanguageRoleEvidenceBinding {
  final String languageId;
  final LanguageRole role;
  final String universalContractVersion;
  final String universalContractHash;
  final String manifestStaticFingerprint;
  final String capabilitySnapshotVersion;
  final String capabilitySnapshotHash;
  final List<ArtifactEvidenceCoordinate> consumedArtifactCoordinates;
  final String compatibilityPolicyVersion;
  final String compatibilityPolicyHash;
  final String readinessValidatorFingerprint;
  final String readinessEvidenceRef;

  LanguageRoleEvidenceBinding({
    required this.languageId,
    required this.role,
    required this.universalContractVersion,
    required this.universalContractHash,
    required this.manifestStaticFingerprint,
    required this.capabilitySnapshotVersion,
    required this.capabilitySnapshotHash,
    List<ArtifactEvidenceCoordinate> consumedArtifactCoordinates = const [],
    required this.compatibilityPolicyVersion,
    required this.compatibilityPolicyHash,
    required this.readinessValidatorFingerprint,
    required this.readinessEvidenceRef,
  }) : consumedArtifactCoordinates =
            List<ArtifactEvidenceCoordinate>.unmodifiable(
          consumedArtifactCoordinates,
        ) {
    _requireNonEmpty(languageId, 'languageId');
    _requireNonEmpty(universalContractVersion, 'universalContractVersion');
    _requireNonEmpty(universalContractHash, 'universalContractHash');
    _requireNonEmpty(manifestStaticFingerprint, 'manifestStaticFingerprint');
    _requireNonEmpty(capabilitySnapshotVersion, 'capabilitySnapshotVersion');
    _requireNonEmpty(capabilitySnapshotHash, 'capabilitySnapshotHash');
    _requireNonEmpty(compatibilityPolicyVersion, 'compatibilityPolicyVersion');
    _requireNonEmpty(compatibilityPolicyHash, 'compatibilityPolicyHash');
    _requireNonEmpty(
      readinessValidatorFingerprint,
      'readinessValidatorFingerprint',
    );
    _requireNonEmpty(readinessEvidenceRef, 'readinessEvidenceRef');
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'languageId': languageId,
        'role': role.wireName,
        'universalContractVersion': universalContractVersion,
        'universalContractHash': universalContractHash,
        'manifestStaticFingerprint': manifestStaticFingerprint,
        'capabilitySnapshotVersion': capabilitySnapshotVersion,
        'capabilitySnapshotHash': capabilitySnapshotHash,
        'consumedArtifactCoordinates': consumedArtifactCoordinates
            .map((coordinate) => coordinate.toMap())
            .toList(growable: false),
        'compatibilityPolicyVersion': compatibilityPolicyVersion,
        'compatibilityPolicyHash': compatibilityPolicyHash,
        'readinessValidatorFingerprint': readinessValidatorFingerprint,
        'readinessEvidenceRef': readinessEvidenceRef,
      };
}

/// Status for exactly one eligible language + role.
///
/// Eligibility is a separate axis and must be explicitly ELIGIBLE before a
/// lifecycle/status record can exist. Evidence is required before VERIFIED or
/// PRODUCTION_READY. This class does not derive aggregate readiness.
final class LanguageRoleStatusRecord {
  final String languageId;
  final LanguageRole role;
  final LanguageRoleEligibilityRecord eligibility;
  final LanguageRoleStatusState state;
  final LanguageRoleEvidenceBinding? evidenceBinding;

  factory LanguageRoleStatusRecord({
    required String languageId,
    required LanguageRole role,
    required LanguageRoleEligibilityRecord eligibility,
    required LanguageRoleStatusState state,
    LanguageRoleEvidenceBinding? evidenceBinding,
  }) {
    _requireNonEmpty(languageId, 'languageId');

    if (eligibility.languageId != languageId || eligibility.role != role) {
      throw ArgumentError(
        'eligibility must match the record languageId and role',
      );
    }

    if (!eligibility.allowsRole) {
      throw StateError('role lifecycle/status requires explicit ELIGIBLE role');
    }

    if (evidenceBinding != null &&
        (evidenceBinding.languageId != languageId ||
            evidenceBinding.role != role)) {
      throw ArgumentError(
        'evidence binding must match the record languageId and role',
      );
    }

    if ((state == LanguageRoleStatusState.verified ||
            state == LanguageRoleStatusState.productionReady) &&
        evidenceBinding == null) {
      throw StateError(
        'verified role states require exact role-scoped evidence binding',
      );
    }

    return LanguageRoleStatusRecord._(
      languageId: languageId,
      role: role,
      eligibility: eligibility,
      state: state,
      evidenceBinding: evidenceBinding,
    );
  }

  const LanguageRoleStatusRecord._({
    required this.languageId,
    required this.role,
    required this.eligibility,
    required this.state,
    required this.evidenceBinding,
  });

  bool get isFailClosed => state.isFailClosed;

  Map<String, Object?> toMap() => <String, Object?>{
        'languageId': languageId,
        'role': role.wireName,
        'eligibility': eligibility.toMap(),
        'state': state.name,
        'evidenceBinding': evidenceBinding?.toMap(),
      };
}

void _requireNonEmpty(String value, String field) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
}
