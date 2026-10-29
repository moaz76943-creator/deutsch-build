import 'dart:convert';

enum ContentRegister {
  formal,
  neutral,
  informal;

  static ContentRegister parse(Object? raw) {
    switch (raw) {
      case 'formal':
        return ContentRegister.formal;
      case 'neutral':
        return ContentRegister.neutral;
      case 'informal':
        return ContentRegister.informal;
      default:
        throw const FormatException(
          'register must be one of: formal, neutral, informal',
        );
    }
  }
}

final class PipelineContentCard {
  PipelineContentCard({
    required this.id,
    required this.semanticId,
    required this.languageCode,
    required this.text,
    required this.register,
    this.translation,
    this.example,
    this.metadata = const <String, Object?>{},
  }) {
    _validateIdentifier(id, 'id', maxLength: 160);
    _validateIdentifier(
      semanticId,
      'semanticId',
      maxLength: 160,
    );
    _validateLanguageCode(languageCode);
    _validateRequiredUtf8(text, 'text');
    _validateOptionalUtf8(translation, 'translation');
    _validateOptionalUtf8(example, 'example');
  }

  final String id;
  final String semanticId;
  final String languageCode;
  final String text;
  final ContentRegister register;
  final String? translation;
  final String? example;
  final Map<String, Object?> metadata;

  factory PipelineContentCard.fromJson(
    Map<String, Object?> json,
  ) {
    final id = _requiredString(json, 'id');
    final semanticId = _requiredString(json, 'semanticId');
    final languageCode = _requiredString(json, 'languageCode');
    final text = _requiredString(json, 'text');
    final register = ContentRegister.parse(json['register']);
    final translation = _optionalString(json, 'translation');
    final example = _optionalString(json, 'example');
    final rawMetadata = json['metadata'];
    final metadata = rawMetadata == null
        ? const <String, Object?>{}
        : _stringKeyedMap(rawMetadata, 'metadata');

    return PipelineContentCard(
      id: id,
      semanticId: semanticId,
      languageCode: languageCode,
      text: text,
      register: register,
      translation: translation,
      example: example,
      metadata: metadata,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'semanticId': semanticId,
        'languageCode': languageCode,
        'text': text,
        'register': register.name,
        if (translation != null) 'translation': translation,
        if (example != null) 'example': example,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  static void requireStrictUtf8Bytes(
    List<int> bytes, {
    String field = 'payload',
  }) {
    final decoded = utf8.decode(bytes, allowMalformed: false);
    final roundTrip = utf8.encode(decoded);
    if (roundTrip.length != bytes.length) {
      throw FormatException('$field is not canonical UTF-8');
    }
    for (var index = 0; index < bytes.length; index += 1) {
      if (roundTrip[index] != bytes[index]) {
        throw FormatException('$field is not canonical UTF-8');
      }
    }
  }

  static bool isStrictUtf8String(String value) {
    try {
      final bytes = utf8.encode(value);
      return utf8.decode(bytes, allowMalformed: false) == value;
    } on FormatException {
      return false;
    }
  }

  static String _requiredString(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key is required');
    }
    return value;
  }

  static String? _optionalString(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('$key must be a string');
    }
    if (value.trim().isEmpty) {
      throw FormatException('$key must not be empty');
    }
    return value;
  }

  static Map<String, Object?> _stringKeyedMap(
    Object? raw,
    String field,
  ) {
    if (raw is! Map) {
      throw FormatException('$field must be an object');
    }
    final result = <String, Object?>{};
    for (final entry in raw.entries) {
      if (entry.key is! String) {
        throw FormatException('$field keys must be strings');
      }
      result[entry.key as String] = entry.value;
    }
    return Map<String, Object?>.unmodifiable(result);
  }

  static void _validateIdentifier(
    String value,
    String field, {
    required int maxLength,
  }) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length > maxLength) {
      throw ArgumentError.value(
        value,
        field,
        'must be 1..$maxLength characters',
      );
    }
    if (!isStrictUtf8String(value)) {
      throw ArgumentError.value(
        value,
        field,
        'must round-trip through strict UTF-8',
      );
    }
  }

  static void _validateLanguageCode(String value) {
    final normalized = value.trim().replaceAll('_', '-');
    if (!RegExp(r'^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*$')
        .hasMatch(normalized)) {
      throw ArgumentError.value(
        value,
        'languageCode',
        'must be a valid language tag',
      );
    }
  }

  static void _validateRequiredUtf8(
    String value,
    String field,
  ) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, field, 'must not be empty');
    }
    if (!isStrictUtf8String(value)) {
      throw ArgumentError.value(
        value,
        field,
        'must round-trip through strict UTF-8',
      );
    }
  }

  static void _validateOptionalUtf8(
    String? value,
    String field,
  ) {
    if (value == null) return;
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, field, 'must not be empty');
    }
    if (!isStrictUtf8String(value)) {
      throw ArgumentError.value(
        value,
        field,
        'must round-trip through strict UTF-8',
      );
    }
  }
}
