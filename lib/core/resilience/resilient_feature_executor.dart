import 'dart:async';
import '../concurrency/cancellation_token.dart';
import 'recovery_outcome.dart';
import 'failure_categorization.dart';


/// Optional work only. Results from a previous UI/session generation are stale.
class ResilientFeatureExecutor {
  static const int defaultMaxAttempts = 3;
  static const Duration defaultBackoff = Duration(milliseconds: 100);
  static const Duration defaultTaskTimeout = Duration(seconds: 3);
  int _generation = 0;

  Future<RecoveryOutcome<T>> execute<T>({
    required Future<T> Function() task,
    CancellationToken? cancellationToken,
    int maxAttempts = defaultMaxAttempts,
    Duration backoff = defaultBackoff,
    Duration taskTimeout = defaultTaskTimeout,
  }) async {
    if (maxAttempts < 1 || maxAttempts > 5 ||
        backoff.isNegative || taskTimeout <= Duration.zero) {
      throw ArgumentError('Invalid resilience bounds');
    }
    final generation = ++_generation;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (cancellationToken?.isCancelled ?? false) {
        return RecoveryOutcome<T>.cancelled();
      }
      if (generation != _generation) return RecoveryOutcome<T>.stale();
      try {
        final result = await task().timeout(taskTimeout);
        if (cancellationToken?.isCancelled ?? false) {
          return RecoveryOutcome<T>.cancelled();
        }
        if (generation != _generation) return RecoveryOutcome<T>.stale();
        return RecoveryOutcome<T>.success(result);
      } catch (error, stack) {
        // Critical storage/integrity failure cannot be silently retried.
        if (FailureCategorization.isCritical(error)) {
          Error.throwWithStackTrace(error, stack);
        }
        if (cancellationToken?.isCancelled ?? false) {
          return RecoveryOutcome<T>.cancelled();
        }
        if (generation != _generation) return RecoveryOutcome<T>.stale();
        // Dart Future.timeout cannot terminate an underlying async task.
        // Retrying it may replay writes after the caller has moved on.
        if (error is TimeoutException || attempt == maxAttempts) {
          return RecoveryOutcome<T>.failed(error, stack);
        }
        await Future<void>.delayed(backoff * attempt);
      }
    }
    return RecoveryOutcome<T>.failed(StateError('Retries exhausted'));
  }

  void resetSession() => ++_generation;
}
