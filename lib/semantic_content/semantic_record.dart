import 'artifact_provenance.dart';

/// Language-neutral semantic record kinds.
///
/// The identifier is explicit and opaque. This model intentionally exposes no
/// allocator from row order, legacy numeric suffixes, surface text or
/// translation text.
enum SemanticKind { concept, intent, proposition, relation, other }

final class SemanticRecord {
  final String semanticId;
  final int semanticVersion;
  final SemanticKind kind;
  final String? conceptId;
  final String? intentId;
  final List<String> domainRefs;
  final Map<String, Object?> neutralConstraints;
  final ArtifactProvenance provenance;

  SemanticRecord({
    required this.semanticId,
    required this.semanticVersion,
    required this.kind,
    this.conceptId,
    this.intentId,
    List<String> domainRefs = const <String>[],
    Map<String, Object?> neutralConstraints = const <String, Object?>{},
    required this.provenance,
  })  : domainRefs = List<String>.unmodifiable(domainRefs),
        neutralConstraints = Map<String, Object?>.unmodifiable(
          neutralConstraints,
        ) {
    _requireNonEmpty(semanticId, 'semanticId');
    if (semanticVersion <= 0) {
      throw ArgumentError.value(
        semanticVersion,
        'semanticVersion',
        'must be positive',
      );
    }
    if (conceptId != null) {
      _requireNonEmpty(conceptId!, 'conceptId');
    }
    if (intentId != null) {
      _requireNonEmpty(intentId!, 'intentId');
    }
    for (final domainRef in this.domainRefs) {
      _requireNonEmpty(domainRef, 'domainRef');
    }
  }

  /// Stable meaning identity. Presentation aliases never replace this value.
  String get identityKey => semanticId;

  Map<String, Object?> toMap() => <String, Object?>{
        'semanticId': semanticId,
        'semanticVersion': semanticVersion,
        'kind': kind.name,
        'conceptId': conceptId,
        'intentId': intentId,
        'domainRefs': domainRefs,
        'neutralConstraints': neutralConstraints,
        'provenance': provenance.toMap(),
      };
}

void _requireNonEmpty(String value, String field) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
}
