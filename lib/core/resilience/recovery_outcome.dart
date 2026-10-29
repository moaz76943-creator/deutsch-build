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
  /// Storage failures and vault or data-integrity faults stop retry.
  /// A missing optional plugin is not a vault failure.
  static bool isCritical(Object error) {
    if (error is StorageFailure) return true;
    final text = error.toString().toLowerCase();
    if (text.contains('missing plugin')) return false;
    return text.contains('vault') || text.contains('data integrity');
  }

  static bool isRecoverable(Object error) => !isCritical(error);
}
