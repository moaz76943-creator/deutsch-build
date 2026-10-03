import 'app_text_direction.dart';

/// Direction-aware configuration for one explicit source -> target pair.
final class LanguageConfiguration {
  const LanguageConfiguration({
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.sourceLanguageDirection,
    required this.targetLanguageDirection,
  });

  final String sourceLanguage;
  final String targetLanguage;
  final AppTextDirection sourceLanguageDirection;
  final AppTextDirection targetLanguageDirection;

  factory LanguageConfiguration.fromJson(Map<String, Object?> json) {
    final pairIdentity = _asStringMap(json['pair_identity']);

    final sourceLanguage = _requiredLanguage(
      _firstValue(json, const ['sourceLanguage', 'source_language']) ??
          pairIdentity?['source_language'],
      'source language',
    );
    final targetLanguage = _requiredLanguage(
      _firstValue(json, const ['targetLanguage', 'target_language']) ??
          pairIdentity?['target_language'],
      'target language',
    );

    final sourceDirection = _firstValue(json, const [
          'sourceLanguageDirection',
          'source_direction',
        ]) ??
        pairIdentity?['source_direction'];
    final targetDirection = _firstValue(json, const [
          'targetLanguageDirection',
          'target_direction',
        ]) ??
        pairIdentity?['target_direction'];

    return LanguageConfiguration(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      sourceLanguageDirection: AppTextDirection.fromJson(
        sourceDirection,
        languageCode: sourceLanguage,
      ),
      targetLanguageDirection: AppTextDirection.fromJson(
        targetDirection,
        languageCode: targetLanguage,
      ),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
        'sourceLanguageDirection': sourceLanguageDirection.jsonValue,
        'targetLanguageDirection': targetLanguageDirection.jsonValue,
      };
}

Object? _firstValue(Map<String, Object?> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) {
      return json[key];
    }
  }
  return null;
}

Map<String, Object?>? _asStringMap(Object? value) {
  if (value == null) return null;
  if (value is! Map) {
    throw FormatException('pair_identity must be an object');
  }

  final result = <String, Object?>{};
  for (final entry in value.entries) {
    if (entry.key is! String) {
      throw FormatException('pair_identity keys must be strings');
    }
    result[entry.key as String] = entry.value;
  }
  return result;
}

String _requiredLanguage(Object? value, String label) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$label must be a non-empty string');
  }
  return value.trim().toLowerCase();
}
