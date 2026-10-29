import '../architecture/operation_result.dart';

enum RecoveryOutcomeState { success, failed, cancelled, stale }

class RecoveryOutcome<T> {
  const RecoveryOutcome.success([this.data])
      : state = RecoveryOutcomeState.success,
        error = null,
        stackTrace = null;

  const RecoveryOutcome.failed(this.error, [this.stackTrace])
      : state = RecoveryOutcomeState.failed,
        data = null;

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

  final RecoveryOutcomeState state;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;

  bool get isSuccess => state == RecoveryOutcomeState.success;
  bool get isFailed => state == RecoveryOutcomeState.failed;
  bool get isCancelled => state == RecoveryOutcomeState.cancelled;
  bool get isStale => state == RecoveryOutcomeState.stale;
}

class FailureCategorization {
  /// Only typed integrity errors are terminal. String-matching on "vault" or
  /// "integrity" could misclassify optional plugins and lead to startup loops.
  static bool isCritical(Object error) => error is StorageFailure;
  static bool isRecoverable(Object error) => !isCritical(error);
}
