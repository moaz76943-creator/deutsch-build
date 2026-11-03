import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/bootstrap/isolated_bootstrap_pipeline.dart';
import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';
import 'package:deutsch_bilarabi/services/crash_loop_guard.dart';

class _MockCriticalStep extends BootstrapStep {
  @override
  String get name => 'mock_critical';

  @override
  bool get isCritical => true;

  @override
  Duration get timeout => const Duration(seconds: 1);

  final bool shouldSucceed;

  _MockCriticalStep({this.shouldSucceed = true});

  @override
  Future<BootstrapStepResult> execute() async {
    return BootstrapStepResult(
      stepName: name,
      status: shouldSucceed
          ? BootstrapStepStatus.success
          : BootstrapStepStatus.fatalFailure,
    );
  }
}

class _MockOptionalStep extends BootstrapStep {
  @override
  String get name => 'mock_optional';

  @override
  bool get isCritical => false;

  @override
  Duration get timeout => const Duration(milliseconds: 200);

  final bool shouldThrow;
  final bool shouldTimeout;
  final bool shouldFail;

  _MockOptionalStep({
    this.shouldThrow = false,
    this.shouldTimeout = false,
    this.shouldFail = false,
  });

  @override
  Future<BootstrapStepResult> execute() async {
    if (shouldThrow) {
      throw Exception('Optional step crashed');
    }
    if (shouldTimeout) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return const BootstrapStepResult(
        stepName: 'mock_optional',
        status: BootstrapStepStatus.success,
      );
    }
    return BootstrapStepResult(
      stepName: name,
      status: shouldFail
          ? BootstrapStepStatus.recoverableFailure
          : BootstrapStepStatus.success,
    );
  }
}

class _MockAudioStep extends BootstrapStep {
  @override
  String get name => 'mock_audio';

  @override
  bool get isCritical => false;

  @override
  Future<BootstrapStepResult> execute() async {
    return const BootstrapStepResult(
      stepName: 'mock_audio',
      status: BootstrapStepStatus.recoverableFailure,
    );
  }
}

class _MockCorruptedPackStep extends BootstrapStep {
  @override
  String get name => 'mock_corrupted_pack';

  @override
  bool get isCritical => false;

  @override
  Future<BootstrapStepResult> execute() async {
    return const BootstrapStepResult(
      stepName: 'mock_corrupted_pack',
      status: BootstrapStepStatus.recoverableFailure,
    );
  }
}

class _MockActiveContentStep extends BootstrapStep {
  @override
  String get name => 'active_content';

  @override
  bool get isCritical => false;

  @override
  Future<BootstrapStepResult> execute() async {
    return const BootstrapStepResult(
      stepName: 'active_content',
      status: BootstrapStepStatus.success,
    );
  }
}

class _MockSlowWorkerStep extends BootstrapStep {
  @override
  String get name => 'mock_slow_worker';

  @override
  bool get isCritical => false;

  @override
  Duration get timeout => const Duration(milliseconds: 50);

  @override
  Future<BootstrapStepResult> execute() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const BootstrapStepResult(
      stepName: 'mock_slow_worker',
      status: BootstrapStepStatus.success,
    );
  }
}

class _MockCrashLoopGuard extends CrashLoopGuard {
  bool forceSafeMode = false;

  _MockCrashLoopGuard() : super(store: _MockBootLedgerStore());

  @override
  Future<bool> beginBoot() async {
    return forceSafeMode;
  }
}

class _MockBootLedgerStore implements BootLedgerStore {
  @override
  Future<Map<String, dynamic>?> read() async => null;
  @override
  Future<void> write(Map<String, dynamic> state) async {}
}

