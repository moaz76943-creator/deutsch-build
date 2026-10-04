import '../localization/locale_provider.dart';
import '../orchestration/orchestration.dart';

final class PolyglotMatrixState {
  PolyglotMatrixState({
    required String sourceLanguageTag,
    required String targetLanguageTag,
    required this.revision,
  })  : sourceLanguageTag =
            AppLocale.parse(sourceLanguageTag).languageTag,
        targetLanguageTag =
            AppLocale.parse(targetLanguageTag).languageTag {
    if (revision < 0) {
      throw ArgumentError.value(
        revision,
        'revision',
        'must be non-negative',
      );
    }
  }

  factory PolyglotMatrixState.fromEvent(AgentEvent event) {
    if (event.topic != AgentTopics.polyglotMatrixChanged) {
      throw FormatException(
        'Expected ' +
            AgentTopics.polyglotMatrixChanged +
            ', got ' +
            event.topic +
            '.',
      );
    }
    return PolyglotMatrixState(
      sourceLanguageTag: _requiredString(
        event.payload['sourceLanguage'],
        'sourceLanguage',
      ),
      targetLanguageTag: _requiredString(
        event.payload['targetLanguage'],
        'targetLanguage',
      ),
      revision: _nonNegativeInt(event.payload['revision'], 'revision'),
    );
  }

  final String sourceLanguageTag;
  final String targetLanguageTag;
  final int revision;

  String get sourceLanguageCode =>
      AppLocale.parse(sourceLanguageTag).languageCode;

  String get targetLanguageCode =>
      AppLocale.parse(targetLanguageTag).languageCode;

  String get directedPairKey =>
      sourceLanguageTag + '->' + targetLanguageTag;

  bool get isIdentityPair =>
      sourceLanguageTag == targetLanguageTag;

  Map<String, Object?> toEventPayload() => <String, Object?>{
        'sourceLanguage': sourceLanguageTag,
        'targetLanguage': targetLanguageTag,
        'directedPair': directedPairKey,
        'revision': revision,
        'identityPair': isIdentityPair,
      };
}

enum UniversalGrammarCapability {
  konjunktivIi,
  comparativeSuperlative;

  String get wireName => switch (this) {
        UniversalGrammarCapability.konjunktivIi => 'konjunktiv_ii',
        UniversalGrammarCapability.comparativeSuperlative =>
          'comparative_superlative',
      };

  static UniversalGrammarCapability parse(Object? value) {
    final normalized = _requiredString(value, 'capability')
        .trim()
        .toLowerCase();
    return switch (normalized) {
      'konjunktiv_ii' => UniversalGrammarCapability.konjunktivIi,
      'comparative_superlative' =>
        UniversalGrammarCapability.comparativeSuperlative,
      _ => throw FormatException(
          'Unsupported grammar capability: ' + normalized,
        ),
    };
  }
}

final class GrammarAgentResult {
  GrammarAgentResult({
    required this.ok,
    required String capability,
    required String targetLanguageTag,
    required String engineId,
    required List<Map<String, Object?>> items,
    this.errorCode,
    this.message,
  })  : capability = capability.trim(),
        targetLanguageTag =
            AppLocale.parse(targetLanguageTag).languageTag,
        engineId = engineId.trim(),
        items = List<Map<String, Object?>>.unmodifiable(
          items.map(
            (item) => Map<String, Object?>.unmodifiable(item),
          ),
        ) {
    if (this.capability.isEmpty) {
      throw ArgumentError('capability must not be empty.');
    }
    if (this.engineId.isEmpty) {
      throw ArgumentError('engineId must not be empty.');
    }
  }

  factory GrammarAgentResult.fromEvent(AgentEvent event) {
    if (event.topic != AgentTopics.grammarResponse) {
      throw FormatException(
        'Expected ' +
            AgentTopics.grammarResponse +
            ', got ' +
            event.topic +
            '.',
      );
    }

    final rawItems = event.payload['items'];
    final items = <Map<String, Object?>>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is! Map) {
          throw const FormatException(
            'Grammar response items must be maps.',
          );
        }
        final converted = <String, Object?>{};
        for (final entry in item.entries) {
          if (entry.key is! String) {
            throw const FormatException(
              'Grammar response item keys must be strings.',
            );
          }
          converted[entry.key as String] = entry.value;
        }
        items.add(converted);
      }
    }

    return GrammarAgentResult(
      ok: event.payload['ok'] == true,
      capability: _requiredString(
        event.payload['capability'],
        'capability',
      ),
      targetLanguageTag: _requiredString(
        event.payload['targetLanguage'],
        'targetLanguage',
      ),
      engineId: _requiredString(
        event.payload['engineId'],
        'engineId',
      ),
      items: items,
      errorCode: _optionalString(event.payload['errorCode']),
      message: _optionalString(event.payload['message']),
    );
  }

  final bool ok;
  final String capability;
  final String targetLanguageTag;
  final String engineId;
  final List<Map<String, Object?>> items;
  final String? errorCode;
  final String? message;
}

