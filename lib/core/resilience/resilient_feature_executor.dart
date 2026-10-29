import 'dart:async';

import '../concurrency/cancellation_token.dart';
import 'recovery_outcome.dart';

/// Bounded optional-feature retries; never overlaps multiple attempts after
/// a timeout, and never publishes success from a prior screen/generation.
class ResilientFeatureExecutor {
  static const int defaultMaxAttempts = 3;
  static const Duration defaultBackoff = Duration(milliseconds: 500);
  static const Duration defaultAttemptTimeout = Duration(seconds: 5);

  int _generation = 0;

  Future<RecoveryOutcome<T>> execute<T>({
    required Future<T> Function() task,
    CancellationToken? cancellationToken,
    int maxAttempts = defaultMaxAttempts,
    Duration backoff = defaultBackoff,
    Duration attemptTimeout = defaultAttemptTimeout,
  }) async {
    if (maxAttempts < 1 ||
        maxAttempts > 10 ||
        backoff.isNegative ||
        attemptTimeout <= Duration.zero) {
      throw ArgumentError('Invalid retry or timeout policy');
    }
    final current = ++_generation;
    bool cancelled() => cancellationToken?.isCancelled ?? false;
    bool stale() => current != _generation;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (cancelled()) return const RecoveryOutcome.cancelled();
      if (stale()) return const RecoveryOutcome.stale();
      try {
        final result = await task().timeout(attemptTimeout);
        if (cancelled()) return const RecoveryOutcome.cancelled();
        if (stale()) return const RecoveryOutcome.stale();
        return RecoveryOutcome<T>.success(result);
      } on TimeoutException catch (error, stackTrace) {
        // A timed-out future may continue in the background. Starting a
        // retry would overlap initialization and duplicate side effects.
        if (cancelled()) return const RecoveryOutcome.cancelled();
        if (stale()) return const RecoveryOutcome.stale();
        return RecoveryOutcome<T>.failed(error, stackTrace);
      } catch (error, stackTrace) {
        if (cancelled()) return const RecoveryOutcome.cancelled();
        if (stale()) return const RecoveryOutcome.stale();
        if (FailureCategorization.isCritical(error) ||
            attempt == maxAttempts) {
          return RecoveryOutcome<T>.failed(error, stackTrace);
        }
        await Future<void>.delayed(backoff * attempt);
      }
    }
    return RecoveryOutcome<T>.failed(StateError('Retries exhausted'));
  }

  void resetSession() => _generation++;
}
