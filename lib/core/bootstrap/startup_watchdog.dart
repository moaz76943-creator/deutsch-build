import 'dart:async';

enum BootstrapStatus {
  ready,
  degradedOffline,
  timeoutRecovered,
  failedSafeFallback,
}

class BootstrapOutcome {
  final BootstrapStatus status;
  final Duration elapsed;
  final String destinationRoute;
  final String? warning;

  const BootstrapOutcome({
    required this.status,
    required this.elapsed,
    required this.destinationRoute,
    this.warning,
  });

  bool get canNavigate => true; // Guarantees splash never deadlocks
}

/// StartupWatchdog enforces Master Constitution Section 10:
/// Offline boot must not depend on network, heavy CPU is off Splash path,
/// and splash screen navigation is guaranteed via strict watchdog timeout.
class StartupWatchdog {
  final Duration maxBootTimeout;
  final String defaultHomeRoute;

  const StartupWatchdog({
    this.maxBootTimeout = const Duration(seconds: 4),
    this.defaultHomeRoute = '/home',
  });

  Future<BootstrapOutcome> executeBootstrap(
    Future<String> Function() fastInitAction,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final route = await fastInitAction().timeout(
        maxBootTimeout,
        onTimeout: () {
          // Timeout reached: recover gracefully without blocking UI
          return defaultHomeRoute;
        },
      );

      stopwatch.stop();
      final timedOut = stopwatch.elapsed >= maxBootTimeout;

      return BootstrapOutcome(
        status: timedOut ? BootstrapStatus.timeoutRecovered : BootstrapStatus.ready,
        elapsed: stopwatch.elapsed,
        destinationRoute: route,
        warning: timedOut ? 'Bootstrap exceeded budget; transitioned into degraded mode.' : null,
      );
    } catch (e) {
      stopwatch.stop();
      // Fail-safe: Navigate to default route even if an unhandled initialization error occurs
      return BootstrapOutcome(
        status: BootstrapStatus.failedSafeFallback,
        elapsed: stopwatch.elapsed,
        destinationRoute: defaultHomeRoute,
        warning: 'Initialization error encountered: $e. Fail-safe route activated.',
      );
    }
  }
}
