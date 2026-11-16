import '../explainer/explainer_models.dart';
import '../l10n/l10n_models.dart';

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

abstract interface class ExplainWhyEngine {
  bool supports(String reasonCode);
  ExplainWhyResult explain(ExplainerRequest request);
}

/// Deterministic reason-code renderer over an admitted [L10nDictionary].
///
/// Templates are supplied through the injected dictionary; this engine is
/// deliberately decoupled from the UI localization runtime and contains no
/// user-facing explanation prose. Runtime reason lookup is O(1) and
/// placeholder rendering is bounded by the selected template.
final class DeterministicExplainWhyEngine implements ExplainWhyEngine {
  DeterministicExplainWhyEngine({
    required L10nDictionary dictionary,
  })  : _dictionary = dictionary,
        _reasonCodes = _reasonCodesFromDictionary(dictionary);

  factory DeterministicExplainWhyEngine.fromDictionary({
    required L10nDictionary dictionary,
    required String userLanguageCode,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) =>
      DeterministicExplainWhyEngine(dictionary: dictionary);

  final L10nDictionary _dictionary;
  final Set<String> _reasonCodes;

  @override
  bool supports(String reasonCode) {
    try {
      return _reasonCodes.contains(_validatedReasonCode(reasonCode));
    } on FormatException {
      return false;
    }
  }

  @override
  ExplainWhyResult explain(ExplainerRequest request) {
    final rawReasonCode = request.reasonCode;
    if (rawReasonCode == null || rawReasonCode.trim().isEmpty) {
      throw StateError('explain_why_reason_missing');
    }
    final reasonCode = _validatedReasonCode(rawReasonCode);
    if (!_reasonCodes.contains(reasonCode)) {
      throw StateError('explain_why_reason_unsupported:' + reasonCode);
    }

    final correct = request.correct;
    if (correct == null) {
      throw StateError('explain_why_outcome_missing:' + reasonCode);
    }

    final key = _messageKey(reasonCode, correct: correct);
    final L10nMessage message;
    try {
      message = _dictionary.require(key);
    } on StateError {
      throw StateError('explain_why_template_missing:' + key);
    }

    return ExplainWhyResult(
      reasonCode: reasonCode,
      languageCode: _dictionary.locale.languageTag,
      text: message.render(arguments: request.arguments),
    );
  }
}

Set<String> _reasonCodesFromDictionary(L10nDictionary dictionary) {
  const prefix = 'explain.';
  const correctSuffix = '.correct';
  const incorrectSuffix = '.incorrect';

  final variants = <String, int>{};
  for (final key in dictionary.messages.keys) {
    if (!key.startsWith(prefix)) continue;

    late final String reasonCode;
    late final int mask;
    if (key.endsWith(correctSuffix)) {
      reasonCode = key.substring(
        prefix.length,
        key.length - correctSuffix.length,
      );
      mask = 1;
    } else if (key.endsWith(incorrectSuffix)) {
      reasonCode = key.substring(
        prefix.length,
        key.length - incorrectSuffix.length,
      );
      mask = 2;
    } else {
      throw FormatException('explain_why_template_key_invalid:' + key);
    }

    final normalized = _validatedReasonCode(reasonCode);
    variants[normalized] = (variants[normalized] ?? 0) | mask;
  }

  if (variants.isEmpty) {
    throw const FormatException('explain_why_catalog_empty');
  }
  for (final entry in variants.entries) {
    if (entry.value != 3) {
      throw FormatException(
        'explain_why_template_pair_incomplete:' + entry.key,
      );
    }
  }
  return variants.keys.toSet();
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
