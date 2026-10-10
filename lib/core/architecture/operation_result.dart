abstract class OperationFailure {
  final String code;
  final String message;
  const OperationFailure(this.code, this.message);
}

class StorageFailure extends OperationFailure {
  const StorageFailure(super.code, super.message);
}

class ContentFailure extends OperationFailure {
  const ContentFailure(super.code, super.message);
}

class OperationResult<T> {
  final T? _data;
  final OperationFailure? _failure;

  const OperationResult.success(this._data) : _failure = null;
  const OperationResult.failure(this._failure) : _data = null;

  bool get isSuccess => _failure == null;
  T get data => _data!;
  OperationFailure get failure => _failure!;
}
