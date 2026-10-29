import 'dart:async';
import 'package:test/test.dart';
import 'package:deutsch_app/core/bootstrap/startup_watchdog.dart';

void main() {
  group('StartupWatchdog Bootstrap Resilience', () {
    test('Navigates promptly to destination route when initialization succeeds', () async {
      const watchdog = StartupWatchdog(
        maxBootTimeout: Duration(milliseconds: 200),
      );

      final outcome = await watchdog.executeBootstrap(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return '/dashboard';
      });

      expect(outcome.status, equals(BootstrapStatus.ready));
      expect(outcome.destinationRoute, equals('/dashboard'));
      expect(outcome.canNavigate, isTrue);
    });

    test('Breaks hanging initialization and guarantees navigation via timeout recovery', () async {
      const watchdog = StartupWatchdog(
        maxBootTimeout: Duration(milliseconds: 50),
        defaultHomeRoute: '/home',
      );

      // Simulate a hung future (e.g. blocked network socket or deadlocked lock)
      final outcome = await watchdog.executeBootstrap(() async {
        final completer = Completer<String>();
        // Never completes deliberately
        return completer.future;
      });

      expect(outcome.status, equals(BootstrapStatus.timeoutRecovered));
      expect(outcome.destinationRoute, equals('/home'));
      expect(outcome.canNavigate, isTrue);
      expect(outcome.warning, contains('Bootstrap exceeded budget'));
    });

    test('Safely catches errors during initialization and provides fail-safe navigation', () async {
      const watchdog = StartupWatchdog(
        maxBootTimeout: Duration(milliseconds: 100),
        defaultHomeRoute: '/home',
      );

      final outcome = await watchdog.executeBootstrap(() async {
        throw StateError('Simulated SQLite pack admission fault');
      });

      expect(outcome.status, equals(BootstrapStatus.failedSafeFallback));
      expect(outcome.destinationRoute, equals('/home'));
      expect(outcome.canNavigate, isTrue);
    });
  });
}
