import '../architecture/operation_result.dart';

enum RecoveryOutcomeState {
  success,
  failed,
  cancelled,
  stale,
}

class RecoveryOutcome<T> {
  final RecoveryOutcomeState state;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;

  const RecoveryOutcome.success(T data)
      : state = RecoveryOutcomeState.success,
        data = data,
        error = null,
        stackTrace = null;

  const RecoveryOutcome.failed(Object error, [StackTrace? stackTrace])
      : state = RecoveryOutcomeState.failed,
        data = null,
        error = error,
        stackTrace = stackTrace;

  const RecoveryOutcome.cancelled()
      : state = RecoveryOutcomeState.cancelled,
        data = null,
        error = null,
        stackTrace = null;

  const RecoveryOutcome.stale()
      : state = RecoveryOutcomeState.stale,
        data = null,
        error = null,
        stackTrace = null;

  bool get isSuccess => state == RecoveryOutcomeState.success;
  bool get isFailed => state == RecoveryOutcomeState.failed;
  bool get isCancelled => state == RecoveryOutcomeState.cancelled;
  bool get isStale => state == RecoveryOutcomeState.stale;
}

class FailureCategorization {
  static bool isCritical(Object error) {
    if (error is StorageFailure) return true;

    final errorString = error.toString().toLowerCase();
    if (errorString.contains('vault') ||
        errorString.contains('integrity')) {
      return true;
    }

    return false;
  }

  static bool isRecoverable(Object error) {
    return !isCritical(error);
  }
}
