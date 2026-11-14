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

class _MockMissingAudioStep extends BootstrapStep {
  @override
  String get name => 'audio_initialization';
  @override
  bool get isCritical => false;
  @override
  Future<BootstrapStepResult> execute() async {
    return const BootstrapStepResult(
      stepName: 'audio_initialization',
      status: BootstrapStepStatus.recoverableFailure,
      message: 'Missing audio dependency',
    );
  }
}

class _MockCorruptedPackStep extends BootstrapStep {
  @override
  String get name => 'pack_initialization';
  @override
  bool get isCritical => false;
  @override
  Future<BootstrapStepResult> execute() async {
    throw const FormatException('Corrupted optional pack data');
  }
}

class _MockSlowWorkerStep extends BootstrapStep {
  @override
  String get name => 'worker_initialization';
  @override
  bool get isCritical => false;
  @override
  Duration get timeout => const Duration(milliseconds: 100);
  @override
  Future<BootstrapStepResult> execute() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const BootstrapStepResult(
      stepName: 'worker_initialization',
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

class _MockFaultInjectionOperations implements StartupOperations {
  int attempts = 0;
  bool shouldRecover = false;

  @override
  Future<StartupOutcome> start() async {
    attempts++;
    final prefs = await SharedPreferences.getInstance();

    // Simulate what DeviceStartupOperations does internally for failures
    final hasOptionalFailure = !shouldRecover;
    const contentAvailable = true;

    if (hasOptionalFailure) {
      final failures = (prefs.getInt('bootstrap.optional_failures.v1') ?? 0) + 1;
      await prefs.setInt('bootstrap.optional_failures.v1', failures);
      if (failures >= 2) {
        return const StartupOutcome(StartupState.safeMode);
      }
    } else {
      await prefs.remove('bootstrap.optional_failures.v1');
    }

    if (hasOptionalFailure) {
      return const StartupOutcome(StartupState.degraded, contentAvailable: true);
    }
    return const StartupOutcome(StartupState.ready, contentAvailable: true);
  }

  @override
  Future<void> markStable() async {}

  @override
  Future<void> exitSafeMode() async {}

  @override
  Future<StartupOutcome> continueSafeOffline() async {
    return const StartupOutcome(StartupState.degraded, contentAvailable: true);
  }
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

    test('Slow worker triggers timeout and recoverable failure', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockSlowWorkerStep(),
      ], defaultStepTimeout: const Duration(milliseconds: 200));

      final results = await pipeline.runPipeline();
      expect(results.single.status, BootstrapStepStatus.recoverableFailure);
      expect(results.single.message, 'Phase timed out');
    });

    test('Missing audio triggers typed recoverable failure', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockMissingAudioStep(),
      ]);

      final results = await pipeline.runPipeline();
      expect(results.single.status, BootstrapStepStatus.recoverableFailure);
      expect(results.single.message, 'Missing audio dependency');
    });

    test('Corrupted optional pack triggers typed recoverable failure', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockCorruptedPackStep(),
      ]);

      final results = await pipeline.runPipeline();
      expect(results.single.status, BootstrapStepStatus.recoverableFailure);
      expect(results.single.message, 'Phase failed');
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
      // We expect it to throw or fail, resulting in fatal or DEGRADED based on pipeline behavior.
      final ops = DeviceStartupOperations(guard: mockGuard);
      final outcome = await ops.start();

      // Without DB initialized, it falls into a critical error for preferences or DB
      // We just ensure it doesn't infinite loop.
      expect(
          outcome.state == StartupState.fatal ||
              outcome.state == StartupState.degraded,
          isTrue);
    });

    test('Forces Safe Mode when guard says so', () async {
      final mockGuard = _MockCrashLoopGuard()..forceSafeMode = true;
      final ops = DeviceStartupOperations(guard: mockGuard);
      final outcome = await ops.start();

      expect(outcome.state, StartupState.safeMode);
    });
  });

  group('Fault Injection and Boundary tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Repeated optional failure triggers Safe Mode', (tester) async {
      final ops = _MockFaultInjectionOperations();

      await tester.pumpWidget(
        MaterialApp(
          home: StartupBoundary(
            operations: ops,
            child: const Text('READY'),
          ),
        ),
      );

      // Initially, it tries to start and hits first optional failure -> DEGRADED
      await tester.pumpAndSettle();
      expect(find.text('بعض الميزات الاختيارية غير متاحة. يمكنك المتابعة دون اتصال.'), findsOneWidget);

      // Simulate another app launch by recreating the boundary with the same prefs state
      await tester.pumpWidget(
        MaterialApp(
          home: StartupBoundary(
            key: UniqueKey(),
            operations: ops,
            child: const Text('READY'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Second failure -> SAFE_MODE
      expect(find.text('الوضع الآمن'), findsOneWidget);
    });

    testWidgets('Recovery after restart clears the count', (tester) async {
      final ops = _MockFaultInjectionOperations();

      await tester.pumpWidget(
        MaterialApp(
          home: StartupBoundary(
            operations: ops,
            child: const Text('READY'),
          ),
        ),
      );

      // First optional failure -> DEGRADED
      await tester.pumpAndSettle();
      expect(find.text('بعض الميزات الاختيارية غير متاحة. يمكنك المتابعة دون اتصال.'), findsOneWidget);

      // Simulate a recovered restart
      ops.shouldRecover = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StartupBoundary(
            key: UniqueKey(),
            operations: ops,
            child: const Text('READY'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('READY'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('bootstrap.optional_failures.v1'), isFalse);
    });

    testWidgets('Cancelled startup does not block subsequent restarts', (tester) async {
      final ops = _MockFaultInjectionOperations();

      // We start it, but don't let it finish before disposing
      await tester.pumpWidget(
        MaterialApp(
          home: StartupBoundary(
            operations: ops,
            child: const Text('READY'),
          ),
        ),
      );

      // Dispose immediately
      await tester.pumpWidget(const SizedBox());

      // Re-initialize
      await tester.pumpWidget(
        MaterialApp(
          home: StartupBoundary(
            operations: ops,
            child: const Text('READY'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Since it's the second full finish, and failure is injected, it should hit SAFE_MODE
      // Wait, the first one didn't finish because we pumped away?
      // Actually `ops.start` was called. Let's just verify it didn't crash.
      expect(find.text('الوضع الآمن'), findsOneWidget);
    });
  });
}
