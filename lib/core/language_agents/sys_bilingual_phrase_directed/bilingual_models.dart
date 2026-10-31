enum LifeContext {
  greeting,
  shopping,
  housing,
  transport,
  health,
  work,
  bureaucracy,
  social,
  emergency,
}

enum PhraseRegister { neutral, polite, formal, informal }

final class DirectedPhrase {
  const DirectedPhrase({
    required this.id,
    required this.sourceLanguageId,
    required this.targetLanguageId,
    required this.sourceText,
    required this.targetText,
    required this.context,
    required this.register,
    this.semanticSlots = const <String>[],
    this.notes = '',
  });

  final String id;
  final String sourceLanguageId;
  final String targetLanguageId;
  final String sourceText;
  final String targetText;
  final LifeContext context;
  final PhraseRegister register;
  final List<String> semanticSlots;
  final String notes;

  String get pairId => '$sourceLanguageId->$targetLanguageId';
}

final class ContextValidationResult {
  const ContextValidationResult({
    required this.isValid,
    required this.code,
    required this.message,
  });

  final bool isValid;
  final String code;
  final String message;

  const ContextValidationResult.valid()
      : isValid = true,
        code = 'valid',
        message = 'context_and_semantics_valid';

  const ContextValidationResult.invalid(this.code, this.message)
      : isValid = false;
}

final class BilingualResolution {
  const BilingualResolution._({
    required this.isAccepted,
    required this.code,
    required this.path,
    this.phrase,
  });

  final bool isAccepted;
  final String code;
  final List<String> path;
  final DirectedPhrase? phrase;

  factory BilingualResolution.accepted(DirectedPhrase phrase) =>
      BilingualResolution._(
        isAccepted: true,
        code: 'accepted',
        path: <String>[
          phrase.sourceLanguageId,
          phrase.targetLanguageId,
        ],
        phrase: phrase,
      );

  factory BilingualResolution.blocked({
    required String code,
    required String sourceLanguageId,
    required String targetLanguageId,
  }) =>
      BilingualResolution._(
        isAccepted: false,
        code: code,
        path: <String>[sourceLanguageId, targetLanguageId],
      );
}
