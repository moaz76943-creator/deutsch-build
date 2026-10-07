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

/// Deterministic reason-code renderer over one exact admitted learning-content
/// dictionary. No UI-localization fallback participates in explanation lookup.
/// Runtime reason lookup is O(1) and placeholder rendering is bounded by the
/// selected template.
final class DeterministicExplainWhyEngine implements ExplainWhyEngine {
  DeterministicExplainWhyEngine._({
    required L10nDictionary dictionary,
    required Set<String> reasonCodes,
  })  : _dictionary = dictionary,
        _reasonCodes = Set<String>.unmodifiable(reasonCodes);

  factory DeterministicExplainWhyEngine.fromDictionary({
    required L10nDictionary dictionary,
  }) {
    final reasonCodes = _reasonCodesFromDictionary(dictionary);
    return DeterministicExplainWhyEngine._(
      dictionary: dictionary,
      reasonCodes: reasonCodes,
    );
  }

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
    if (!_dictionary.contains(key)) {
      throw StateError('explain_why_template_missing:' + key);
    }
    final message = _dictionary.require(key);

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
