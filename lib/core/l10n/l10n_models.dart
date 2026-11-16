import '../localization/localization_state.dart';
import '../localization/locale_provider.dart';

enum L10nSourceFormat {
  json,
  arb,
}

enum L10nChangeReason {
  userLanguage,
  learningPair,
  fallbackLanguage,
  dictionaryRegistered,
  dictionaryRemoved,
}

final class L10nPlaceholder {
  L10nPlaceholder({
    required String name,
    this.type,
    this.example,
  }) : name = _validatedToken(name, 'placeholder');

  final String name;
  final String? type;
  final String? example;
}

final class L10nMessageMetadata {
  L10nMessageMetadata({
    this.description,
    Map<String, L10nPlaceholder> placeholders =
        const <String, L10nPlaceholder>{},
  }) : placeholders =
            Map<String, L10nPlaceholder>.unmodifiable(placeholders);

  final String? description;
  final Map<String, L10nPlaceholder> placeholders;
}

final class L10nMessage {
  L10nMessage({
    required String key,
    required String template,
    L10nMessageMetadata? metadata,
  })  : key = _validatedMessageKey(key),
        template = template,
        metadata = metadata ?? L10nMessageMetadata() {
    final inferred = _extractPlaceholders(template);
    final unknownMetadata =
        this.metadata.placeholders.keys.where((name) => !inferred.contains(name));
    if (unknownMetadata.isNotEmpty) {
      throw FormatException(
        'Placeholder metadata is not present in template for $key: '
        '${unknownMetadata.join(', ')}',
      );
    }
  }

  final String key;
  final String template;
  final L10nMessageMetadata metadata;

  Set<String> get placeholders =>
      Set<String>.unmodifiable(_extractPlaceholders(template));

  String render({
    Map<String, Object?> arguments = const <String, Object?>{},
  }) {
    var rendered = template;
    for (final name in placeholders) {
      if (!arguments.containsKey(name) || arguments[name] == null) {
        throw FormatException(
          'Missing localization argument "$name" for "$key".',
        );
      }
      rendered = rendered.replaceAll('{$name}', arguments[name].toString());
    }
    return rendered;
  }
}

final class L10nDictionary {
  L10nDictionary({
    required this.locale,
    required this.sourceFormat,
    required Map<String, L10nMessage> messages,
  }) : messages = Map<String, L10nMessage>.unmodifiable(messages) {
    if (this.messages.isEmpty) {
      throw ArgumentError('Localization dictionary must not be empty.');
    }
    for (final entry in this.messages.entries) {
      if (entry.key != entry.value.key) {
        throw ArgumentError(
          'Dictionary key ${entry.key} does not match message '
          '${entry.value.key}.',
        );
      }
    }
  }

  final AppLocale locale;
  final L10nSourceFormat sourceFormat;
  final Map<String, L10nMessage> messages;

  bool contains(String key) => messages.containsKey(key.trim());

  L10nMessage? find(String key) => messages[key.trim()];

  L10nMessage require(String key) {
    final message = find(key);
    if (message == null) {
      throw StateError(
        'Missing localization key "$key" in ${locale.languageTag}.',
      );
    }
    return message;
  }
}

final class UiL10nResolvedText {
  const UiL10nResolvedText({
    required this.key,
    required this.value,
    required this.requestedLocale,
    required this.resolvedLocale,
    required this.usedFallback,
  });

  final String key;
  final String value;
  final String requestedLocale;
  final String resolvedLocale;
  final bool usedFallback;
}

final class L10nRuntimeSnapshot {
  L10nRuntimeSnapshot({
    required this.state,
    required this.fallbackLocale,
    required this.revision,
    required Set<String> loadedLocales,
  }) : loadedLocales = Set<String>.unmodifiable(loadedLocales) {
    if (revision < 0) {
      throw ArgumentError.value(revision, 'revision', 'must be non-negative');
    }
  }

  final LocalizationState state;
  final AppLocale fallbackLocale;
  final int revision;
  final Set<String> loadedLocales;

  AppLocale get userLocale => state.userLocale;
  AppLocale get sourceLocale => state.sourceLocale;
  AppLocale get targetLocale => state.targetLocale;
  bool get isRtl => userLocale.isRtl;
  String get direction => userLocale.direction.jsonValue;
}

final class L10nEngineChange {
  const L10nEngineChange({
    required this.reason,
    required this.previous,
    required this.current,
    this.dictionaryLocale,
  });

  final L10nChangeReason reason;
  final L10nRuntimeSnapshot previous;
  final L10nRuntimeSnapshot current;
  final String? dictionaryLocale;
}

String _validatedMessageKey(String raw) {
  final key = raw.trim();
  if (key.isEmpty ||
      key.length > 160 ||
      !RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.-]*$').hasMatch(key)) {
    throw FormatException('Invalid localization key: "$raw".');
  }
  return key;
}

String _validatedToken(String raw, String field) {
  final value = raw.trim();
  if (value.isEmpty ||
      value.length > 80 ||
      !RegExp(r'^[A-Za-z_][A-Za-z0-9_.-]*$').hasMatch(value)) {
    throw FormatException('Invalid $field token: "$raw".');
  }
  return value;
}

Set<String> _extractPlaceholders(String template) {
  final result = <String>{};
  final pattern = RegExp(r'\{([A-Za-z_][A-Za-z0-9_.-]*)\}');
  for (final match in pattern.allMatches(template)) {
    final name = match.group(1);
    if (name != null) result.add(name);
  }
  return result;
}
