/// Provenance state is descriptive evidence only.
///
/// Factory-2 does not own canonical publication or readiness authority.
enum ArtifactProvenanceStatus { unknown, candidate, reviewed }

/// Exact version/fingerprint coordinate for one consumed or produced artifact.
final class ArtifactFingerprint {
  final String artifactType;
  final String version;
  final String fingerprint;
  final String? reference;

  ArtifactFingerprint({
    required this.artifactType,
    required this.version,
    required this.fingerprint,
    this.reference,
  }) {
    _requireNonEmpty(artifactType, 'artifactType');
    _requireNonEmpty(version, 'version');
    _requireNonEmpty(fingerprint, 'fingerprint');
    if (reference != null) {
      _requireNonEmpty(reference!, 'reference');
    }
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'artifactType': artifactType,
        'version': version,
        'fingerprint': fingerprint,
        'reference': reference,
      };
}

/// Bounded provenance/evidence envelope.
///
/// Even REVIEWED provenance is not, by itself, canonical or readiness truth.
/// Those verdicts belong to later promotion/readiness authorities.
final class ArtifactProvenance {
  final ArtifactProvenanceStatus status;
  final String producer;
  final List<String> evidenceRefs;
  final List<ArtifactFingerprint> inputFingerprints;

  ArtifactProvenance({
    required this.status,
    required this.producer,
    List<String> evidenceRefs = const <String>[],
    List<ArtifactFingerprint> inputFingerprints = const <ArtifactFingerprint>[],
  })  : evidenceRefs = List<String>.unmodifiable(evidenceRefs),
        inputFingerprints = List<ArtifactFingerprint>.unmodifiable(
          inputFingerprints,
        ) {
    _requireNonEmpty(producer, 'producer');
    for (final evidenceRef in this.evidenceRefs) {
      _requireNonEmpty(evidenceRef, 'evidenceRef');
    }
  }

  factory ArtifactProvenance.unknown({
    required String producer,
    List<ArtifactFingerprint> inputFingerprints = const <ArtifactFingerprint>[],
  }) =>
      ArtifactProvenance(
        status: ArtifactProvenanceStatus.unknown,
        producer: producer,
        inputFingerprints: inputFingerprints,
      );

  /// Provenance can never certify canonical publication by itself.
  bool get grantsCanonicalAuthority => false;

  /// Provenance can never certify runtime/readiness state by itself.
  bool get grantsReadinessAuthority => false;

  Map<String, Object?> toMap() => <String, Object?>{
        'status': status.name,
        'producer': producer,
        'evidenceRefs': evidenceRefs,
        'inputFingerprints': inputFingerprints
            .map((fingerprint) => fingerprint.toMap())
            .toList(),
      };
}

void _requireNonEmpty(String value, String field) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
}
