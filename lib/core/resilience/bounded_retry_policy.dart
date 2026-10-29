import 'dart:async';

import 'feature_recovery_outcome.dart';
import 'failure_categorization.dart';

class BoundedRetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;

  BoundedRetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 100),
  });

  Future<FeatureRecoveryOutcome> execute<T>(Future<T> Function() operation,
      {String? sessionId, bool Function()? isDisposed}) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      if (isDisposed != null && isDisposed()) {
        return const RecoveryBlocked(
            FeatureFailureReason.unknown, 'Widget disposed during retry');
      }

      try {
        final result = await operation();
        return RecoverySuccess<T>(result);
      } catch (error) {
        attempts++;
        final outcome = RecoveryOutcomeHelper.classifyFailure(error);

        // Don't retry on blocked critical errors
        if (outcome is RecoveryBlocked || FailureCategorization.isCritical(error)) {
          rethrow;
        }

        if (attempts >= maxAttempts) {
          return outcome;
        }

        if (isDisposed != null && isDisposed()) {
          return const RecoveryBlocked(
              FeatureFailureReason.unknown, 'Widget disposed during retry');
        }

        // Exponential backoff
        // In tests with fake_async, pending timers can cause issues. Use a custom delay.
        final delay = initialDelay * attempts;
        if (delay > Duration.zero) {
          // If we want to support widget unmounting safely we should track the timer,
          // but since this is just an async operation that's decoupled, await Future.delayed
          // and just exit early if disposed. For tests we will configure initialDelay to 0.
          await Future<void>.delayed(delay);
        }
      }
    }

    return const RecoveryDegraded(
        FeatureFailureReason.unknown, 'Max attempts reached.');
  }
}
