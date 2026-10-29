abstract class OperationFailure {
  final String code;
  final String message;
  final Object? cause;
  const OperationFailure(this.code, this.message, [this.cause]);
}

class StorageFailure extends OperationFailure {
  const StorageFailure(String code, String message, [Object? cause]) : super(code, message, cause);
}

class ContentFailure extends OperationFailure {
  const ContentFailure(String code, String message, [Object? cause]) : super(code, message, cause);
}

class UnavailableFailure extends OperationFailure {
  const UnavailableFailure(String code, String message, [Object? cause]) : super(code, message, cause);
}

class InvalidInputFailure extends OperationFailure {
  const InvalidInputFailure(String code, String message, [Object? cause]) : super(code, message, cause);
}

class CancelledFailure extends OperationFailure {
  const CancelledFailure(String code, String message, [Object? cause]) : super(code, message, cause);
}

class IncompatibleVersionFailure extends OperationFailure {
  const IncompatibleVersionFailure(String code, String message, [Object? cause]) : super(code, message, cause);
}

class OperationResult<T> {
  final T? _data;
  final OperationFailure? _failure;

  const OperationResult.success(this._data) : _failure = null;
  const OperationResult.failure(this._failure) : _data = null;

  factory OperationResult.unavailable(String code, String message, [Object? cause]) =>
      OperationResult.failure(UnavailableFailure(code, message, cause));

  factory OperationResult.invalidInput(String code, String message, [Object? cause]) =>
      OperationResult.failure(InvalidInputFailure(code, message, cause));

  factory OperationResult.cancelled(String code, String message, [Object? cause]) =>
      OperationResult.failure(CancelledFailure(code, message, cause));

  factory OperationResult.incompatibleVersion(String code, String message, [Object? cause]) =>
      OperationResult.failure(IncompatibleVersionFailure(code, message, cause));

  bool get isSuccess => _failure == null;
  T get data => _data!;
  OperationFailure get failure => _failure!;
}
