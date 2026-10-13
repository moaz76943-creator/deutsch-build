import '../architecture/operation_result.dart';

enum RecoveryOutcomeState { success, failed, cancelled, stale }

class RecoveryOutcome<T> {
  final RecoveryOutcomeState state;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;

  const RecoveryOutcome.success(T result)
      : state = RecoveryOutcomeState.success,
        data = result, error = null, stackTrace = null;
  const RecoveryOutcome.failed(Object failure, [StackTrace? stack])
      : state = RecoveryOutcomeState.failed,
        data = null, error = failure, stackTrace = stack;
  const RecoveryOutcome.cancelled()
      : state = RecoveryOutcomeState.cancelled,
        data = null, error = null, stackTrace = null;
  const RecoveryOutcome.stale()
      : state = RecoveryOutcomeState.stale,
        data = null, error = null, stackTrace = null;

  bool get isSuccess => state == RecoveryOutcomeState.success;
  bool get isFailed => state == RecoveryOutcomeState.failed;
  bool get isCancelled => state == RecoveryOutcomeState.cancelled;
  bool get isStale => state == RecoveryOutcomeState.stale;
}

class FailureCategorization {
  static bool isCritical(Object error) =>
      error is StorageFailure ||
      error.toString().toLowerCase().contains('vault corruption') ||
      error.toString().toLowerCase().contains('data integrity');

  static bool isRecoverable(Object error) => !isCritical(error);
}
