abstract class OperationFailure {
  final String code;
  final String message;

  /// Raw cause is not exposed through a public property or toString.
  final Object? _cause;
  const OperationFailure(this.code, this.message, [this._cause]);

  @override
  String toString() => 'OperationFailure(code: $code, message: $message)';
}

class StorageFailure extends OperationFailure {
  const StorageFailure(String code, String message, [Object? cause])
      : super(code, message, cause);
}

class ContentFailure extends OperationFailure {
  const ContentFailure(String code, String message, [Object? cause])
      : super(code, message, cause);
}

class UnavailableFailure extends OperationFailure {
  const UnavailableFailure(String code, String message, [Object? cause])
      : super(code, message, cause);
}

class InvalidInputFailure extends OperationFailure {
  const InvalidInputFailure(String code, String message, [Object? cause])
      : super(code, message, cause);
}

class CancelledFailure extends OperationFailure {
  const CancelledFailure(String code, String message, [Object? cause])
      : super(code, message, cause);
}

class IncompatibleVersionFailure extends OperationFailure {
  const IncompatibleVersionFailure(String code, String message, [Object? cause])
      : super(code, message, cause);
}

class OperationResult<T> {
  final T? _data;
  final OperationFailure? _failure;

  const OperationResult.success(this._data) : _failure = null;
  const OperationResult.failure(this._failure) : _data = null;

  bool get isSuccess => _failure == null;
  T get data {
    if (!isSuccess) {
      throw StateError('Cannot read data from a failed operation');
    }
    return _data as T;
  }

  OperationFailure get failure {
    if (isSuccess) {
      throw StateError('Cannot read failure from a successful operation');
    }
    return _failure!;
  }
}
