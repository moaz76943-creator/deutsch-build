abstract class OperationFailure {
  final String code;
  final String message;
  final String? cause;
  const OperationFailure(this.code, this.message, {this.cause});
}

class StorageFailure extends OperationFailure {
  const StorageFailure(super.code, super.message, {super.cause});
}

class ContentFailure extends OperationFailure {
  const ContentFailure(super.code, super.message, {super.cause});
}

class UnavailableFailure extends OperationFailure {
  const UnavailableFailure(super.code, super.message, {super.cause});
}

class InvalidInputFailure extends OperationFailure {
  const InvalidInputFailure(super.code, super.message, {super.cause});
}

class CancelledFailure extends OperationFailure {
  const CancelledFailure(super.code, super.message, {super.cause});
}

class IncompatibleVersionFailure extends OperationFailure {
  const IncompatibleVersionFailure(super.code, super.message, {super.cause});
}

sealed class OperationResult<T> {
  const OperationResult();

  const factory OperationResult.success(T? data) = SuccessOutcome<T>;
  factory OperationResult.failure(OperationFailure failure) {
    if (failure is UnavailableFailure) return UnavailableOutcome<T>(failure);
    if (failure is InvalidInputFailure) return InvalidInputOutcome<T>(failure);
    if (failure is CancelledFailure) return CancelledOutcome<T>(failure);
    if (failure is IncompatibleVersionFailure) return IncompatibleVersionOutcome<T>(failure);
    return GenericFailureOutcome<T>(failure);
  }

  bool get isSuccess;
  T? get _data;
  OperationFailure? get _failure;

  T get data => _data!;
  OperationFailure get failure => _failure!;
}

class SuccessOutcome<T> extends OperationResult<T> {
  @override
  final T? _data;
  const SuccessOutcome(this._data);

  @override
  bool get isSuccess => true;

  @override
  OperationFailure? get _failure => null;
}

abstract class FailureOutcome<T> extends OperationResult<T> {
  @override
  final OperationFailure _failure;
  const FailureOutcome(this._failure);

  @override
  bool get isSuccess => false;

  @override
  T? get _data => null;
}

class UnavailableOutcome<T> extends FailureOutcome<T> {
  const UnavailableOutcome(UnavailableFailure super.failure);
}

class InvalidInputOutcome<T> extends FailureOutcome<T> {
  const InvalidInputOutcome(InvalidInputFailure super.failure);
}

class CancelledOutcome<T> extends FailureOutcome<T> {
  const CancelledOutcome(CancelledFailure super.failure);
}

class IncompatibleVersionOutcome<T> extends FailureOutcome<T> {
  const IncompatibleVersionOutcome(IncompatibleVersionFailure super.failure);
}

class GenericFailureOutcome<T> extends FailureOutcome<T> {
  const GenericFailureOutcome(super.failure);
}
