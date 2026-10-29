enum DeckValidationErrorCode {
  invalidJson,
  invalidRoot,
  missingRequiredField,
  invalidFieldType,
  invalidValue,
  directionMismatch,
  inconsistentMetadata,
}

final class DeckValidationError {
  const DeckValidationError({
    required this.code,
    required this.path,
    required this.message,
  });

  final DeckValidationErrorCode code;
  final String path;
  final String message;

  @override
  String toString() => '$path: $message';
}

/// Typed aggregate validation failure with every provable error from one pass.
final class DeckValidationException implements Exception {
  DeckValidationException(Iterable<DeckValidationError> errors)
      : errors = List<DeckValidationError>.unmodifiable(errors);

  final List<DeckValidationError> errors;

  @override
  String toString() =>
      'DeckValidationException(${errors.map((error) => error.toString()).join('; ')})';
}