void main() {
  group('IsolatedBootstrapPipeline', () {
    test('Executes steps and correctly classifies failures', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockCriticalStep(shouldSucceed: true),
        _MockOptionalStep(shouldFail: true), // Should be recoverable
        _MockOptionalStep(shouldThrow: true), // Should be recoverable
        _MockOptionalStep(shouldTimeout: true), // Should be recoverable
      ]);

      final results = await pipeline.runPipeline();

      expect(results.length, 4);

      final criticalResult =
          results.firstWhere((r) => r.stepName == 'mock_critical');
      expect(criticalResult.status, BootstrapStepStatus.success);

      final failingResults =
          results.where((r) => r.stepName == 'mock_optional').toList();
      expect(failingResults.length, 3);
      for (final result in failingResults) {
        expect(result.status, BootstrapStepStatus.recoverableFailure);
      }
    });

    test('Critical failure is correctly classified', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockCriticalStep(shouldSucceed: false),
      ]);

      final results = await pipeline.runPipeline();
      expect(results.single.status, BootstrapStepStatus.fatalFailure);
    });

    test('Missing audio fault injection returns recoverable failure', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockCriticalStep(shouldSucceed: true),
        _MockAudioStep(),
      ]);

      final results = await pipeline.runPipeline();
      expect(results.length, 2);
      expect(results[1].status, BootstrapStepStatus.recoverableFailure);
    });

    test('Corrupted optional pack fault injection returns recoverable failure', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockCriticalStep(shouldSucceed: true),
        _MockCorruptedPackStep(),
      ]);

      final results = await pipeline.runPipeline();
      expect(results.length, 2);
      expect(results[1].status, BootstrapStepStatus.recoverableFailure);
    });

    test('Slow worker fault injection resolves to recoverable failure after timeout', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockSlowWorkerStep(),
      ]);

      final results = await pipeline.runPipeline();
      expect(results.single.status, BootstrapStepStatus.recoverableFailure);
      expect(results.single.message, 'Phase timed out');
    });
  });

  group('DeviceStartupOperations', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
        'Handles missing extra steps gracefully (CRITICAL_ERROR from active_content)',
        () async {
      final mockGuard = _MockCrashLoopGuard();
      // Since it's a real DeviceStartupOperations, _ActiveContentStep will try to hit the real DB.
      // We expect it to throw or fail, resulting in CRITICAL_ERROR or DEGRADED based on pipeline behavior.
      final ops = DeviceStartupOperations(guard: mockGuard);
      final outcome = await ops.start();

      // Without DB initialized, it falls into a critical error for preferences or DB
      // We just ensure it doesn't infinite loop.
      expect(
          outcome.state == StartupState.CRITICAL_ERROR ||
              outcome.state == StartupState.DEGRADED,
          isTrue);
    });

    test('Forces Safe Mode when guard says so', () async {
      final mockGuard = _MockCrashLoopGuard()..forceSafeMode = true;
      final ops = DeviceStartupOperations(guard: mockGuard);
      final outcome = await ops.start();

      expect(outcome.state, StartupState.SAFE_MODE);
    });

    test('Repeated optional failure triggers Safe Mode', () async {
      final mockGuard = _MockCrashLoopGuard();
      final ops = DeviceStartupOperations(guard: mockGuard);

      // Attempt 1 -> DEGRADED
      final outcome1 = await ops.start();
      expect(outcome1.state, StartupState.DEGRADED);

      // Attempt 2 -> DEGRADED
      final outcome2 = await ops.start();
      expect(outcome2.state, StartupState.DEGRADED);

      // Attempt 3 -> SAFE_MODE
      final outcome3 = await ops.start();
      expect(outcome3.state, StartupState.SAFE_MODE);
    });

    test('Recovery after restart clears the failure counter', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('optional_failure_count', 3);

      final mockGuard = _MockCrashLoopGuard();

      // Inject a successful pipeline (no optional failures, and content is available)
      final successPipeline = IsolatedBootstrapPipeline([
        _MockCriticalStep(shouldSucceed: true),
        _MockActiveContentStep(),
      ]);

      final ops = DeviceStartupOperations(guard: mockGuard, testPipeline: successPipeline);

      final outcome = await ops.start();
      expect(outcome.state, StartupState.READY);
      expect(prefs.getInt('optional_failure_count'), null);
    });
  });

  group('StartupBoundary Widget', () {
    testWidgets('Cancelled startup avoids stale completions', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      final mockGuard = _MockCrashLoopGuard();
      final ops = DeviceStartupOperations(guard: mockGuard);

      // Mount and immediately unmount to trigger disposal
      await tester.pumpWidget(MaterialApp(
        home: StartupBoundary(
          operations: ops,
          child: const Text('Ready'),
        ),
      ));

      // Destroy the widget before boot finishes
      await tester.pumpWidget(const SizedBox());

      // Advance time enough to clear all pending futures/timers from the pipeline.
      await tester.pump(const Duration(seconds: 25));
      await tester.pumpAndSettle();

      // No unhandled errors or stale setState should occur
      expect(find.text('Ready'), findsNothing);
    });
  });
}
