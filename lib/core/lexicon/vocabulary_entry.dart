import '../language/app_text_direction.dart';
import '../language/language_configuration.dart';

/// Lossless domain view over one lexicon-pipeline vocabulary record.
///
/// Existing schema fields are preserved verbatim. Direction metadata is read
/// from the generated camelCase fields first, then pair_identity metadata, and
/// finally the language fallback policy when neither is present.
final class VocabularyEntry {
  VocabularyEntry._({
    required this.canonicalKey,
    required this.sourceText,
    required this.targetText,
    required this.languageConfiguration,
    required Map<String, Object?> rawJson,
    required bool hadSourceDirection,
    required bool hadTargetDirection,
  })  : _rawJson = rawJson,
        _hadSourceDirection = hadSourceDirection,
        _hadTargetDirection = hadTargetDirection;

  final String canonicalKey;
  final String sourceText;
  final String targetText;
  final LanguageConfiguration languageConfiguration;

  final Map<String, Object?> _rawJson;
  final bool _hadSourceDirection;
  final bool _hadTargetDirection;

  AppTextDirection get sourceLanguageDirection =>
      languageConfiguration.sourceLanguageDirection;
  AppTextDirection get targetLanguageDirection =>
      languageConfiguration.targetLanguageDirection;

  factory VocabularyEntry.fromJson(Map<String, Object?> json) {
    final snapshot = _cloneStringMap(json);
    return VocabularyEntry._(
      canonicalKey: _requiredString(snapshot['canonical_key'], 'canonical_key'),
      sourceText: _requiredString(snapshot['source_text'], 'source_text'),
      targetText: _requiredString(snapshot['target_text'], 'target_text'),
      languageConfiguration: LanguageConfiguration.fromJson(snapshot),
      rawJson: snapshot,
      hadSourceDirection: snapshot['sourceLanguageDirection'] is String,
      hadTargetDirection: snapshot['targetLanguageDirection'] is String,
    );
  }

  /// Serializes without changing the input schema shape by default.
  ///
  /// [includeResolvedDirections] can be used by newer writers to materialize
  /// fallback values explicitly while older records remain lossless.
  Map<String, Object?> toJson({bool includeResolvedDirections = false}) {
    final json = _cloneStringMap(_rawJson);
    if (_hadSourceDirection || includeResolvedDirections) {
      json['sourceLanguageDirection'] = sourceLanguageDirection.jsonValue;
    }
    if (_hadTargetDirection || includeResolvedDirections) {
      json['targetLanguageDirection'] = targetLanguageDirection.jsonValue;
    }
    return json;
  }
}

String _requiredString(Object? value, String field) {
  if (value is! String || value.isEmpty) {
    throw FormatException('$field must be a non-empty string');
  }
  return value;
}

Map<String, Object?> _cloneStringMap(Map<String, Object?> source) {
  return <String, Object?>{
    for (final entry in source.entries) entry.key: _cloneJsonValue(entry.value),
  };
}

Object? _cloneJsonValue(Object? value) {
  if (value is Map) {
    final clone = <String, Object?>{};
    for (final entry in value.entries) {
      if (entry.key is! String) {
        throw FormatException('JSON object keys must be strings');
      }
      clone[entry.key as String] = _cloneJsonValue(entry.value);
    }
    return clone;
  }
  if (value is List) {
    return <Object?>[for (final item in value) _cloneJsonValue(item)];
  }
  return value;
}
