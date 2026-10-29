import '../language/language_identity.dart';
import 'artifact_provenance.dart';

enum LanguageRealizationKind { lexeme, phrase, utterance, other }

/// Opaque language-owned payload envelope.
///
/// Factory-2 validates ownership/version coordinates but does not interpret
/// German, Arabic, Hindi, Mandarin or other language-specific morphology.
final class LanguageOwnedExtension {
  final String languageId;
  final String schemaRef;
  final String schemaVersion;
  final Map<String, Object?> payload;

  LanguageOwnedExtension({
    required this.languageId,
    required this.schemaRef,
    required this.schemaVersion,
    Map<String, Object?> payload = const <String, Object?>{},
  }) : payload = Map<String, Object?>.unmodifiable(payload) {
    _requireNonEmpty(languageId, 'languageId');
    _requireNonEmpty(schemaRef, 'schemaRef');
    _requireNonEmpty(schemaVersion, 'schemaVersion');
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'languageId': languageId,
        'schemaRef': schemaRef,
        'schemaVersion': schemaVersion,
        'payload': payload,
      };
}

/// Natural realization of one explicit semantic identity in one language.
///
/// Surface text is realization data only. It never allocates or replaces the
/// semantic identity supplied by the caller.
final class LanguageRealization {
  final String realizationId;
  final String semanticId;
  final LanguageIdentity language;
  final int realizationVersion;
  final LanguageRealizationKind kind;
  final String? surface;
  final List<String> acceptedForms;
  final List<LanguageOwnedExtension> extensions;
  final ArtifactProvenance provenance;

  LanguageRealization({
    required this.realizationId,
    required this.semanticId,
    required this.language,
    required this.realizationVersion,
    required this.kind,
    this.surface,
    List<String> acceptedForms = const <String>[],
    List<LanguageOwnedExtension> extensions = const <LanguageOwnedExtension>[],
    required this.provenance,
  })  : acceptedForms = List<String>.unmodifiable(acceptedForms),
        extensions = List<LanguageOwnedExtension>.unmodifiable(extensions) {
    _requireNonEmpty(realizationId, 'realizationId');
    _requireNonEmpty(semanticId, 'semanticId');
    if (realizationVersion <= 0) {
      throw ArgumentError.value(
        realizationVersion,
        'realizationVersion',
        'must be positive',
      );
    }
    if (surface != null) {
      _requireNonEmpty(surface!, 'surface');
    }
    for (final form in this.acceptedForms) {
      _requireNonEmpty(form, 'acceptedForm');
    }
    for (final extension in this.extensions) {
      if (extension.languageId != language.languageId) {
        throw StateError(
          'language-owned extension must match realization language',
        );
      }
    }
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'realizationId': realizationId,
        'semanticId': semanticId,
        'languageId': language.languageId,
        'realizationVersion': realizationVersion,
        'kind': kind.name,
        'surface': surface,
        'acceptedForms': acceptedForms,
        'extensions': extensions.map((extension) => extension.toMap()).toList(),
        'provenance': provenance.toMap(),
      };
}

void _requireNonEmpty(String value, String field) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
}
