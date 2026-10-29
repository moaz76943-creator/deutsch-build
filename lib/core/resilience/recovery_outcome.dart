sealed class RecoveryOutcome<T> {
  const RecoveryOutcome();

  bool get isSuccess => this is RecoverySuccess<T>;
  bool get isFailed => this is RecoveryFailed<T>;
  bool get isCancelled => this is RecoveryCancelled<T>;
  bool get isStale => this is RecoveryStale<T>;

  T? get data => this is RecoverySuccess<T> ? (this as RecoverySuccess<T>).value : null;
  Object? get error => this is RecoveryFailed<T> ? (this as RecoveryFailed<T>).err : null;
  StackTrace? get stackTrace => this is RecoveryFailed<T> ? (this as RecoveryFailed<T>).stack : null;

  factory RecoveryOutcome.success(T value) = RecoverySuccess<T>;
  factory RecoveryOutcome.failed(Object err, [StackTrace? stack]) = RecoveryFailed<T>;
  factory RecoveryOutcome.cancelled() = RecoveryCancelled<T>;
  factory RecoveryOutcome.stale() = RecoveryStale<T>;
}

class RecoverySuccess<T> extends RecoveryOutcome<T> {
  final T value;
  const RecoverySuccess(this.value);
}

class RecoveryFailed<T> extends RecoveryOutcome<T> {
  final Object err;
  final StackTrace? stack;
  const RecoveryFailed(this.err, [this.stack]);
}

class RecoveryCancelled<T> extends RecoveryOutcome<T> {
  const RecoveryCancelled();
}

class RecoveryStale<T> extends RecoveryOutcome<T> {
  const RecoveryStale();
}
