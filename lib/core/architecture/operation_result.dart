abstract class OperationFailure {
  final String code;
  final String message;
  final Object? cause;

  const OperationFailure(this.code, this.message, [this.cause]);

  @override
  String toString() => 'OperationFailure(code: $code, message: $message)';
}

class StorageFailure extends OperationFailure {
  const StorageFailure(super.code, super.message, [super.cause]);
}

class ContentFailure extends OperationFailure {
  const ContentFailure(super.code, super.message, [super.cause]);
}

class UnavailableFailure extends OperationFailure {
  const UnavailableFailure(super.code, super.message, [super.cause]);
}

class InvalidInputFailure extends OperationFailure {
  const InvalidInputFailure(super.code, super.message, [super.cause]);
}

class CancelledFailure extends OperationFailure {
  const CancelledFailure(super.code, super.message, [super.cause]);
}

class IncompatibleVersionFailure extends OperationFailure {
  const IncompatibleVersionFailure(super.code, super.message, [super.cause]);
}

class OperationResult<T> {
  final T? _data;
  final OperationFailure? _failure;

  const OperationResult.success(this._data) : _failure = null;
  const OperationResult.failure(this._failure) : _data = null;

  bool get isSuccess => _failure == null;

  T get data {
    if (!isSuccess) throw StateError('Cannot get data from a failure result');
    return _data as T;
  }

  OperationFailure get failure {
    if (isSuccess) throw StateError('Cannot get failure from a success result');
    return _failure!;
  }
}
