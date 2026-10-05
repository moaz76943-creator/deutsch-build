import '../l10n/dynamic_l10n_engine.dart';
import '../l10n/l10n_models.dart';
import '../localization/locale_provider.dart';
import '../localization/localization_state.dart';

final class ExplainWhyRequest {
  ExplainWhyRequest({
    required String reasonCode,
    required this.correct,
    Map<String, String> arguments = const <String, String>{},
  })  : reasonCode = _validatedReasonCode(reasonCode),
        arguments = Map<String, String>.unmodifiable(arguments);

  final String reasonCode;
  final bool correct;
  final Map<String, String> arguments;
}

final class ExplainWhyResult {
  const ExplainWhyResult({
    required this.reasonCode,
    required this.languageCode,
    required this.text,
  });

  final String reasonCode;
  final String languageCode;
  final String text;
}

final class ExplainWhyTemplate {
  ExplainWhyTemplate({
    required String reasonCode,
    required this.successTemplate,
    required this.failureTemplate,
  }) : reasonCode = _validatedReasonCode(reasonCode) {
    if (successTemplate.trim().isEmpty || failureTemplate.trim().isEmpty) {
      throw const FormatException('explain_why_template_empty');
    }
  }

  final String reasonCode;
  final String successTemplate;
  final String failureTemplate;
}

final class ExplainWhyCatalog {
  ExplainWhyCatalog({
    required String userLanguageCode,
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required Map<String, ExplainWhyTemplate> templates,
  })  : userLanguageCode = _validatedLanguageCode(userLanguageCode),
        sourceLanguageCode = _validatedLanguageCode(sourceLanguageCode),
        targetLanguageCode = _validatedLanguageCode(targetLanguageCode),
        templates = Map<String, ExplainWhyTemplate>.unmodifiable(templates) {
    if (this.templates.isEmpty) {
      throw ArgumentError('Explain Why catalog cannot be empty.');
    }
    for (final entry in this.templates.entries) {
      final key = _validatedReasonCode(entry.key);
      if (key != entry.value.reasonCode) {
        throw ArgumentError(
          'Explain Why template key does not match reasonCode: ' + key + '.',
        );
      }
    }
  }

  final String userLanguageCode;
  final String sourceLanguageCode;
  final String targetLanguageCode;
  final Map<String, ExplainWhyTemplate> templates;

  L10nDictionary toDictionary() {
    final messages = <String, L10nMessage>{};
    for (final template in templates.values) {
      final successKey = _messageKey(template.reasonCode, correct: true);
      final failureKey = _messageKey(template.reasonCode, correct: false);
      messages[successKey] = L10nMessage(
        key: successKey,
        template: template.successTemplate,
      );
      messages[failureKey] = L10nMessage(
        key: failureKey,
        template: template.failureTemplate,
      );
    }
    return L10nDictionary(
      locale: AppLocale.parse(userLanguageCode),
      sourceFormat: L10nSourceFormat.json,
      messages: messages,
    );
  }
}

abstract interface class ExplainWhyEngine {
  bool supports(String reasonCode);
  ExplainWhyResult explain(ExplainWhyRequest request);
}

/// Deterministic reason-code adapter over the project's central localization
/// runtime. It performs no network, persistence, clock, randomness, or AI work.
///
/// Runtime lookup is O(1) by reason key plus O(P) placeholder rendering.
/// Storage scales with reusable reason templates O(R), not learning items.
final class DeterministicExplainWhyEngine implements ExplainWhyEngine {
  DeterministicExplainWhyEngine(this.catalog)
      : _l10n = DynamicL10nEngine(
          initialState: LocalizationState.fromLanguageTags(
            userLanguageTag: catalog.userLanguageCode,
            sourceLanguageTag: catalog.sourceLanguageCode,
            targetLanguageTag: catalog.targetLanguageCode,
          ),
          fallbackLanguageTag: catalog.userLanguageCode,
          dictionaries: <L10nDictionary>[catalog.toDictionary()],
        );

  final ExplainWhyCatalog catalog;
  final DynamicL10nEngine _l10n;

  @override
  bool supports(String reasonCode) {
    try {
      return catalog.templates.containsKey(_validatedReasonCode(reasonCode));
    } on FormatException {
      return false;
    }
  }

  @override
  ExplainWhyResult explain(ExplainWhyRequest request) {
    if (!supports(request.reasonCode)) {
      throw StateError(
        'explain_why_reason_unsupported:' + request.reasonCode,
      );
    }

    final key = _messageKey(request.reasonCode, correct: request.correct);
    final message = _l10n.findMessage(
      key,
      languageTag: catalog.userLanguageCode,
    );
    if (message == null) {
      throw StateError('explain_why_template_missing:' + key);
    }

    final resolved = _l10n.resolve(
      key,
      arguments: request.arguments,
    );
    return ExplainWhyResult(
      reasonCode: request.reasonCode,
      languageCode: resolved.resolvedLocale,
      text: resolved.value,
    );
  }
}

String _messageKey(String reasonCode, {required bool correct}) =>
    'explain.' + reasonCode + '.' + (correct ? 'correct' : 'incorrect');

String _validatedReasonCode(String raw) {
  final value = raw.trim();
  if (value.isEmpty ||
      value.length > 160 ||
      !RegExp(r'^[a-z0-9]+(?:[._-][a-z0-9]+)*$').hasMatch(value)) {
    throw FormatException('explain_why_reason_code_invalid:' + raw);
  }
  return value;
}

String _validatedLanguageCode(String raw) {
  final locale = AppLocale.parse(raw);
  return locale.languageTag;
}
