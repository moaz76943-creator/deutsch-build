import 'artifact_provenance.dart';
import 'learner_content_key.dart';

/// Compatibility binding from historical/local identity into the neutral model.
///
/// Legacy identity remains a compatibility/persistence coordinate. It never
/// becomes semantic identity, and semantic identity never replaces learner
/// mastery identity.
final class LegacyBinding {
  static const String germanLegacyNamespace = 'legacy-german-content';

  final String legacyNamespace;
  final String legacyId;
  final int bindingVersion;
  final String languageId;
  final List<String> semanticRefs;
  final List<String> realizationRefs;
  final List<String> compatibilityProjectionRefs;
  final LearnerContentKey? learnerContentKey;
  final ArtifactProvenance provenance;

  LegacyBinding({
    required this.legacyNamespace,
    required this.legacyId,
    required this.bindingVersion,
    required this.languageId,
    List<String> semanticRefs = const <String>[],
    List<String> realizationRefs = const <String>[],
    List<String> compatibilityProjectionRefs = const <String>[],
    this.learnerContentKey,
    required this.provenance,
  })  : semanticRefs = List<String>.unmodifiable(semanticRefs),
        realizationRefs = List<String>.unmodifiable(realizationRefs),
        compatibilityProjectionRefs = List<String>.unmodifiable(
          compatibilityProjectionRefs,
        ) {
    _requireNonEmpty(legacyNamespace, 'legacyNamespace');
    _requireNonEmpty(legacyId, 'legacyId');
    _requireNonEmpty(languageId, 'languageId');
    if (bindingVersion <= 0) {
      throw ArgumentError.value(
        bindingVersion,
        'bindingVersion',
        'must be positive',
      );
    }
    _validateRefs(this.semanticRefs, 'semanticRef');
    _validateRefs(this.realizationRefs, 'realizationRef');
    _validateRefs(
      this.compatibilityProjectionRefs,
      'compatibilityProjectionRef',
    );
    if (learnerContentKey != null &&
        learnerContentKey!.languageId != languageId) {
      throw StateError(
        'learner content key language must match legacy binding language',
      );
    }
  }

  factory LegacyBinding.german({
    required String legacyId,
    required int bindingVersion,
    List<String> semanticRefs = const <String>[],
    List<String> realizationRefs = const <String>[],
    List<String> compatibilityProjectionRefs = const <String>[],
    required ArtifactProvenance provenance,
  }) =>
      LegacyBinding(
        legacyNamespace: germanLegacyNamespace,
        legacyId: legacyId,
        bindingVersion: bindingVersion,
        languageId: 'de',
        semanticRefs: semanticRefs,
        realizationRefs: realizationRefs,
        compatibilityProjectionRefs: compatibilityProjectionRefs,
        learnerContentKey: LearnerContentKey.germanLegacy(legacyId),
        provenance: provenance,
      );

  /// Resolve learner-addressable compatibility identity.
  ///
  /// Generic legacy bindings are allowed to be non-learner-addressable. In
  /// that case lookup fails closed rather than inventing a global bare ID.
  LearnerContentKey resolveLearnerContentKey() {
    final key = learnerContentKey;
    if (key == null) {
      throw StateError(
        'legacy binding has no explicit learner content compatibility key',
      );
    }
    return key;
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'legacyNamespace': legacyNamespace,
        'legacyId': legacyId,
        'bindingVersion': bindingVersion,
        'languageId': languageId,
        'semanticRefs': semanticRefs,
        'realizationRefs': realizationRefs,
        'compatibilityProjectionRefs': compatibilityProjectionRefs,
        'learnerContentKey': learnerContentKey?.toMap(),
        'provenance': provenance.toMap(),
      };
}

void _validateRefs(List<String> refs, String field) {
  for (final ref in refs) {
    _requireNonEmpty(ref, field);
  }
}

void _requireNonEmpty(String value, String field) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
}