final class TtsVoiceRequest {
  TtsVoiceRequest({
    required String text,
    required String targetLanguageTag,
    required double speed,
  })  : text = _validatedSpeechText(text),
        targetLanguageTag =
            AppLocale.parse(targetLanguageTag).languageTag,
        speed = _validatedSpeed(speed);

  factory TtsVoiceRequest.fromEvent(AgentEvent event) {
    if (event.topic != AgentTopics.ttsRequest) {
      throw FormatException(
        'Expected ' +
            AgentTopics.ttsRequest +
            ', got ' +
            event.topic +
            '.',
      );
    }
    final rawSpeed = event.payload['speed'];
    if (rawSpeed is! num) {
      throw const FormatException(
        'TTS speed must be numeric.',
      );
    }
    return TtsVoiceRequest(
      text: _requiredString(event.payload['text'], 'text'),
      targetLanguageTag: _requiredString(
        event.payload['targetLanguage'],
        'targetLanguage',
      ),
      speed: rawSpeed.toDouble(),
    );
  }

  final String text;
  final String targetLanguageTag;
  final double speed;

  Map<String, Object?> toEventPayload() => <String, Object?>{
        'text': text,
        'targetLanguage': targetLanguageTag,
        'speed': speed,
      };
}

final class TtsVoiceDispatch {
  TtsVoiceDispatch({
    required this.accepted,
    required String text,
    required String targetLanguageTag,
    required double speed,
    required String backend,
    this.rejectionReason,
  })  : text = text.trim(),
        targetLanguageTag =
            AppLocale.parse(targetLanguageTag).languageTag,
        speed = speed,
        backend = backend.trim() {
    if (this.backend.isEmpty) {
      throw ArgumentError('backend must not be empty.');
    }
  }

  factory TtsVoiceDispatch.fromEvent(AgentEvent event) {
    if (event.topic != AgentTopics.ttsPrepared) {
      throw FormatException(
        'Expected ' +
            AgentTopics.ttsPrepared +
            ', got ' +
            event.topic +
            '.',
      );
    }
    final rawSpeed = event.payload['speed'];
    if (rawSpeed is! num) {
      throw const FormatException(
        'Prepared TTS speed must be numeric.',
      );
    }
    return TtsVoiceDispatch(
      accepted: event.payload['accepted'] == true,
      text: _requiredString(event.payload['text'], 'text'),
      targetLanguageTag: _requiredString(
        event.payload['targetLanguage'],
        'targetLanguage',
      ),
      speed: rawSpeed.toDouble(),
      backend: _requiredString(event.payload['backend'], 'backend'),
      rejectionReason:
          _optionalString(event.payload['rejectionReason']),
    );
  }

  final bool accepted;
  final String text;
  final String targetLanguageTag;
  final double speed;
  final String backend;
  final String? rejectionReason;
}

String _validatedSpeechText(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(
      value,
      'text',
      'TTS text must not be empty.',
    );
  }
  if (normalized.length > 4000) {
    throw ArgumentError.value(
      normalized.length,
      'text.length',
      'TTS text must not exceed 4000 characters.',
    );
  }
  return normalized;
}

double _validatedSpeed(double value) {
  if (!value.isFinite || value < 0.5 || value > 2.0) {
    throw ArgumentError.value(
      value,
      'speed',
      'TTS speed must be between 0.5 and 2.0.',
    );
  }
  return value;
}

String _requiredString(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException(field + ' must be a non-empty string.');
  }
  return value.trim();
}

String? _optionalString(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException(
      'Optional text values must be strings.',
    );
  }
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

int _nonNegativeInt(Object? value, String field) {
  if (value is! num) {
    throw FormatException(field + ' must be numeric.');
  }
  final result = value.toInt();
  if (result < 0) {
    throw FormatException(field + ' must be non-negative.');
  }
  return result;
}
