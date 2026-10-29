import 'dart:convert';

import '../localization/locale_provider.dart';
import 'l10n_models.dart';

abstract final class L10nDictionaryCodec {
  static L10nDictionary decodeJson(
    String encoded, {
    String? localeTag,
  }) {
    final root = _decodeObject(encoded);
    final resolvedLocale = _resolveLocale(
      explicit: localeTag,
      embedded: root['locale'],
      format: 'JSON',
    );

    final rawStrings = root['strings'];
    final rawMetadata = root['metadata'];
    final messages = rawStrings is Map
        ? _messagesFromMap(
            rawStrings,
            metadata: rawMetadata is Map ? rawMetadata : const <Object?, Object?>{},
            reservedKeys: const <String>{},
          )
        : _messagesFromMap(
            root,
            metadata: rawMetadata is Map ? rawMetadata : const <Object?, Object?>{},
            reservedKeys: const <String>{'locale', 'metadata'},
          );

    return L10nDictionary(
      locale: AppLocale.parse(resolvedLocale),
      sourceFormat: L10nSourceFormat.json,
      messages: messages,
    );
  }

  static L10nDictionary decodeArb(
    String encoded, {
    String? localeTag,
  }) {
    final root = _decodeObject(encoded);
    final resolvedLocale = _resolveLocale(
      explicit: localeTag,
      embedded: root['@@locale'],
      format: 'ARB',
    );

    final metadata = <Object?, Object?>{
      for (final entry in root.entries)
        if (entry.key is String &&
            (entry.key as String).startsWith('@') &&
            !(entry.key as String).startsWith('@@'))
          (entry.key as String).substring(1): entry.value,
    };

    final messages = _messagesFromMap(
      root,
      metadata: metadata,
      reservedKeys: const <String>{},
      skipAtKeys: true,
    );

    return L10nDictionary(
      locale: AppLocale.parse(resolvedLocale),
      sourceFormat: L10nSourceFormat.arb,
      messages: messages,
    );
  }

  static Map<Object?, Object?> _decodeObject(String encoded) {
    if (encoded.trim().isEmpty) {
      throw const FormatException('Localization document must not be empty.');
    }
    late final Object? decoded;
    try {
      decoded = jsonDecode(encoded);
    } on Object {
      throw const FormatException('Localization document is not valid JSON.');
    }
    if (decoded is! Map) {
      throw const FormatException(
        'Localization document root must be a JSON object.',
      );
    }
    return Map<Object?, Object?>.from(decoded);
  }

  static String _resolveLocale({
    required String? explicit,
    required Object? embedded,
    required String format,
  }) {
    final explicitValue = explicit?.trim() ?? '';
    final embeddedValue = embedded is String ? embedded.trim() : '';

    if (explicitValue.isNotEmpty &&
        embeddedValue.isNotEmpty &&
        AppLocale.parse(explicitValue).languageTag !=
            AppLocale.parse(embeddedValue).languageTag) {
      throw FormatException(
        '$format locale mismatch: $explicitValue != $embeddedValue.',
      );
    }

    final selected =
        explicitValue.isNotEmpty ? explicitValue : embeddedValue;
    if (selected.isEmpty) {
      throw FormatException('$format localization document has no locale.');
    }
    return selected;
  }

  static Map<String, L10nMessage> _messagesFromMap(
    Map rawMessages, {
    required Map metadata,
    required Set<String> reservedKeys,
    bool skipAtKeys = false,
  }) {
    final messages = <String, L10nMessage>{};

    for (final entry in rawMessages.entries) {
      final rawKey = entry.key;
      if (rawKey is! String) {
        throw const FormatException(
          'Localization message keys must be strings.',
        );
      }

      final key = rawKey.trim();
      if (reservedKeys.contains(key)) continue;
      if (skipAtKeys && key.startsWith('@')) continue;
      if (key.startsWith('@@')) continue;

      final rawValue = entry.value;
      if (rawValue is! String) {
        throw FormatException(
          'Localization message "$key" must be a string.',
        );
      }

      final rawMessageMetadata = metadata[key];
      messages[key] = L10nMessage(
        key: key,
        template: rawValue,
        metadata: _metadata(rawMessageMetadata),
      );
    }

    if (messages.isEmpty) {
      throw const FormatException(
        'Localization document contains no UI messages.',
      );
    }
    return messages;
  }

  static L10nMessageMetadata _metadata(Object? raw) {
    if (raw == null) return L10nMessageMetadata();
    if (raw is! Map) {
      throw const FormatException(
        'Localization message metadata must be an object.',
      );
    }

    final description = raw['description'];
    if (description != null && description is! String) {
      throw const FormatException(
        'Localization metadata description must be a string.',
      );
    }

    final placeholders = <String, L10nPlaceholder>{};
    final rawPlaceholders = raw['placeholders'];
    if (rawPlaceholders != null) {
      if (rawPlaceholders is! Map) {
        throw const FormatException(
          'Localization placeholders metadata must be an object.',
        );
      }

      for (final entry in rawPlaceholders.entries) {
        if (entry.key is! String) {
          throw const FormatException(
            'Localization placeholder names must be strings.',
          );
        }
        final name = (entry.key as String).trim();
        final spec = entry.value;
        if (spec != null && spec is! Map) {
          throw FormatException(
            'Placeholder metadata for "$name" must be an object.',
          );
        }
        final type = spec is Map ? spec['type'] : null;
        final example = spec is Map ? spec['example'] : null;
        if (type != null && type is! String) {
          throw FormatException(
            'Placeholder type for "$name" must be a string.',
          );
        }
        if (example != null &&
            example is! String &&
            example is! num &&
            example is! bool) {
          throw FormatException(
            'Placeholder example for "$name" must be scalar.',
          );
        }
        placeholders[name] = L10nPlaceholder(
          name: name,
          type: type as String?,
          example: example?.toString(),
        );
      }
    }

    return L10nMessageMetadata(
      description: description as String?,
      placeholders: placeholders,
    );
  }
}
