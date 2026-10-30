import 'dart:async';
import '../concurrency/cancellation_token.dart';
import 'recovery_outcome.dart';

class ResilientFeatureExecutor {
  static const int defaultMaxAttempts = 3;
  static const Duration defaultBackoff = Duration(milliseconds: 500);

  int _operationCounter = 0;

  Future<RecoveryOutcome<T>> execute<T>({
    required Future<T> Function() task,
    CancellationToken? cancellationToken,
    int maxAttempts = defaultMaxAttempts,
    Duration backoff = defaultBackoff,
  }) async {
    final int currentOperationToken = ++_operationCounter;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      if (cancellationToken != null && cancellationToken.isCancelled) {
        return const RecoveryOutcome.cancelled();
      }

      try {
        final result = await task();

        if (cancellationToken != null && cancellationToken.isCancelled) {
          return const RecoveryOutcome.cancelled();
        }

        if (currentOperationToken != _operationCounter) {
          return const RecoveryOutcome.stale();
        }

        return RecoveryOutcome.success(result);
      } catch (e, stackTrace) {
        if (FailureCategorization.isCritical(e)) {
          // Critical failures should be propagated or returned as failure immediately,
          // without retrying, and before cancellation check.
          Error.throwWithStackTrace(e, stackTrace);
        }

        if (cancellationToken != null && cancellationToken.isCancelled) {
          return const RecoveryOutcome.cancelled();
        }

        if (attempt == maxAttempts) {
          return RecoveryOutcome.failed(e, stackTrace);
        }

        // Wait before retrying, if not cancelled
        try {
          await Future.delayed(backoff * attempt);
        } catch (_) {}
      }
    }

    // Should not reach here due to the attempt limit check above, but dart requires return
    return const RecoveryOutcome.failed("Max attempts reached");
  }

  void resetSession() {
    _operationCounter++;
  }
}
